// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {System} from "@latticexyz/world/src/System.sol";
import {MediaObject, MediaObjectData} from "../codegen/Tables.sol";
import {MediaObjectType, EncodingFormat} from "../codegen/Types.sol";
import {getUniqueEntity} from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";

contract MediaGallerySystem is System {
    /**
     * @notice - Add to media gallery
     **/
    function addToMediaGallery(
        MediaObjectData memory mediaObjectData
    ) public returns (bytes32 key) {
        key = getUniqueEntity();

        MediaObject.set(key, mediaObjectData);
    }

    /**
     * @notice - Remove from media gallery
     **/
    function removeFromMediaGallery(bytes32 key) public {
        MediaObject.deleteRecord(key);
    }
}
