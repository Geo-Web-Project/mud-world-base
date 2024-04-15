// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {IERC165} from "@latticexyz/world/src/IERC165.sol";
import {IAugment} from "./IAugment.sol";
import {WorldContextConsumer} from "@latticexyz/world/src/WorldContext.sol";

/**
 * @title Augment
 * @dev Abstract contract that implements the ERC-165 supportsInterface function for IAugment.
 */
abstract contract Augment is IAugment, WorldContextConsumer {
    /**
     * @notice Checks if the given interfaceId is supported by this contract.
     * @dev Overrides the functionality from IERC165 to check for supported interfaces.
     * @param interfaceId The bytes4 identifier for the interface.
     * @return true if the interface is supported, false otherwise.
     */
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        pure
        virtual
        override(IERC165, WorldContextConsumer)
        returns (bool)
    {
        return
            interfaceId == type(IAugment).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
}
