// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ModelAugment.sol";
import {IWorld} from "@geo-web/mud-world-base-contracts/src/codegen/world/IWorld.sol";
import {AugmentComponentValue} from "@geo-web/mud-world-base-contracts/src/modules/augmentinstallation/AugmentInstallationSystem.sol";
import {NameCom, ModelCom} from "@geo-web/mud-world-base-contracts/src/codegen/index.sol";
import {ModelEncodingFormat} from "@geo-web/mud-world-base-contracts/src/codegen/tables/ModelCom.sol";
import {PackedCounter} from "@latticexyz/store/src/PackedCounter.sol";

contract InstallAugment is Script {
    ModelAugment modelAugment =
        ModelAugment(0x091FCc7eD8c5457321cb44848E2E0950d717c0be);

    IWorld world = IWorld(0x3F4C6aAe96be19AD74695a64955dE2Ef392e50B2);

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
            ) = NameCom.encode("Buddha");

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
            ) = ModelCom.encode(
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
