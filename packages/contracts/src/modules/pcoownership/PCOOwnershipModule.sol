// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {Module} from "@latticexyz/world/src/Module.sol";
import {ResourceId} from "@latticexyz/world/src/WorldResourceId.sol";
import {BEFORE_SET_RECORD, BEFORE_DELETE_RECORD, BEFORE_SPLICE_STATIC_DATA} from "@latticexyz/store/src/storeHookTypes.sol";
import {RESOURCE_TABLE} from "@latticexyz/store/src/storeResourceTypes.sol";
import {PCOOwnershipHook} from "./PCOOwnershipHook.sol";
import {IBaseWorld} from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import {IStoreHook} from "@latticexyz/store/src/IStoreHook.sol";

contract PCOOwnershipModule is Module {
    ResourceId constant _namespaceOwnerTableId =
        ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    bytes14("world"),
                    bytes16("NamespaceOwner")
                )
            )
        );

    function getName() public pure returns (bytes16) {
        return bytes16("pcoOwnership");
    }

    function installRoot(bytes memory args) public override {
        // Deploy hook
        address pcoLicense = abi.decode(args, (address));
        IStoreHook hook = new PCOOwnershipHook(pcoLicense);

        IBaseWorld world = IBaseWorld(_world());

        // Initialize variable to reuse in low level calls
        bool success;
        bytes memory returnData;

        // Register a hook that is called when a value is set in the source table
        (success, returnData) = address(world).delegatecall(
            abi.encodeCall(
                world.registerStoreHook,
                (
                    _namespaceOwnerTableId,
                    hook,
                    BEFORE_SET_RECORD |
                        BEFORE_SPLICE_STATIC_DATA |
                        BEFORE_DELETE_RECORD
                )
            )
        );
    }

    function install(bytes memory) public pure {
        revert Module_NonRootInstallNotSupported();
    }
}
