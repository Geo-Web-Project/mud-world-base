// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import "forge-std/Script.sol";
// import "../src/ImageAugment.sol";
// import {IWorld} from "@geo-web/mud-world-base-contracts/src/codegen/world/IWorld.sol";
// import {AugmentComponentValue} from "@geo-web/mud-world-base-contracts/src/modules/augmentinstallation/AugmentInstallationSystem.sol";
// import {NameCom, ImageCom} from "@geo-web/mud-world-base-contracts/src/codegen/index.sol";
// import {ImageEncodingFormat} from "@geo-web/mud-world-base-contracts/src/codegen/common.sol";
// import {PackedCounter} from "@latticexyz/store/src/PackedCounter.sol";
// import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
// import {ResourceId, WorldResourceIdLib, WorldResourceIdInstance} from "@latticexyz/world/src/WorldResourceId.sol";
// import {RESOURCE_TABLE} from "@latticexyz/world/src/worldResourceTypes.sol";
// import "forge-std/console.sol";
// import {IAugment} from "@geo-web/mud-world-base-contracts/src/modules/augmentinstallation/IAugment.sol";
// import {NameCom, ImageCom, PositionCom, OrientationCom, ScaleCom} from "@geo-web/mud-world-base-contracts/src/codegen/index.sol";

// contract InstallImageAugment is Script {
//     ImageAugment imageAugment =
//         ImageAugment(0x31897D284D8D7FD36335E5bc284af682d8174e31);

//     IWorld world = IWorld(0x3904285496739BF5030d79C0CF259A569806F759);

//     function run() external {
//         uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
//         vm.startBroadcast(deployerPrivateKey);

//         AugmentComponentValue[][]
//             memory componentValues = new AugmentComponentValue[][](1);
//         componentValues[0] = new AugmentComponentValue[](5);

//         // Create ImageAugment
//         {
//             (
//                 bytes memory staticData,
//                 PackedCounter encodedLengths,
//                 bytes memory dynamicData
//             ) = ImageCom.encode(
//                     ImageEncodingFormat.Jpeg,
//                     500,
//                     "ipfs://QmNiCFEQ8JeLjKW6UP2FDP3N7jU4RAGvZfPXExxMxjj5nd"
//                 );

//             componentValues[0][0] = AugmentComponentValue({
//                 staticData: staticData,
//                 encodedLengths: encodedLengths,
//                 dynamicData: dynamicData
//             });
//         }
//         {
//             (
//                 bytes memory staticData,
//                 PackedCounter encodedLengths,
//                 bytes memory dynamicData
//             ) = NameCom.encode("Lake");

//             componentValues[0][1] = AugmentComponentValue({
//                 staticData: staticData,
//                 encodedLengths: encodedLengths,
//                 dynamicData: dynamicData
//             });
//         }
//         {
//             (
//                 bytes memory staticData,
//                 PackedCounter encodedLengths,
//                 bytes memory dynamicData
//             ) = PositionCom.encode(1000, "dr72hbyjx00");

//             componentValues[0][2] = AugmentComponentValue({
//                 staticData: staticData,
//                 encodedLengths: encodedLengths,
//                 dynamicData: dynamicData
//             });
//         }
//         {
//             (
//                 bytes memory staticData,
//                 PackedCounter encodedLengths,
//                 bytes memory dynamicData
//             ) = OrientationCom.encode(0, 0, 0, 0);

//             componentValues[0][3] = AugmentComponentValue({
//                 staticData: staticData,
//                 encodedLengths: encodedLengths,
//                 dynamicData: dynamicData
//             });
//         }

//         {
//             (
//                 bytes memory staticData,
//                 PackedCounter encodedLengths,
//                 bytes memory dynamicData
//             ) = ScaleCom.encode(1, 1, 1);

//             componentValues[0][4] = AugmentComponentValue({
//                 staticData: staticData,
//                 encodedLengths: encodedLengths,
//                 dynamicData: dynamicData
//             });
//         }

//         string memory parcelStr = Strings.toString(uint256(320));
//         bytes14 parcelNamespace = bytes14(bytes(parcelStr));

//         world.grantAccess(
//             WorldResourceIdLib.encodeNamespace(parcelNamespace),
//             address(imageAugment)
//         );
//         world.installAugment(
//             imageAugment,
//             parcelNamespace,
//             abi.encode(componentValues)
//         );
//         world.revokeAccess(
//             WorldResourceIdLib.encodeNamespace(parcelNamespace),
//             address(imageAugment)
//         );

//         vm.stopBroadcast();
//     }
// }
