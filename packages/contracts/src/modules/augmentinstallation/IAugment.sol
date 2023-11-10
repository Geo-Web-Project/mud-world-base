// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {IERC165, ERC165_INTERFACE_ID} from "@latticexyz/world/src/IERC165.sol";

bytes4 constant AUGMENT_INTERFACE_ID = IAugment.getMetadataURI.selector ^
    IAugment.getComponentTypes.selector ^
    IAugment.performOverrides.selector ^
    ERC165_INTERFACE_ID;

interface IAugment is IERC165 {
    /**
     * @notice Return the metadata of the augment.
     * @return metadataURI The URI of the metadata as a content hash
     */
    function getMetadataURI() external view returns (string memory metadataURI);

    /**
     * @notice Return the entity and component types for the augment.
     * @return The types of the augment as a bytes16[][] two dimensional array.
     */
    function getComponentTypes() external view returns (bytes16[][] memory);

    /**
     * @notice Perform overrides to entities that define this augment.
     * @dev This function should emit Store events to be read by clients.
     */
    function performOverrides(bytes14 namespace) external;
}
