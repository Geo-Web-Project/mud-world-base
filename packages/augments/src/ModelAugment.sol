// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Augment} from "@geo-web/mud-world-base-contracts/src/modules/augmentinstallation/Augment.sol";

contract ModelAugment is Augment {
    bytes16[][] private componentTypes = [
        [bytes16("NameCom"), bytes16("ModelCom")]
    ];

    function getMetadataURI() external view returns (bytes memory) {
        return new bytes(0);
    }

    function getComponentTypes() external view returns (bytes16[][] memory) {
        return componentTypes;
    }

    function performOverrides(bytes14 namespace) external {}
}
