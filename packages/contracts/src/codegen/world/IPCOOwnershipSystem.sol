// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";

/**
 * @title IPCOOwnershipSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IPCOOwnershipSystem {
  function getNamespaceForParcel(uint256 parcelId) external pure returns (bytes14);

  function getNamespaceIdForParcel(uint256 parcelId) external pure returns (ResourceId);

  function getAugmentInstallSystemResource(bytes14 namespace) external pure returns (ResourceId);

  function registerParcelNamespace(uint256 parcelId) external;

  function claimParcelNamespace(uint256 parcelId) external;
}
