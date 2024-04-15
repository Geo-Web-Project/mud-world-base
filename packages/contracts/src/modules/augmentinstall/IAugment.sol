// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {IERC165} from "@latticexyz/world/src/IERC165.sol";

interface IAugment is IERC165 {
    /**
     * @notice Run a hook before installation. Can be used to gate access to installing an augment
     */
    function onBeforeInstall() external;

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
     * @notice Install overrides to entities that define this augment.
     * @dev This function should emit Store events to be read by clients.
     * @param keyOffset The key of the first installed entity
     */
    function installOverrides(bytes32 keyOffset) external;

    /**
     * @notice Uninstall overrides to entities that define this augment.
     */
    function uninstallOverrides(bytes32 keyOffset) external;
}
