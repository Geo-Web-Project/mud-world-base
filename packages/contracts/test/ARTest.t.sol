// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import {MudTest} from "@latticexyz/store/src/MudTest.sol";

import {IWorld} from "../src/codegen/world/IWorld.sol";
import {IsAnchorComponent, PositionComponentData, ScaleComponentData, OrientationComponentData, AnchorComponent, AnchorComponentData, Model3DComponent} from "../src/codegen/Tables.sol";
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
        bytes32 key = world.geoweb_ARSystem_addNewAnchor(
            PositionComponentData({x: 0, y: 0, z: -1})
        );

        assertEq(IsAnchorComponent.get(key), true);
    }

    function testAddObject() public {
        bytes32 anchor = world.geoweb_ARSystem_addNewAnchor(
            PositionComponentData({x: 0, y: 0, z: -1})
        );

        bytes32 key = world.geoweb_ARSystem_addNewObject(anchor, new bytes(0));
        AnchorComponentData memory anchorData = AnchorComponent.get(key);
        bytes memory usdz = Model3DComponent.get(key);

        assertEq(anchorData.anchor, anchor);
        assertEq(usdz, new bytes(0));
    }
}
