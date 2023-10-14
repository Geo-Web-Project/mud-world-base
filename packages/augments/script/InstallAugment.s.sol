// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ModelAugment.sol";
import {IWorld} from "@geo-web/mud-world-base-contracts/src/codegen/world/IWorld.sol";
import {AugmentComponentValue} from "@geo-web/mud-world-base-contracts/src/modules/augmentinstallation/AugmentInstallationSystem.sol";
import {NameComponent, ModelComponent} from "@geo-web/mud-world-base-contracts/src/codegen/index.sol";
import {ModelEncodingFormat} from "@geo-web/mud-world-base-contracts/src/codegen/tables/ModelComponent.sol";
import {PackedCounter} from "@latticexyz/store/src/PackedCounter.sol";

contract InstallAugment is Script {
    ModelAugment modelAugment =
        ModelAugment(0xbECd2b08ef2cfeEE29Ae08147f78870Af9dFC607);

    IWorld world = IWorld(0x2f656242DE26118133F94991257A3B9c02d0831E);

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        AugmentComponentValue[][]
            memory componentValues = new AugmentComponentValue[][](1);
        componentValues[0] = new AugmentComponentValue[](2);

        // Create ModelAugment
        {
            (
                bytes memory staticData,
                PackedCounter encodedLengths,
                bytes memory dynamicData
            ) = NameComponent.encode("Buddha");

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
            ) = ModelComponent.encode(
                    ModelEncodingFormat.Glb,
                    hex"e30101701220ef41de9da4895794034ca1e057762ac36c65057d9566f0c34494fe949a87e349"
                );

            componentValues[0][1] = AugmentComponentValue({
                staticData: staticData,
                encodedLengths: encodedLengths,
                dynamicData: dynamicData
            });
        }

        bytes14 parcelNamespace = bytes14(
            keccak256(abi.encodePacked(uint256(320)))
        );

        world.installAugment(
            modelAugment,
            parcelNamespace,
            abi.encode(componentValues)
        );

        vm.stopBroadcast();
    }
}
