// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import {MudTest} from "@latticexyz/store/src/MudTest.sol";

import {IWorld} from "../src/codegen/world/IWorld.sol";
import {Name, Url, NameTableId} from "../src/codegen/Tables.sol";

contract ProfileTest is MudTest {
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

    function testSetName() public {
        world.geoweb_ProfileSystem_setName("New name");
        string memory name = Name.get(world);
        assertEq(name, "New name");
    }

    function testSetUrl() public {
        world.geoweb_ProfileSystem_setUrl("New url");
        string memory url = Url.get(world);
        assertEq(url, "New url");
    }
}
