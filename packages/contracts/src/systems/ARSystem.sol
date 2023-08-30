// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {System} from "@latticexyz/world/src/System.sol";
import {getUniqueEntity} from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import {IsAnchorComponent, AnchorComponent, AnchorComponentData, Model3DComponent, PositionComponent, PositionComponentData, ScaleComponent, ScaleComponentData, OrientationComponent, OrientationComponentData} from "../codegen/Tables.sol";

contract ARSystem is System {
    /**
     * @notice - Add new anchor
     **/
    function addNewAnchor(
        PositionComponentData memory positionData
    ) public returns (bytes32 key) {
        key = getUniqueEntity();

        PositionComponent.set(key, positionData);
        IsAnchorComponent.set(key, true);
    }

    /**
     * @notice - Add new object
     **/
    function addNewObject(
        bytes32 anchor,
        bytes memory usdz
    ) public returns (bytes32 key) {
        key = getUniqueEntity();

        AnchorComponent.setAnchor(key, anchor);
        Model3DComponent.set(key, usdz);
    }
}
