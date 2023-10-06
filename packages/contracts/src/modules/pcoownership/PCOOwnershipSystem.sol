// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {System} from "@latticexyz/world/src/System.sol";
import {PCOOwnership, PCOOwnershipData} from "./tables/PCOOwnership.sol";
import {ResourceId, WorldResourceIdLib} from "@latticexyz/world/src/WorldResourceId.sol";
import {IBaseWorld} from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import {TABLE_ID} from "./constants.sol";
import {CORE_SYSTEM_ID} from "@latticexyz/world/src/modules/core/constants.sol";
import {Systems} from "@latticexyz/world/src/codegen/tables/Systems.sol";
import {WorldRegistrationSystem} from "@latticexyz/world/src/modules/core/implementations/WorldRegistrationSystem.sol";
import {revertWithBytes} from "@latticexyz/world/src/revertWithBytes.sol";

contract PCOOwnershipSystem is System {
    function registerParcelNamespace(uint256 parcelId) public {
        bytes14 namespace = bytes14(keccak256(abi.encodePacked(parcelId)));
        ResourceId namespaceId = WorldResourceIdLib.encodeNamespace(namespace);

        PCOOwnership._set(
            TABLE_ID,
            namespaceId,
            PCOOwnershipData({exists: true, parcelId: parcelId})
        );

        (address coreSystemAddress, ) = Systems._get(CORE_SYSTEM_ID);
        (bool success, bytes memory data) = coreSystemAddress.delegatecall(
            abi.encodeCall(
                WorldRegistrationSystem.registerNamespace,
                (namespaceId)
            )
        );
        if (!success) revertWithBytes(data);
    }
}
