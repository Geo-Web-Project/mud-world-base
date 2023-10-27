// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Augment} from "@geo-web/mud-world-base-contracts/src/modules/augmentinstallation/Augment.sol";
import {ImageCom, AudioCom, NFTCom, ModelCom} from "@geo-web/mud-world-base-contracts/src/codegen/index.sol";
import {IWorld} from "@geo-web/mud-world-base-contracts/src/codegen/world/IWorld.sol";
import {getUniqueEntity} from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";
import {ResourceId} from "@latticexyz/world/src/WorldResourceId.sol";
import {RESOURCE_TABLE} from "@latticexyz/world/src/worldResourceTypes.sol";

contract NFTAugmentTemplate is Augment {
    enum NFTType {
        Image,
        Audio,
        Model
    }

    bytes16[][] private componentTypes;

    NFTType immutable nftType;
    uint64 immutable chainId;
    address immutable tokenAddress;
    uint256 immutable tokenId;

    constructor(
        NFTType nftType_,
        uint64 chainId_,
        address tokenAddress_,
        uint256 tokenId_
    ) {
        nftType = nftType_;
        chainId = chainId_;
        tokenAddress = tokenAddress_;
        tokenId = tokenId_;

        bytes16 contentCom;
        if (nftType == NFTType.Image) {
            contentCom = bytes16("ImageCom");
        } else if (nftType == NFTType.Audio) {
            contentCom = bytes16("AudioCom");
        } else {
            contentCom = bytes16("ModelCom");
        }
        componentTypes = [
            [contentCom, bytes16("PositionCom"), bytes16("OrientationCom")]
        ];
    }

    function getMetadataURI() external pure returns (bytes memory) {
        return new bytes(0);
    }

    function getComponentTypes() external view returns (bytes16[][] memory) {
        return componentTypes;
    }

    function performOverrides(bytes14 namespace) external {
        bytes32 key = getUniqueEntity();

        // Add NFTCom
        ResourceId _nftTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    namespace,
                    bytes16(bytes32("NFTCom"))
                )
            )
        );
        NFTCom.set(
            IWorld(_world()),
            _nftTableId,
            key,
            chainId,
            tokenAddress,
            tokenId
        );

        // Content should be empty
        if (nftType == NFTType.Image) {
            ResourceId _imageTableId = ResourceId.wrap(
                bytes32(
                    abi.encodePacked(
                        RESOURCE_TABLE,
                        namespace,
                        bytes16(bytes32("ImageCom"))
                    )
                )
            );
            ImageCom.setContentHash(
                IWorld(_world()),
                _imageTableId,
                key,
                new bytes(0)
            );
        } else if (nftType == NFTType.Audio) {
            ResourceId _audioTableId = ResourceId.wrap(
                bytes32(
                    abi.encodePacked(
                        RESOURCE_TABLE,
                        namespace,
                        bytes16(bytes32("AudioCom"))
                    )
                )
            );
            AudioCom.setContentHash(
                IWorld(_world()),
                _audioTableId,
                key,
                new bytes(0)
            );
        } else {
            ResourceId _modelTableId = ResourceId.wrap(
                bytes32(
                    abi.encodePacked(
                        RESOURCE_TABLE,
                        namespace,
                        bytes16(bytes32("ModelCom"))
                    )
                )
            );
            ModelCom.setContentHash(
                IWorld(_world()),
                _modelTableId,
                key,
                new bytes(0)
            );
        }
    }
}
