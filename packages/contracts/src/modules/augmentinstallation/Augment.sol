// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {IERC165, ERC165_INTERFACE_ID} from "@latticexyz/world/src/IERC165.sol";
import {IAugment, AUGMENT_INTERFACE_ID} from "./IAugment.sol";

/**
 * @title Augment
 * @dev Abstract contract that implements the ERC-165 supportsInterface function for IAugment.
 */
abstract contract Augment is IAugment {
    /**
     * @notice Checks if the given interfaceId is supported by this contract.
     * @dev Overrides the functionality from IERC165 to check for supported interfaces.
     * @param interfaceId The bytes4 identifier for the interface.
     * @return true if the interface is supported, false otherwise.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public pure virtual override(IERC165) returns (bool) {
        return
            interfaceId == AUGMENT_INTERFACE_ID ||
            interfaceId == ERC165_INTERFACE_ID;
    }
}
