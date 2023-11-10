// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Augment} from "@geo-web/mud-world-base-contracts/src/modules/augmentinstallation/Augment.sol";
// import {ImageCom, AudioCom, NFTCom, ModelCom} from "@geo-web/mud-world-base-contracts/src/codegen/index.sol";
// import {ImageEncodingFormat} from "@geo-web/mud-world-base-contracts/src/codegen/common.sol";
// import {IWorld} from "@geo-web/mud-world-base-contracts/src/codegen/world/IWorld.sol";
// import {getUniqueEntity} from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";
// import {ResourceId} from "@latticexyz/world/src/WorldResourceId.sol";
// import {RESOURCE_TABLE} from "@latticexyz/world/src/worldResourceTypes.sol";

// contract NFTAugmentTemplate is Augment {
//     enum NFTType {
//         Image,
//         Audio,
//         Model
//     }

//     bytes16[][] private componentTypes;

//     NFTType immutable nftType;
//     uint64 immutable chainId;
//     address immutable tokenAddress;
//     uint256 immutable tokenId;
//     uint16 physicalWidthInMillimeters;

//     constructor(
//         NFTType nftType_,
//         uint64 chainId_,
//         address tokenAddress_,
//         uint256 tokenId_,
//         uint16 physicalWidthInMillimeters_
//     ) {
//         nftType = nftType_;
//         chainId = chainId_;
//         tokenAddress = tokenAddress_;
//         tokenId = tokenId_;
//         physicalWidthInMillimeters = physicalWidthInMillimeters_;

//         componentTypes = [[bytes16("PositionCom"), bytes16("OrientationCom")]];
//     }

//     function getMetadataURI() external pure returns (bytes memory) {
//         return new bytes(0);
//     }

//     function getComponentTypes() external view returns (bytes16[][] memory) {
//         return componentTypes;
//     }

//     function performOverrides(bytes14 namespace) external {
//         bytes32 key = getUniqueEntity();

//         // Add NFTCom
//         ResourceId _nftTableId = ResourceId.wrap(
//             bytes32(
//                 abi.encodePacked(
//                     RESOURCE_TABLE,
//                     namespace,
//                     bytes16(bytes32("NFTCom"))
//                 )
//             )
//         );
//         NFTCom.set(
//             IWorld(_world()),
//             _nftTableId,
//             key,
//             chainId,
//             tokenAddress,
//             tokenId
//         );

//         // Content should be empty
//         if (nftType == NFTType.Image) {
//             ResourceId _imageTableId = ResourceId.wrap(
//                 bytes32(
//                     abi.encodePacked(
//                         RESOURCE_TABLE,
//                         namespace,
//                         bytes16(bytes32("ImageCom"))
//                     )
//                 )
//             );
//             ImageCom.set(
//                 IWorld(_world()),
//                 _imageTableId,
//                 key,
//                 ImageEncodingFormat.Jpeg,
//                 physicalWidthInMillimeters,
//                 new bytes(0)
//             );
//         }
//     }
// }
