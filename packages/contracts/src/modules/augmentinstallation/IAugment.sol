// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {IERC165, ERC165_INTERFACE_ID} from "@latticexyz/world/src/IERC165.sol";
import {PackedCounter} from "@latticexyz/store/src/PackedCounter.sol";

bytes4 constant AUGMENT_INTERFACE_ID = IAugment.getName.selector ^
    IAugment.getIcon.selector ^
    IAugment.getTypes.selector ^
    ERC165_INTERFACE_ID;

interface IAugment is IERC165 {
    struct ComponentValue {
        bytes staticData;
        PackedCounter encodedLengths;
        bytes dynamicData;
    }

    /**
     * @notice Return the name of the augment.
     * @dev Provides a way to identify the augment by a unique name.
     * @return name The name of the augment as a bytes16.
     */
    function getName() external view returns (bytes16 name);

    /**
     * @notice Returns a content hash referencing the icon of the augment.
     * @return name The content hash of the icon as bytes.
     */
    function getIcon() external view returns (bytes memory);

    /**
     * @notice Return the entity and component types for the augment.
     * @return name The types of the augment as a bytes16[][] two dimensional array.
     */
    function getTypes() external view returns (bytes16[][] memory);

    /**
     * @notice Perform overrides to entities that define this augment.
     * @dev This function should emit Store events to be read by clients.
     */
    function performOverrides(bytes14 namespace) external;
}
