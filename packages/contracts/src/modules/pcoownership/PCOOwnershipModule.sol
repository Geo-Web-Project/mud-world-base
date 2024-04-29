// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {Module} from "@latticexyz/world/src/Module.sol";
import {ResourceId, WorldResourceIdInstance} from "@latticexyz/world/src/WorldResourceId.sol";
import {BEFORE_SET_RECORD, BEFORE_DELETE_RECORD, BEFORE_SPLICE_STATIC_DATA} from "@latticexyz/store/src/storeHookTypes.sol";
import {RESOURCE_TABLE, RESOURCE_SYSTEM} from "@latticexyz/world/src/worldResourceTypes.sol";
import {PCOOwnershipHook} from "./PCOOwnershipHook.sol";
import {IBaseWorld} from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import {IStoreHook} from "@latticexyz/store/src/IStoreHook.sol";
import {PCOOwnership} from "./tables/PCOOwnership.sol";
import {PCOOwnershipSystem} from "./PCOOwnershipSystem.sol";
import {revertWithBytes} from "@latticexyz/world/src/revertWithBytes.sol";
import {MODULE_NAME, TABLE_ID, SYSTEM_ID, NAMESPACE_ID} from "./constants.sol";
import {NamespaceOwner} from "@latticexyz/world/src/codegen/tables/NamespaceOwner.sol";
import {AccessControl} from "@latticexyz/world/src/AccessControl.sol";
import {WORLD_NAMESPACE_ID} from "@latticexyz/world/src/constants.sol";

contract PCOOwnershipModule is Module {
    PCOOwnershipSystem private immutable pcoOwnershipSystem =
        new PCOOwnershipSystem();

    function getName() public pure returns (bytes16) {
        return MODULE_NAME;
    }

    function installRoot(bytes memory args) public override {
        // Set world namespace owner
        NamespaceOwner._set(WORLD_NAMESPACE_ID, _msgSender());

        // Deploy hook
        address pcoLicense = abi.decode(args, (address));
        IStoreHook hook = new PCOOwnershipHook(pcoLicense);

        IBaseWorld world = IBaseWorld(_world());

        // Register pcoOwnership namespace
        (bool success, bytes memory returnData) = address(world).delegatecall(
            abi.encodeCall(world.registerNamespace, (NAMESPACE_ID))
        );
        if (!success) revertWithBytes(returnData);

        // Register table
        PCOOwnership._register(TABLE_ID);

        // Register system
        (success, returnData) = address(world).delegatecall(
            abi.encodeCall(
                world.registerSystem,
                (SYSTEM_ID, pcoOwnershipSystem, true)
            )
        );
        if (!success) revertWithBytes(returnData);

        // Register a hook that is called when a value is set in the source table
        (success, returnData) = address(world).delegatecall(
            abi.encodeCall(
                world.registerStoreHook,
                (
                    NamespaceOwner._tableId,
                    hook,
                    BEFORE_SET_RECORD |
                        BEFORE_SPLICE_STATIC_DATA |
                        BEFORE_DELETE_RECORD
                )
            )
        );
        if (!success) revertWithBytes(returnData);
    }

    function install(bytes memory) public pure {
        revert Module_NonRootInstallNotSupported();
    }
}
