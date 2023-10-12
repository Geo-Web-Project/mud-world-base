// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "forge-std/Test.sol";
import {MudTest} from "@latticexyz/world/test/MudTest.t.sol";
import {IWorld} from "../src/codegen/world/IWorld.sol";
import {IAugment, Augment} from "../src/modules/augmentinstallation/Augment.sol";
import {ScaleComponent} from "../src/codegen/tables/ScaleComponent.sol";
import {PackedCounter} from "@latticexyz/store/src/PackedCounter.sol";
import {ResourceId} from "@latticexyz/world/src/WorldResourceId.sol";
import {RESOURCE_TABLE} from "@latticexyz/world/src/worldResourceTypes.sol";
import {getUniqueEntity} from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

contract MockAugment is Augment {
    bytes16[][] private componentTypes = [[bytes16(bytes32("ScaleComponent"))]];

    function getName() external view returns (bytes16) {
        return bytes16("MockAugment");
    }

    function getIcon() external view returns (bytes memory) {
        return new bytes(0);
    }

    function getTypes() external view returns (bytes16[][] memory) {
        return componentTypes;
    }

    function performOverrides(bytes14 namespace) external {}
}

contract AugmentInstallationTest is MudTest {
    IWorld world;
    MockAugment mockAugment = new MockAugment();

    function setUp() public override {
        super.setUp();
        world = IWorld(worldAddress);
    }

    function testInstallAugment() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        (
            bytes memory staticData,
            PackedCounter encodedLengths,
            bytes memory dynamicData
        ) = ScaleComponent.encode(1, 2, 3);

        IAugment.ComponentValue memory componentValue = IAugment
            .ComponentValue({
                staticData: staticData,
                encodedLengths: encodedLengths,
                dynamicData: dynamicData
            });
        IAugment.ComponentValue[][]
            memory componentValues = new IAugment.ComponentValue[][](1);
        componentValues[0] = new IAugment.ComponentValue[](1);
        componentValues[0][0] = componentValue;

        world.installAugment(
            mockAugment,
            bytes14("world"),
            abi.encode(componentValues)
        );

        vm.stopBroadcast();

        ResourceId _tableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    bytes14("world"),
                    bytes16(bytes32("ScaleComponent"))
                )
            )
        );
        uint256 entityId = uint256(getUniqueEntity(world)) - 1;

        assertEq(
            ScaleComponent.getX(world, _tableId, bytes32(entityId)),
            1,
            "Scale X should be set"
        );
        assertEq(
            ScaleComponent.getY(world, _tableId, bytes32(entityId)),
            2,
            "Scale Y should be set"
        );
        assertEq(
            ScaleComponent.getZ(world, _tableId, bytes32(entityId)),
            3,
            "Scale Z should be set"
        );
    }
}
