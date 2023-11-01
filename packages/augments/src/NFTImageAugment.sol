// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Augment} from "@geo-web/mud-world-base-contracts/src/modules/augmentinstallation/Augment.sol";
import {ImageCom} from "@geo-web/mud-world-base-contracts/src/codegen/index.sol";
import {IWorld} from "@geo-web/mud-world-base-contracts/src/codegen/world/IWorld.sol";
import {getUniqueEntity} from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";
import {ResourceId} from "@latticexyz/world/src/WorldResourceId.sol";
import {RESOURCE_TABLE} from "@latticexyz/world/src/worldResourceTypes.sol";

contract NFTImageAugment is Augment {
    bytes16[][] private componentTypes = [
        [
            bytes16("NFTCom"),
            bytes16("ImageCom"),
            bytes16("PositionCom"),
            bytes16("OrientationCom")
        ]
    ];

    function getMetadataURI() external pure returns (bytes memory) {
        return new bytes(0);
    }

    function getComponentTypes() external view returns (bytes16[][] memory) {
        return componentTypes;
    }

    function performOverrides(bytes14 namespace) external {
        bytes32 key = getUniqueEntity();

        ResourceId _imageTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    namespace,
                    bytes16(bytes32("ImageCom"))
                )
            )
        );

        ImageCom.set(
            IWorld(_world()),
            _imageTableId,
            key,
            ImageCom.getEncodingFormat(IWorld(_world()), _imageTableId, key),
            ImageCom.getPhysicalWidthInMillimeters(
                IWorld(_world()),
                _imageTableId,
                key
            ),
            new bytes(0)
        );
    }
}
