// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import {MudTest} from "@latticexyz/store/src/MudTest.sol";

import {IWorld} from "../src/codegen/world/IWorld.sol";
import {MediaObjectType, EncodingFormat} from "../src/codegen/Types.sol";
import {MediaObject, MediaObjectData, MediaObjectTableId} from "../src/codegen/Tables.sol";
import {getKeysInTable} from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";

contract MediaGalleryTest is MudTest {
    IWorld public world;

    function setUp() public override {
        super.setUp();
        world = IWorld(worldAddress);
    }

    function testWorldExists() public {
        uint256 codeSize;
        address addr = worldAddress;
        assembly {
            codeSize := extcodesize(addr)
        }
        assertTrue(codeSize > 0);
    }

    function testAddToMediaGallery() public {
        bytes32 key = world.geoweb_MediaGallerySyst_addToMediaGallery(
            MediaObjectData({
                name: "Name",
                mediaType: MediaObjectType.Image,
                contentHash: new bytes(0),
                contentSize: 0,
                encodingFormat: EncodingFormat.Jpeg
            })
        );

        MediaObjectData memory mediaObjectData = MediaObject.get(world, key);
        assertEq(mediaObjectData.name, "Name");
        assertEq(uint(mediaObjectData.mediaType), uint(MediaObjectType.Image));
        assertEq(mediaObjectData.contentSize, 0);
        assertEq(
            uint(mediaObjectData.encodingFormat),
            uint(EncodingFormat.Jpeg)
        );
    }

    function testRemoveFromMediaGallery() public {
        bytes32 key = world.geoweb_MediaGallerySyst_addToMediaGallery(
            MediaObjectData({
                name: "Name",
                mediaType: MediaObjectType.Image,
                contentHash: new bytes(0),
                contentSize: 0,
                encodingFormat: EncodingFormat.Jpeg
            })
        );

        bytes32[][] memory mediaObjects = getKeysInTable(
            world,
            MediaObjectTableId
        );

        uint256 oldLength = mediaObjects.length;

        world.geoweb_MediaGallerySyst_removeFromMediaGallery(key);

        mediaObjects = getKeysInTable(world, MediaObjectTableId);

        assertEq(oldLength - mediaObjects.length, 1);
    }
}
