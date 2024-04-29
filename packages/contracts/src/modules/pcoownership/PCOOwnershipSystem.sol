// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {System} from "@latticexyz/world/src/System.sol";
import {PCOOwnership, PCOOwnershipData} from "./tables/PCOOwnership.sol";
import {ResourceId, WorldResourceIdLib} from "@latticexyz/world/src/WorldResourceId.sol";
import {IBaseWorld} from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import {TABLE_ID} from "./constants.sol";
import {RESOURCE_SYSTEM, REGISTRATION_SYSTEM_ID} from "@latticexyz/world/src/modules/init/constants.sol";
import {Systems} from "@latticexyz/world/src/codegen/tables/Systems.sol";
import {WorldRegistrationSystem} from "@latticexyz/world/src/modules/init/implementations/WorldRegistrationSystem.sol";
import {revertWithBytes} from "@latticexyz/world/src/revertWithBytes.sol";
import {ResourceAccess} from "@latticexyz/world/src/codegen/tables/ResourceAccess.sol";
import {NamespaceOwner} from "@latticexyz/world/src/codegen/tables/NamespaceOwner.sol";
import {AugmentInstallSystem, AugmentInstallLib} from "../augmentinstall/AugmentInstallSystem.sol";
import {Augments} from "../augmentinstall/tables/Augments.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {SystemSwitch} from "@latticexyz/world-modules/src/utils/SystemSwitch.sol";

contract PCOOwnershipSystem is System {
    AugmentInstallSystem private immutable augmentInstallSystem =
        new AugmentInstallSystem();

    function getNamespaceForParcel(
        uint256 parcelId
    ) public pure returns (bytes14) {
        string memory parcelStr = Strings.toString(parcelId);
        return bytes14(bytes(parcelStr));
    }

    function getNamespaceIdForParcel(
        uint256 parcelId
    ) public pure returns (ResourceId) {
        return
            WorldResourceIdLib.encodeNamespace(getNamespaceForParcel(parcelId));
    }

    function getAugmentInstallSystemResource(
        bytes14 namespace
    ) public pure returns (ResourceId) {
        return
            WorldResourceIdLib.encode(
                RESOURCE_SYSTEM,
                namespace,
                "AugmentInstall"
            );
    }

    function registerParcelNamespace(uint256 parcelId) public {
        bytes14 namespace = getNamespaceForParcel(parcelId);
        ResourceId namespaceId = getNamespaceIdForParcel(parcelId);

        // Set PCOOwnership hash
        PCOOwnership._set(
            TABLE_ID,
            namespaceId,
            PCOOwnershipData({exists: true, parcelId: parcelId})
        );

        // Register namespace
        SystemSwitch.call(
            abi.encodeCall(
                WorldRegistrationSystem.registerNamespace,
                (namespaceId)
            )
        );

        // Register AugmentInstallationSystem
        ResourceId systemResource = getAugmentInstallSystemResource(namespace);
        SystemSwitch.call(
            abi.encodeCall(
                WorldRegistrationSystem.registerSystem,
                (systemResource, augmentInstallSystem, false)
            )
        );
        SystemSwitch.call(
            abi.encodeCall(
                WorldRegistrationSystem.registerFunctionSelector,
                (systemResource, "installAugment(IAugment,bytes)")
            )
        );
        SystemSwitch.call(
            abi.encodeCall(
                WorldRegistrationSystem.registerFunctionSelector,
                (systemResource, "updateAugment(bytes32,bytes)")
            )
        );
        SystemSwitch.call(
            abi.encodeCall(
                WorldRegistrationSystem.registerFunctionSelector,
                (systemResource, "uninstallAugment(bytes32)")
            )
        );

        // Register Augments table
        ResourceId augmentsTableId = AugmentInstallLib.getAugmentsTableId(
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
