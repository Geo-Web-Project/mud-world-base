// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {System} from "@latticexyz/world/src/System.sol";
import {getUniqueEntity} from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import {AnchorComponent, AnchorComponentData, Model3DComponent, TrackedImageComponent, TrackedImageComponentData, PositionComponent, PositionComponentData, ScaleComponent, ScaleComponentData, OrientationComponent, OrientationComponentData} from "../codegen/Tables.sol";

contract ARSystem is System {
    /**
     * @notice - Add new image anchor
     **/
    function addNewImageAnchor(
        TrackedImageComponentData memory trackedImageComponentData
    ) public returns (bytes32 key) {
        key = getUniqueEntity();

        TrackedImageComponent.set(key, trackedImageComponentData);
    }

    /**
     * @notice - Add new object
     **/
    function addNewObject(
        bytes32 anchor,
        PositionComponentData memory positionComponentData,
        ScaleComponentData memory scaleComponentData,
        bytes memory usdz
    ) public returns (bytes32 key) {
        key = getUniqueEntity();

        AnchorComponent.setAnchor(key, anchor);
        PositionComponent.set(key, positionComponentData);
        ScaleComponent.set(key, scaleComponentData);
        Model3DComponent.set(key, usdz);
    }
}
