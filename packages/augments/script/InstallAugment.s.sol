// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/NFTImageAugment.sol";
import {IWorld} from "@geo-web/mud-world-base-contracts/src/codegen/world/IWorld.sol";
import {AugmentComponentValue} from "@geo-web/mud-world-base-contracts/src/modules/augmentinstallation/AugmentInstallationSystem.sol";
import {NameCom, ModelCom} from "@geo-web/mud-world-base-contracts/src/codegen/index.sol";
import {ImageEncodingFormat} from "@geo-web/mud-world-base-contracts/src/codegen/common.sol";
import {PackedCounter} from "@latticexyz/store/src/PackedCounter.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ResourceId, WorldResourceIdLib, WorldResourceIdInstance} from "@latticexyz/world/src/WorldResourceId.sol";
import {RESOURCE_TABLE} from "@latticexyz/world/src/worldResourceTypes.sol";
import "forge-std/console.sol";
import {IAugment} from "@geo-web/mud-world-base-contracts/src/modules/augmentinstallation/IAugment.sol";
import {ImageCom, AudioCom, NFTCom, ModelCom, PositionCom, OrientationCom} from "@geo-web/mud-world-base-contracts/src/codegen/index.sol";

contract InstallAugment is Script {
    NFTImageAugment nftImageAugment =
        NFTImageAugment(0x0c86026c73723A8228d525EeFA5abb8dF366F579);

    IWorld world = IWorld(0x000a18F809049257BfE86009de80990375475f4c);

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        AugmentComponentValue[][]
            memory componentValues = new AugmentComponentValue[][](1);
        componentValues[0] = new AugmentComponentValue[](4);

        // Create NFTImageAugment
        {
            (
                bytes memory staticData,
                PackedCounter encodedLengths,
                bytes memory dynamicData
            ) = NFTCom.encode(1, 0x518f0C4A832b998ee793D87F0E934467b8b6E587, 4);

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
            ) = ImageCom.encode(ImageEncodingFormat.Jpeg, 1000, new bytes(0));

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

        string memory parcelStr = Strings.toString(uint256(320));
        bytes14 parcelNamespace = bytes14(bytes(parcelStr));

        world.grantAccess(
            WorldResourceIdLib.encodeNamespace(parcelNamespace),
            address(nftImageAugment)
        );
        world.installAugment(
            nftImageAugment,
            parcelNamespace,
            abi.encode(componentValues)
        );
        world.revokeAccess(
            WorldResourceIdLib.encodeNamespace(parcelNamespace),
            address(nftImageAugment)
        );

        vm.stopBroadcast();
    }
}
