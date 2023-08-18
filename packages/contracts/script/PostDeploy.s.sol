// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {IWorld} from "../src/codegen/world/IWorld.sol";
import {MediaObjectData} from "../src/codegen/Tables.sol";
import {MediaObjectType, EncodingFormat} from "../src/codegen/Types.sol";

contract PostDeploy is Script {
    function run(address worldAddress) external {
        // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions from the deployer account
        vm.startBroadcast(deployerPrivateKey);

        IWorld(worldAddress).geoweb_ProfileSystem_setName("Initial name");
        IWorld(worldAddress).geoweb_ProfileSystem_setUrl("Initial url");
        IWorld(worldAddress).geoweb_MediaGallerySyst_addToMediaGallery(
            MediaObjectData({
                name: "Name",
                mediaType: MediaObjectType.Image,
                contentHash: new bytes(0),
                contentSize: 0,
                encodingFormat: EncodingFormat.Jpeg
            })
        );

        vm.stopBroadcast();
    }
}
