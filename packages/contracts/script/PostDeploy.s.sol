// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {IWorld} from "../src/codegen/world/IWorld.sol";
import {PCOOwnershipModule} from "../src/modules/pcoownership/PCOOwnershipModule.sol";

contract PostDeploy is Script {
    function run(address worldAddress) external {
        IWorld world = IWorld(worldAddress);

        // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address parcelLicenseAddress = vm.envAddress("PARCEL_LICENSE_ADDRESS");

        // Start broadcasting transactions from the deployer account
        vm.startBroadcast(deployerPrivateKey);

        // Install PCOOwnershipModule
        PCOOwnershipModule module = new PCOOwnershipModule();
        world.installRootModule(module, abi.encode(parcelLicenseAddress));

        vm.stopBroadcast();
    }
}
