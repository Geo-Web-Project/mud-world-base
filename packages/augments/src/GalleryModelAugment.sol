// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {Augment} from "@geo-web/mud-world-base-contracts/src/modules/augmentinstall/Augment.sol";
import {IStore} from "@latticexyz/store/src/IStore.sol";

contract GalleryModelAugment is Augment {
    bytes16[] private components = [bytes16("ModelCom"), bytes16("NameCom")];

    bytes16[][] private componentTypes = [
        [bytes16("ModelCom"), bytes16("NameCom")]
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
    ) external {}

    function uninstallOverrides(
        IStore store,
        bytes14 namespace,
        bytes32 keyOffset
    ) external {}
}
