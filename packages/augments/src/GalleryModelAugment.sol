// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {Augment} from "@geo-web/mud-world-base-contracts/src/modules/augmentinstallation/Augment.sol";

contract GalleryModelAugment is Augment {
    bytes16[][] private componentTypes = [
        [bytes16("ModelCom"), bytes16("NameCom")]
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
