// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {System} from "@latticexyz/world/src/System.sol";
import {getUniqueEntity} from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import {AnchorComponent, AnchorComponentData, ModelComponent, ModelComponentData, TrackedImageComponent, TrackedImageComponentData, PositionComponent, PositionComponentData, ScaleComponent, ScaleComponentData, OrientationComponent, OrientationComponentData} from "../codegen/Tables.sol";

contract ARSystem is System {
    /**
     * @notice - Add new image anchor
     **/
    function addImageAnchor(
        TrackedImageComponentData memory trackedImageComponentData
    ) public returns (bytes32 key) {
        key = getUniqueEntity();

        TrackedImageComponent.set(key, trackedImageComponentData);
    }

    /**
     * @notice - Add new object
     **/
    function addAnchoredObject(
        bytes32 anchor,
        ModelComponentData memory modelComponentData
    ) public returns (bytes32 key) {
        key = getUniqueEntity();

        AnchorComponent.setAnchor(key, anchor);
        ModelComponent.set(key, modelComponentData);
    }

    /**
     * @notice - Add new object
     **/
    function addAnchoredObject(
        bytes32 anchor,
        PositionComponentData memory positionComponentData,
        ModelComponentData memory modelComponentData
    ) public returns (bytes32 key) {
        key = getUniqueEntity();

        AnchorComponent.setAnchor(key, anchor);
        PositionComponent.set(key, positionComponentData);
        ModelComponent.set(key, modelComponentData);
    }

    /**
     * @notice - Add new object
     **/
    function addAnchoredObject(
        bytes32 anchor,
        PositionComponentData memory positionComponentData,
        ScaleComponentData memory scaleComponentData,
        OrientationComponentData memory orientationComponentData,
        ModelComponentData memory modelComponentData
    ) public returns (bytes32 key) {
        key = getUniqueEntity();

        AnchorComponent.setAnchor(key, anchor);
        PositionComponent.set(key, positionComponentData);
        ScaleComponent.set(key, scaleComponentData);
        OrientationComponent.set(key, orientationComponentData);
        ModelComponent.set(key, modelComponentData);
    }

    /**
     * @notice - Remove anchor
     **/
    function removeImageAnchor(bytes32 key) public {
        TrackedImageComponent.deleteRecord(key);
    }

    /**
     * @notice - Remove object
     **/
    function removeObject(bytes32 key) public {
        AnchorComponent.deleteRecord(key);
        PositionComponent.deleteRecord(key);
        ScaleComponent.deleteRecord(key);
        OrientationComponent.deleteRecord(key);
        ModelComponent.deleteRecord(key);
    }
}
