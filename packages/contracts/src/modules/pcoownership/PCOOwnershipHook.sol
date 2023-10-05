// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {StoreHook} from "@latticexyz/store/src/StoreHook.sol";
import {FieldLayout} from "@latticexyz/store/src/FieldLayout.sol";
import {PackedCounter} from "@latticexyz/store/src/PackedCounter.sol";
import {ResourceId} from "@latticexyz/world/src/WorldResourceId.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * Hook that only allows namespace owner to be changed to the current PCO licensee
 */
contract PCOOwnershipHook is StoreHook {
    IERC721 pcoLicense;

    constructor(address _pcoLicense) {
        pcoLicense = IERC721(_pcoLicense);
    }

    function onBeforeSetRecord(
        ResourceId,
        bytes32[] memory keyTuple,
        bytes memory staticData,
        PackedCounter,
        bytes memory,
        FieldLayout
    ) public override {
        uint256 parcelId = uint256(keyTuple[0]);
        address allowedOwner = pcoLicense.ownerOf(parcelId);

        assert(abi.decode(staticData, (address)) == allowedOwner);
    }

    function onBeforeSpliceStaticData(
        ResourceId,
        bytes32[] memory keyTuple,
        uint48,
        bytes memory data
    ) public override {
        uint256 parcelId = uint256(keyTuple[0]);
        address allowedOwner = pcoLicense.ownerOf(parcelId);

        assert(abi.decode(data, (address)) == allowedOwner);
    }

    function onBeforeDeleteRecord(
        ResourceId tableId,
        bytes32[] memory keyTuple,
        FieldLayout fieldLayout
    ) public override {
        uint256 parcelId = uint256(keyTuple[0]);
        address allowedOwner = pcoLicense.ownerOf(parcelId);

        assert(allowedOwner == address(0x0));
    }
}
