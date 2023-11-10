// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ModelAugment.sol";
import {IWorld} from "@geo-web/mud-world-base-contracts/src/codegen/world/IWorld.sol";
import {AugmentComponentValue} from "@geo-web/mud-world-base-contracts/src/modules/augmentinstallation/AugmentInstallationSystem.sol";
import {NameCom, ModelCom} from "@geo-web/mud-world-base-contracts/src/codegen/index.sol";
import {ModelEncodingFormat} from "@geo-web/mud-world-base-contracts/src/codegen/common.sol";
import {PackedCounter} from "@latticexyz/store/src/PackedCounter.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ResourceId, WorldResourceIdLib, WorldResourceIdInstance} from "@latticexyz/world/src/WorldResourceId.sol";
import {RESOURCE_TABLE} from "@latticexyz/world/src/worldResourceTypes.sol";
import "forge-std/console.sol";
import {IAugment} from "@geo-web/mud-world-base-contracts/src/modules/augmentinstallation/IAugment.sol";
import {NameCom, ModelCom, PositionCom, OrientationCom, ScaleCom} from "@geo-web/mud-world-base-contracts/src/codegen/index.sol";

contract InstallAugment is Script {
    ModelAugment modelAugment =
        ModelAugment(0x0c2819e12c930089D0F563467Fa6af4f87563019);

    IWorld world = IWorld(0x22D33a1d6A772B88C557C4e243F2f949935d35E1);

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        AugmentComponentValue[][]
            memory componentValues = new AugmentComponentValue[][](1);
        componentValues[0] = new AugmentComponentValue[](5);

        // Create ModelAugment
        {
            (
                bytes memory staticData,
                PackedCounter encodedLengths,
                bytes memory dynamicData
            ) = ModelCom.encode(
                    ModelEncodingFormat.Glb,
                    "ipfs://bafkreihqnpefxdmb7xtxq7hmgiim3dbgony2s43zf7kqixzipvd5pgbeja"
                );

            componentValues[0][0] = AugmentComponentValue({
                staticData: staticData,
                encodedLengths: encodedLengths,
                dynamicData: dynamicData
            });
        }
        {
            (
                bytes memory staticData,
                PackedCounter encodedLengths,
                bytes memory dynamicData
            ) = NameCom.encode("Robot");

            componentValues[0][1] = AugmentComponentValue({
                staticData: staticData,
                encodedLengths: encodedLengths,
                dynamicData: dynamicData
            });
        }
        {
            (
                bytes memory staticData,
                PackedCounter encodedLengths,
                bytes memory dynamicData
            ) = PositionCom.encode(2000, hex"309f54ef7d784c");

            componentValues[0][2] = AugmentComponentValue({
                staticData: staticData,
                encodedLengths: encodedLengths,
                dynamicData: dynamicData
            });
        }
        {
            (
                bytes memory staticData,
                PackedCounter encodedLengths,
                bytes memory dynamicData
            ) = OrientationCom.encode(0, 0, 0, 0);

            componentValues[0][3] = AugmentComponentValue({
                staticData: staticData,
                encodedLengths: encodedLengths,
                dynamicData: dynamicData
            });
        }

        {
            (
                bytes memory staticData,
                PackedCounter encodedLengths,
                bytes memory dynamicData
            ) = ScaleCom.encode(1, 1, 1);

            componentValues[0][4] = AugmentComponentValue({
                staticData: staticData,
                encodedLengths: encodedLengths,
                dynamicData: dynamicData
            });
        }

        string memory parcelStr = Strings.toString(uint256(320));
        bytes14 parcelNamespace = bytes14(bytes(parcelStr));

        world.grantAccess(
            WorldResourceIdLib.encodeNamespace(parcelNamespace),
            address(modelAugment)
        );
        world.installAugment(
            modelAugment,
            parcelNamespace,
            abi.encode(componentValues)
        );
        world.revokeAccess(
            WorldResourceIdLib.encodeNamespace(parcelNamespace),
            address(modelAugment)
        );

        vm.stopBroadcast();
    }
}
