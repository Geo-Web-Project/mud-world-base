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

        IWorld(worldAddress).geoweb_ProfileSystem_setName("Example World");
        IWorld(worldAddress).geoweb_ProfileSystem_setUrl(
            "https://geoweb.network"
        );
        IWorld(worldAddress).geoweb_MediaGallerySyst_addToMediaGallery(
            MediaObjectData({
                name: "App Logo",
                mediaType: MediaObjectType.Image,
                contentHash: hex"e3010155122055c19cfa5032eae6cc5cfe6350c5545dc270c0c8e63264da275ad903e50b2ea5",
                contentSize: 33649,
                encodingFormat: EncodingFormat.Png
            })
        );
        IWorld(worldAddress).geoweb_MediaGallerySyst_addToMediaGallery(
            MediaObjectData({
                name: "Buddha",
                mediaType: MediaObjectType.Model3D,
                contentHash: hex"e301017012208fdf9e63064917220218e7b261b39c1cffbe2b66a231ce53bd6f4c29a4b5e6e1",
                contentSize: 22712008,
                encodingFormat: EncodingFormat.Usdz
            })
        );
        IWorld(worldAddress).geoweb_MediaGallerySyst_addToMediaGallery(
            MediaObjectData({
                name: "Sample Audio",
                mediaType: MediaObjectType.Audio,
                contentHash: hex"e301015512204fcb312155dc09bdfa9c615c5b058e206e36ee4917cb23ea3086dc86afd77540",
                contentSize: 481161,
                encodingFormat: EncodingFormat.Mp3
            })
        );
        IWorld(worldAddress).geoweb_MediaGallerySyst_addToMediaGallery(
            MediaObjectData({
                name: "Sample Video",
                mediaType: MediaObjectType.Video,
                contentHash: hex"e3010170122010744edb4ff8bbcb6203fe3b8fd6fc2bbc9c9e577f720273d79fa220406d2408",
                contentSize: 13426489,
                encodingFormat: EncodingFormat.Mp4
            })
        );

        vm.stopBroadcast();
    }
}
