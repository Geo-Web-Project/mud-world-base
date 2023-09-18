// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {IWorld} from "../src/codegen/world/IWorld.sol";
import {MediaObjectData, TrackedImageComponentData, ScaleComponentData, OrientationComponentData, PositionComponentData, ModelComponentData, AnchorComponentTableId} from "../src/codegen/Tables.sol";
import {MediaObjectType, MediaObjectEncodingFormat, ImageEncodingFormat, ModelEncodingFormat} from "../src/codegen/Types.sol";

contract PostDeploy is Script {
    function run(address worldAddress) external {
        // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions from the deployer account
        vm.startBroadcast(deployerPrivateKey);

        IWorld(worldAddress).geoweb_ProfileSystem_setName("GLB Model");
        IWorld(worldAddress).geoweb_ProfileSystem_setUrl(
            "https://geoweb.network"
        );
        IWorld(worldAddress).geoweb_MediaGallerySyst_addToMediaGallery(
            MediaObjectData({
                name: "App Logo",
                mediaType: MediaObjectType.Image,
                contentHash: hex"e3010155122055c19cfa5032eae6cc5cfe6350c5545dc270c0c8e63264da275ad903e50b2ea5",
                contentSize: 33649,
                encodingFormat: MediaObjectEncodingFormat.Png
            })
        );
        IWorld(worldAddress).geoweb_MediaGallerySyst_addToMediaGallery(
            MediaObjectData({
                name: "Buddha",
                mediaType: MediaObjectType.Model,
                contentHash: hex"e30101701220ef41de9da4895794034ca1e057762ac36c65057d9566f0c34494fe949a87e349",
                contentSize: 22712008,
                encodingFormat: MediaObjectEncodingFormat.Glb
            })
        );
        IWorld(worldAddress).geoweb_MediaGallerySyst_addToMediaGallery(
            MediaObjectData({
                name: "Sample Audio",
                mediaType: MediaObjectType.Audio,
                contentHash: hex"e301015512204fcb312155dc09bdfa9c615c5b058e206e36ee4917cb23ea3086dc86afd77540",
                contentSize: 481161,
                encodingFormat: MediaObjectEncodingFormat.Mp3
            })
        );
        IWorld(worldAddress).geoweb_MediaGallerySyst_addToMediaGallery(
            MediaObjectData({
                name: "Sample Video",
                mediaType: MediaObjectType.Video,
                contentHash: hex"e3010170122010744edb4ff8bbcb6203fe3b8fd6fc2bbc9c9e577f720273d79fa220406d2408",
                contentSize: 13426489,
                encodingFormat: MediaObjectEncodingFormat.Mp4
            })
        );

        // Add AR objects
        bytes32 anchorKey = IWorld(worldAddress).geoweb_ARSystem_addImageAnchor(
            TrackedImageComponentData({
                physicalWidthInMillimeters: 165,
                imageAsset: hex"e3010155122076e1ccb6fee2a1976d0c530ce1fd6ef349c9aa8e636a8a7aea2eb11a2f6cc4fb",
                encodingFormat: ImageEncodingFormat.Jpeg
            })
        );

        IWorld(worldAddress).geoweb_ARSystem_addAnchoredObject(
            anchorKey,
            ModelComponentData({
                encodingFormat: ModelEncodingFormat.Glb,
                contentHash: hex"e30101701220ef41de9da4895794034ca1e057762ac36c65057d9566f0c34494fe949a87e349"
            })
        );

        vm.stopBroadcast();
    }
}
