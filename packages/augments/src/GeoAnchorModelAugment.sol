// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {Augment} from "@geo-web/mud-world-base-contracts/src/modules/augmentinstall/Augment.sol";
import {IStore} from "@latticexyz/store/src/IStore.sol";
import {ResourceId} from "@latticexyz/world/src/WorldResourceId.sol";
import {RESOURCE_TABLE} from "@latticexyz/world/src/worldResourceTypes.sol";
import {GeoAnchorCom, GeoAnchorComData, PositionCom} from "@geo-web/mud-world-base-contracts/src/codegen/index.sol";

contract GeoAnchorModelAugment is Augment {
    bytes16[] private components = [
        bytes16("GeoAnchorCom"),
        bytes16("ModelCom"),
        bytes16("NameCom"),
        bytes16("PositionCom"),
        bytes16("OrientationCom"),
        bytes16("ScaleCom")
    ];

    bytes16[][] private componentTypes = [
        [
            bytes16("ModelCom"),
            bytes16("NameCom"),
            bytes16("GeoAnchorCom"),
            bytes16("OrientationCom"),
            bytes16("ScaleCom")
        ]
    ];

    function onBeforeInstall(IStore store, bytes14 namespace) external {}

    function getMetadataURI() external pure returns (string memory) {
        return "";
    }

    function getComponentTypes() external view returns (bytes16[][] memory) {
        return componentTypes;
    }

    function getRequiredComponents() external view returns (bytes16[] memory) {
        return components;
    }

    function getRequiredOverrideComponents()
        external
        pure
        returns (bytes16[] memory)
    {
        return new bytes16[](0);
    }

    function installOverrides(
        IStore store,
        bytes14 namespace,
        bytes32 keyOffset
    ) external {
        // Set PositionCom to same coordinate as GeoAnchorCom
        ResourceId _geoAnchorTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    namespace,
                    bytes16(bytes32("GeoAnchorCom"))
                )
            )
        );
        ResourceId _positionTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    namespace,
                    bytes16(bytes32("PositionCom"))
                )
            )
        );

        GeoAnchorComData memory geoAnchor = GeoAnchorCom.get(
            store,
            _geoAnchorTableId,
            keyOffset
        );

        PositionCom.set(
            store,
            _positionTableId,
            keyOffset,
            geoAnchor.h,
            geoAnchor.geohash
        );
    }

    function uninstallOverrides(
        IStore store,
        bytes14 namespace,
        bytes32 keyOffset
    ) external {}
}
