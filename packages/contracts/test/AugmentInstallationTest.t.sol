// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "forge-std/Test.sol";
import {MudTest} from "@latticexyz/world/test/MudTest.t.sol";
import {IWorld} from "../src/codegen/world/IWorld.sol";
import {IWorldErrors} from "@latticexyz/world/src/IWorldErrors.sol";
import {IAugment, Augment} from "../src/modules/augmentinstallation/Augment.sol";
import {ScaleCom} from "../src/codegen/tables/ScaleCom.sol";
import {NameCom} from "../src/codegen/tables/NameCom.sol";
import {PackedCounter} from "@latticexyz/store/src/PackedCounter.sol";
import {ResourceId, WorldResourceIdLib, WorldResourceIdInstance} from "@latticexyz/world/src/WorldResourceId.sol";
import {RESOURCE_TABLE} from "@latticexyz/world/src/worldResourceTypes.sol";
import {TABLE_ID as UNIQUE_ENTITY_TABLE_ID} from "@latticexyz/world-modules/src/modules/uniqueentity/constants.sol";
import {UniqueEntity} from "@latticexyz/world-modules/src/modules/uniqueentity/tables/UniqueEntity.sol";
import {getUniqueEntity} from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";
import {Augments} from "../src/modules/augmentinstallation/tables/Augments.sol";
import {AugmentInstallationLib, AugmentComponentValue} from "../src/modules/augmentinstallation/AugmentInstallationSystem.sol";
import {ResourceIds} from "@latticexyz/store/src/StoreCore.sol";

contract AugmentInstallationTest is MudTest {
    IWorld world;
    bytes14 testNamespace = bytes14("parcel1");

    function setUp() public override {
        super.setUp();
        world = IWorld(worldAddress);

        vm.startPrank(address(0x1));
        world.registerNamespace(
            WorldResourceIdLib.encodeNamespace(testNamespace)
        );
        ScaleCom.register(
            world,
            ResourceId.wrap(
                bytes32(
                    abi.encodePacked(
                        RESOURCE_TABLE,
                        testNamespace,
                        bytes16(bytes32("ScaleCom"))
                    )
                )
            )
        );
        NameCom.register(
            world,
            ResourceId.wrap(
                bytes32(
                    abi.encodePacked(
                        RESOURCE_TABLE,
                        testNamespace,
                        bytes16(bytes32("NameCom"))
                    )
                )
            )
        );
        vm.stopPrank();
    }

    function testInstallAugment_Single() public {
        MockAugmentSingle mockAugment = new MockAugmentSingle();

        (
            bytes memory staticData,
            PackedCounter encodedLengths,
            bytes memory dynamicData
        ) = ScaleCom.encode(1, 2, 3);

        AugmentComponentValue memory componentValue = AugmentComponentValue({
            staticData: staticData,
            encodedLengths: encodedLengths,
            dynamicData: dynamicData
        });
        AugmentComponentValue[][]
            memory componentValues = new AugmentComponentValue[][](1);
        componentValues[0] = new AugmentComponentValue[](1);
        componentValues[0][0] = componentValue;

        vm.startPrank(address(0x1));
        world.installAugment(
            mockAugment,
            testNamespace,
            abi.encode(componentValues)
        );
        vm.stopPrank();

        ResourceId _tableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("ScaleCom"))
                )
            )
        );
        uint256 entityId = uint256(getUniqueEntity(world)) - 1;

        assertEq(
            ScaleCom.getX(world, _tableId, bytes32(entityId)),
            1,
            "Scale X should be set"
        );
        assertEq(
            ScaleCom.getY(world, _tableId, bytes32(entityId)),
            2,
            "Scale Y should be set"
        );
        assertEq(
            ScaleCom.getZ(world, _tableId, bytes32(entityId)),
            3,
            "Scale Z should be set"
        );
        assertEq(
            Augments.get(
                world,
                AugmentInstallationLib.getAugmentsTableId(
                    WorldResourceIdLib.encodeNamespace(bytes14("world"))
                ),
                address(mockAugment),
                keccak256(abi.encode(componentValues))
            ),
            mockAugment.getMetadataURI(),
            "Augment should be installed"
        );
    }

    function testInstallAugment_MultipleComponents() public {
        MockAugmentMultipleComponents mockAugment = new MockAugmentMultipleComponents();

        AugmentComponentValue[][]
            memory componentValues = new AugmentComponentValue[][](1);
        componentValues[0] = new AugmentComponentValue[](2);

        {
            (
                bytes memory staticData,
                PackedCounter encodedLengths,
                bytes memory dynamicData
            ) = ScaleCom.encode(1, 2, 3);
            componentValues[0][0] = AugmentComponentValue(
                staticData,
                encodedLengths,
                dynamicData
            );
        }

        {
            (
                bytes memory staticData,
                PackedCounter encodedLengths,
                bytes memory dynamicData
            ) = NameCom.encode("test");
            componentValues[0][1] = AugmentComponentValue(
                staticData,
                encodedLengths,
                dynamicData
            );
        }

        vm.startPrank(address(0x1));
        world.installAugment(
            mockAugment,
            testNamespace,
            abi.encode(componentValues)
        );
        vm.stopPrank();

        ResourceId _scaleTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("ScaleCom"))
                )
            )
        );
        ResourceId _nameTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("NameCom"))
                )
            )
        );
        uint256 entityId = uint256(getUniqueEntity(world)) - 1;

        assertEq(
            ScaleCom.getX(world, _scaleTableId, bytes32(entityId)),
            1,
            "Scale X should be set"
        );
        assertEq(
            ScaleCom.getY(world, _scaleTableId, bytes32(entityId)),
            2,
            "Scale Y should be set"
        );
        assertEq(
            ScaleCom.getZ(world, _scaleTableId, bytes32(entityId)),
            3,
            "Scale Z should be set"
        );
        assertEq(
            NameCom.get(world, _nameTableId, bytes32(entityId)),
            "test",
            "Name should be set"
        );
        assertEq(
            Augments.get(
                world,
                AugmentInstallationLib.getAugmentsTableId(
                    WorldResourceIdLib.encodeNamespace(bytes14("world"))
                ),
                address(mockAugment),
                keccak256(abi.encode(componentValues))
            ),
            mockAugment.getMetadataURI(),
            "Augment should be installed"
        );
    }

    function testInstallAugment_MultipleEntities() public {
        MockAugmentMultipleEntities mockAugment = new MockAugmentMultipleEntities();

        AugmentComponentValue[][]
            memory componentValues = new AugmentComponentValue[][](2);

        {
            (
                bytes memory staticData,
                PackedCounter encodedLengths,
                bytes memory dynamicData
            ) = ScaleCom.encode(1, 2, 3);
            componentValues[0] = new AugmentComponentValue[](1);
            componentValues[0][0] = AugmentComponentValue(
                staticData,
                encodedLengths,
                dynamicData
            );
        }

        {
            (
                bytes memory staticData,
                PackedCounter encodedLengths,
                bytes memory dynamicData
            ) = NameCom.encode("test");
            componentValues[1] = new AugmentComponentValue[](1);
            componentValues[1][0] = AugmentComponentValue(
                staticData,
                encodedLengths,
                dynamicData
            );
        }

        vm.startPrank(address(0x1));
        world.installAugment(
            mockAugment,
            testNamespace,
            abi.encode(componentValues)
        );
        vm.stopPrank();

        ResourceId _scaleTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("ScaleCom"))
                )
            )
        );
        ResourceId _nameTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("NameCom"))
                )
            )
        );
        uint256 entityId1 = uint256(getUniqueEntity(world)) - 2;
        uint256 entityId2 = entityId1 + 1;

        assertEq(
            ScaleCom.getX(world, _scaleTableId, bytes32(entityId1)),
            1,
            "Scale X should be set"
        );
        assertEq(
            ScaleCom.getY(world, _scaleTableId, bytes32(entityId1)),
            2,
            "Scale Y should be set"
        );
        assertEq(
            ScaleCom.getZ(world, _scaleTableId, bytes32(entityId1)),
            3,
            "Scale Z should be set"
        );
        assertEq(
            NameCom.get(world, _nameTableId, bytes32(entityId2)),
            "test",
            "Name should be set"
        );
        assertEq(
            Augments.get(
                world,
                AugmentInstallationLib.getAugmentsTableId(
                    WorldResourceIdLib.encodeNamespace(bytes14("world"))
                ),
                address(mockAugment),
                keccak256(abi.encode(componentValues))
            ),
            mockAugment.getMetadataURI(),
            "Augment should be installed"
        );
    }

    function testInstallAugment_SetOverride() public {
        MockAugmentSetOverride mockAugment = new MockAugmentSetOverride();

        AugmentComponentValue[][]
            memory componentValues = new AugmentComponentValue[][](1);

        (
            bytes memory staticData,
            PackedCounter encodedLengths,
            bytes memory dynamicData
        ) = ScaleCom.encode(1, 2, 3);
        componentValues[0] = new AugmentComponentValue[](1);
        componentValues[0][0] = AugmentComponentValue(
            staticData,
            encodedLengths,
            dynamicData
        );

        vm.startPrank(address(0x1));
        world.grantAccess(
            WorldResourceIdLib.encodeNamespace(testNamespace),
            address(mockAugment)
        );
        world.installAugment(
            mockAugment,
            testNamespace,
            abi.encode(componentValues)
        );
        world.revokeAccess(
            WorldResourceIdLib.encodeNamespace(testNamespace),
            address(mockAugment)
        );
        vm.stopPrank();

        ResourceId _scaleTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("ScaleCom"))
                )
            )
        );
        ResourceId _nameTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("NameCom"))
                )
            )
        );
        uint256 entityId1 = uint256(getUniqueEntity(world)) - 2;
        uint256 entityId2 = entityId1 + 1;

        assertEq(
            ScaleCom.getX(world, _scaleTableId, bytes32(entityId1)),
            1,
            "Scale X should be set"
        );
        assertEq(
            ScaleCom.getY(world, _scaleTableId, bytes32(entityId1)),
            2,
            "Scale Y should be set"
        );
        assertEq(
            ScaleCom.getZ(world, _scaleTableId, bytes32(entityId1)),
            3,
            "Scale Z should be set"
        );
        assertEq(
            NameCom.get(world, _nameTableId, bytes32(entityId2)),
            "test1",
            "Name should be set"
        );
        assertEq(
            Augments.get(
                world,
                AugmentInstallationLib.getAugmentsTableId(
                    WorldResourceIdLib.encodeNamespace(bytes14("world"))
                ),
                address(mockAugment),
                keccak256(abi.encode(componentValues))
            ),
            mockAugment.getMetadataURI(),
            "Augment should be installed"
        );
    }

    function testInstallAugment_SpliceOverride() public {
        MockAugmentSpliceOverride mockAugment = new MockAugmentSpliceOverride();

        AugmentComponentValue[][]
            memory componentValues = new AugmentComponentValue[][](1);

        (
            bytes memory staticData,
            PackedCounter encodedLengths,
            bytes memory dynamicData
        ) = ScaleCom.encode(1, 2, 3);
        componentValues[0] = new AugmentComponentValue[](1);
        componentValues[0][0] = AugmentComponentValue(
            staticData,
            encodedLengths,
            dynamicData
        );

        vm.startPrank(address(0x1));
        world.grantAccess(
            WorldResourceIdLib.encodeNamespace(testNamespace),
            address(mockAugment)
        );
        world.installAugment(
            mockAugment,
            testNamespace,
            abi.encode(componentValues)
        );
        world.revokeAccess(
            WorldResourceIdLib.encodeNamespace(testNamespace),
            address(mockAugment)
        );
        vm.stopPrank();

        ResourceId _scaleTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("ScaleCom"))
                )
            )
        );

        uint256 entityId1 = UniqueEntity.get(UNIQUE_ENTITY_TABLE_ID);

        assertEq(
            ScaleCom.getX(world, _scaleTableId, bytes32(entityId1)),
            10,
            "Scale X should be set"
        );
        assertEq(
            ScaleCom.getY(world, _scaleTableId, bytes32(entityId1)),
            2,
            "Scale Y should be set"
        );
        assertEq(
            ScaleCom.getZ(world, _scaleTableId, bytes32(entityId1)),
            3,
            "Scale Z should be set"
        );
        assertEq(
            Augments.get(
                world,
                AugmentInstallationLib.getAugmentsTableId(
                    WorldResourceIdLib.encodeNamespace(bytes14("world"))
                ),
                address(mockAugment),
                keccak256(abi.encode(componentValues))
            ),
            mockAugment.getMetadataURI(),
            "Augment should be installed"
        );
    }

    function test_CannotInstallWithoutPermission() public {
        MockAugmentSingle mockAugment = new MockAugmentSingle();

        (
            bytes memory staticData,
            PackedCounter encodedLengths,
            bytes memory dynamicData
        ) = ScaleCom.encode(1, 2, 3);

        AugmentComponentValue memory componentValue = AugmentComponentValue({
            staticData: staticData,
            encodedLengths: encodedLengths,
            dynamicData: dynamicData
        });
        AugmentComponentValue[][]
            memory componentValues = new AugmentComponentValue[][](1);
        componentValues[0] = new AugmentComponentValue[](1);
        componentValues[0][0] = componentValue;

        vm.startPrank(address(0x2));
        vm.expectRevert(
            abi.encodeWithSelector(
                IWorldErrors.World_AccessDenied.selector,
                WorldResourceIdInstance.toString(
                    WorldResourceIdLib.encodeNamespace(testNamespace)
                ),
                address(0x2)
            )
        );
        world.installAugment(
            mockAugment,
            testNamespace,
            abi.encode(componentValues)
        );
        vm.stopPrank();
    }
}

contract MockAugmentSingle is Augment {
    bytes16[][] private componentTypes = [[bytes16(bytes32("ScaleCom"))]];

    function getMetadataURI() external view returns (bytes memory) {
        return new bytes(0);
    }

    function getComponentTypes() external view returns (bytes16[][] memory) {
        return componentTypes;
    }

    function performOverrides(bytes14 namespace) external {}
}

contract MockAugmentMultipleComponents is Augment {
    bytes16[][] private componentTypes = [
        [bytes16(bytes32("ScaleCom")), bytes16(bytes32("NameCom"))]
    ];

    function getMetadataURI() external view returns (bytes memory) {
        return new bytes(0);
    }

    function getComponentTypes() external view returns (bytes16[][] memory) {
        return componentTypes;
    }

    function performOverrides(bytes14 namespace) external {}
}

contract MockAugmentMultipleEntities is Augment {
    bytes16[][] private componentTypes = [
        [bytes16(bytes32("ScaleCom"))],
        [bytes16(bytes32("NameCom"))]
    ];

    function getMetadataURI() external view returns (bytes memory) {
        return new bytes(0);
    }

    function getComponentTypes() external view returns (bytes16[][] memory) {
        return componentTypes;
    }

    function performOverrides(bytes14 namespace) external {}
}

contract MockAugmentSetOverride is Augment {
    bytes16[][] private componentTypes = [[bytes16(bytes32("ScaleCom"))]];

    function getMetadataURI() external view returns (bytes memory) {
        return new bytes(0);
    }

    function getComponentTypes() external view returns (bytes16[][] memory) {
        return componentTypes;
    }

    function performOverrides(bytes14 namespace) external {
        bytes32 key = getUniqueEntity();

        ResourceId _nameTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    namespace,
                    bytes16(bytes32("NameCom"))
                )
            )
        );
        NameCom.set(IWorld(_world()), _nameTableId, key, "test1");
    }
}

contract MockAugmentSpliceOverride is Augment {
    bytes16[][] private componentTypes = [[bytes16(bytes32("ScaleCom"))]];

    function getMetadataURI() external view returns (bytes memory) {
        return new bytes(0);
    }

    function getComponentTypes() external view returns (bytes16[][] memory) {
        return componentTypes;
    }

    function performOverrides(bytes14 namespace) external {
        uint256 keyOffset = UniqueEntity.get(UNIQUE_ENTITY_TABLE_ID) -
            componentTypes.length;

        bytes32 key1 = bytes32(keyOffset + 1);

        ResourceId _nameTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    namespace,
                    bytes16(bytes32("ScaleCom"))
                )
            )
        );
        ScaleCom.setX(IWorld(_world()), _nameTableId, key1, 10);
    }
}
