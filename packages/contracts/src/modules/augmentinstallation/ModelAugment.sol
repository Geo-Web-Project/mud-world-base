// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {Augment} from "./Augment.sol";

contract ModelAugment is Augment {
    bytes16[][] private componentTypes = [
        [
            bytes16(bytes32("ModelComponent")),
            bytes16(bytes32("PositionComponent")),
            bytes16(bytes32("OrientationQuaternionComponent")),
            bytes16(bytes32("ScaleComponent"))
        ]
    ];

    function getName() external view returns (bytes16) {
        return bytes16("ModelAugment");
    }

    function getIcon() external view returns (bytes memory) {
        return new bytes(0);
    }

    function getTypes() external view returns (bytes16[][] memory) {
        return componentTypes;
    }

    function performOverrides(bytes14 namespace) external {}
}
