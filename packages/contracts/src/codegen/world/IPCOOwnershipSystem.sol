// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

/* Autogenerated file. Do not edit manually. */

import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";

/**
 * @title IPCOOwnershipSystem
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IPCOOwnershipSystem {
  function getNamespaceIdForParcel(uint256 parcelId) external view returns (ResourceId);

  function registerParcelNamespace(uint256 parcelId) external;

  function claimParcelNamespace(uint256 parcelId) external;
}
