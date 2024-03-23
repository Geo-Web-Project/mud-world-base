// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {StoreHook} from "@latticexyz/store/src/StoreHook.sol";
import {FieldLayout} from "@latticexyz/store/src/FieldLayout.sol";
import {EncodedLengths} from "@latticexyz/store/src/EncodedLengths.sol";
import {ResourceId, WorldResourceIdInstance} from "@latticexyz/world/src/WorldResourceId.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {PCOOwnership} from "./tables/PCOOwnership.sol";
import {TABLE_ID} from "./constants.sol";
import {ResourceIds} from "@latticexyz/store/src/codegen/tables/ResourceIds.sol";
import {NamespaceOwner} from "@latticexyz/world/src/codegen/tables/NamespaceOwner.sol";
import {ROOT_NAMESPACE_ID} from "@latticexyz/world/src/constants.sol";

/**
 * Hook that only allows namespace owner to be changed to the current PCO licensee
 */
contract PCOOwnershipHook is StoreHook {
    error PCOOwnership_NotFound();
    error PCOOwnership_NotPCOOwner();
    error PCOOwnership_CannotDelete();

    IERC721 pcoLicense;

    constructor(address _pcoLicense) {
        pcoLicense = IERC721(_pcoLicense);
    }

    function onBeforeSetRecord(
        ResourceId,
        bytes32[] memory keyTuple,
        bytes memory staticData,
        EncodedLengths,
        bytes memory,
        FieldLayout
    ) public override {
        address allowedOwner = _getAllowedOwner(keyTuple[0]);
        if (address(bytes20(staticData)) != allowedOwner) {
            revert PCOOwnership_NotPCOOwner();
        }
    }

    function onBeforeSpliceStaticData(
        ResourceId,
        bytes32[] memory keyTuple,
        uint48,
        bytes memory data
    ) public override {
        address allowedOwner = _getAllowedOwner(keyTuple[0]);

        if (address(bytes20(data)) != allowedOwner) {
            revert PCOOwnership_NotPCOOwner();
        }
    }

    function onBeforeDeleteRecord(
        ResourceId,
        bytes32[] memory,
        FieldLayout
    ) public override {
        revert PCOOwnership_CannotDelete();
    }

    function _getAllowedOwner(
        bytes32 key
    ) internal view returns (address allowedOwner) {
        ResourceId namespaceId = ResourceId.wrap(key);
        if (PCOOwnership.getExists(TABLE_ID, namespaceId)) {
            uint256 parcelId = PCOOwnership.getParcelId(TABLE_ID, namespaceId);
            allowedOwner = pcoLicense.ownerOf(parcelId);
        } else {
            revert PCOOwnership_NotFound();
        }
    }
}
