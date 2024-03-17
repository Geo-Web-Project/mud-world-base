// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.24;

import {Augment} from "@geo-web/mud-world-base-contracts/src/modules/augmentinstallation/Augment.sol";

contract ModelAugment is Augment {
    bytes16[][] private componentTypes = [
        [
            bytes16("ModelCom"),
            bytes16("NameCom"),
            bytes16("PositionCom"),
            bytes16("OrientationCom"),
            bytes16("ScaleCom")
        ]
    ];

    function onBeforeInstall() external {}

    function getMetadataURI() external pure returns (string memory) {
        return "";
    }

    function getComponentTypes() external view returns (bytes16[][] memory) {
        return componentTypes;
    }

    function installOverrides(bytes14 namespace, bytes32 keyOffset) external {}

    function uninstallOverrides(
        bytes14 namespace,
        bytes32 keyOffset
    ) external {}
}
