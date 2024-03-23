// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {System} from "@latticexyz/world/src/System.sol";
import {PCOOwnership, PCOOwnershipData} from "./tables/PCOOwnership.sol";
import {ResourceId, WorldResourceIdLib} from "@latticexyz/world/src/WorldResourceId.sol";
import {IBaseWorld} from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import {TABLE_ID} from "./constants.sol";
import {REGISTRATION_SYSTEM_ID} from "@latticexyz/world/src/modules/init/constants.sol";
import {Systems} from "@latticexyz/world/src/codegen/tables/Systems.sol";
import {WorldRegistrationSystem} from "@latticexyz/world/src/modules/init/implementations/WorldRegistrationSystem.sol";
import {revertWithBytes} from "@latticexyz/world/src/revertWithBytes.sol";
import {ResourceAccess} from "@latticexyz/world/src/codegen/tables/ResourceAccess.sol";
import {NamespaceOwner} from "@latticexyz/world/src/codegen/tables/NamespaceOwner.sol";
import {AugmentInstallationLib} from "../augmentinstallation/AugmentInstallationSystem.sol";
import {Augments} from "../augmentinstallation/tables/Augments.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract PCOOwnershipSystem is System {
    function getNamespaceIdForParcel(
        uint256 parcelId
    ) public pure returns (ResourceId) {
        string memory parcelStr = Strings.toString(parcelId);
        return WorldResourceIdLib.encodeNamespace(bytes14(bytes(parcelStr)));
    }

    function registerParcelNamespace(uint256 parcelId) public {
        ResourceId namespaceId = getNamespaceIdForParcel(parcelId);

        // Set PCOOwnership hash
        PCOOwnership._set(
            TABLE_ID,
            namespaceId,
            PCOOwnershipData({exists: true, parcelId: parcelId})
        );

        // Register namespace
        (address registrationSystemAddress, ) = Systems._get(
            REGISTRATION_SYSTEM_ID
        );
        (bool success, bytes memory data) = registrationSystemAddress
            .delegatecall(
                abi.encodeCall(
                    WorldRegistrationSystem.registerNamespace,
                    (namespaceId)
                )
            );
        if (!success) revertWithBytes(data);

        // Register Augments table
        ResourceId augmentsTableId = AugmentInstallationLib.getAugmentsTableId(
            namespaceId
        );
        Augments._register(augmentsTableId);
    }

    function claimParcelNamespace(uint256 parcelId) public {
        // Get current namespace owner
        ResourceId namespaceId = getNamespaceIdForParcel(parcelId);
        address oldOwner = NamespaceOwner._get(namespaceId);

        // Set namespace new owner
        NamespaceOwner._set(namespaceId, _msgSender());

        // Revoke access from old owner
        ResourceAccess._deleteRecord(namespaceId, oldOwner);

        // Grant access to new owner
        ResourceAccess._set(namespaceId, _msgSender(), true);
    }
}
