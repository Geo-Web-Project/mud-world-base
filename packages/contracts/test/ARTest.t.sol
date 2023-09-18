// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import {MudTest} from "@latticexyz/store/src/MudTest.sol";

import {IWorld} from "../src/codegen/world/IWorld.sol";
import {TrackedImageComponent, TrackedImageComponentData, ScaleComponentData, PositionComponentData, OrientationComponentData, AnchorComponent, AnchorComponentData, ModelComponent, ModelComponentData} from "../src/codegen/Tables.sol";
import {ImageEncodingFormat, ModelEncodingFormat} from "../src/codegen/Types.sol";
import {getKeysInTable} from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import "forge-std/console.sol";

contract ARTest is MudTest {
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

    function testAddAnchor() public {
        bytes32 key = world.geoweb_ARSystem_addImageAnchor(
            TrackedImageComponentData({
                physicalWidthInMillimeters: 165,
                imageAsset: new bytes(0),
                encodingFormat: ImageEncodingFormat.Png
            })
        );

        assertEq(
            TrackedImageComponent.get(key).physicalWidthInMillimeters,
            165
        );
    }

    function testAddObject() public {
        bytes32 anchor = world.geoweb_ARSystem_addImageAnchor(
            TrackedImageComponentData({
                physicalWidthInMillimeters: 165,
                imageAsset: new bytes(0),
                encodingFormat: ImageEncodingFormat.Png
            })
        );

        bytes32 key = world.geoweb_ARSystem_addAnchoredObject(
            anchor,
            PositionComponentData({x: 0, y: 100, z: 0}),
            ModelComponentData({
                encodingFormat: ModelEncodingFormat.Usdz,
                contentHash: new bytes(0)
            })
        );
        AnchorComponentData memory anchorData = AnchorComponent.get(key);
        bytes memory contentHash = ModelComponent.getContentHash(key);

        assertEq(anchorData.anchor, anchor);
        assertEq(contentHash, new bytes(0));
    }
}
