// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {IWorld} from "../src/codegen/world/IWorld.sol";
import {PCOOwnershipModule} from "../src/modules/pcoownership/PCOOwnershipModule.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockERC721 is ERC721 {
    constructor() ERC721("name", "symbol") {}

    function mint(uint256 tokenId) external {
        _mint(msg.sender, tokenId);
    }

    function burn(uint256 tokenId) external {
        _burn(tokenId);
    }
}

contract PostDeploy is Script {
    function run(address worldAddress) external {
        IWorld world = IWorld(worldAddress);

        // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions from the deployer account
        vm.startBroadcast(deployerPrivateKey);

        if (isFork() == false) {
            // Install PCOOwnershipModule
            address parcelLicenseAddress = vm.envAddress("PARCEL_LICENSE_ADDRESS");

            PCOOwnershipModule module = new PCOOwnershipModule();
            world.installRootModule(module, abi.encode(parcelLicenseAddress));
        }

        vm.stopBroadcast();
    }
}
