// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "forge-std/Test.sol";
import {MudTest} from "@latticexyz/world/test/MudTest.t.sol";
import {IWorld} from "../src/codegen/world/IWorld.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {PCOOwnershipHook} from "../src/modules/pcoownership/PCOOwnershipHook.sol";
import {PCOOwnershipModule} from "../src/modules/pcoownership/PCOOwnershipModule.sol";
import {NamespaceOwner, NamespaceOwnerTableId} from "@latticexyz/world/src/codegen/tables/NamespaceOwner.sol";
import {ResourceId, WorldResourceIdLib} from "@latticexyz/world/src/WorldResourceId.sol";
import {PackedCounter} from "@latticexyz/store/src/PackedCounter.sol";
import {StoreSwitch} from "@latticexyz/store/src/StoreSwitch.sol";

contract MockERC721 is ERC721 {
    constructor() ERC721("name", "symbol") {}

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) external {
        _burn(tokenId);
    }
}

contract PCOOwnershipTest is MudTest {
    IWorld world;
    MockERC721 mockERC721 = new MockERC721();

    function setUp() public override {
        super.setUp();
        world = IWorld(worldAddress);

        // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions from the deployer account
        vm.startBroadcast(deployerPrivateKey);

        StoreSwitch.setStoreAddress(worldAddress);

        // Install PCOOwnershipModule
        PCOOwnershipModule module = new PCOOwnershipModule();

        world.installRootModule(module, abi.encode(address(mockERC721)));

        vm.stopBroadcast();
    }

    function registerParcel() public returns (ResourceId) {
        uint256 parcelId = 1;
        mockERC721.mint(address(this), parcelId);

        ResourceId namespaceId = world.getNamespaceIdForParcel(parcelId);

        world.registerParcelNamespace(parcelId);

        return namespaceId;
    }

    function testRegisterParcelNamespace() public {
        ResourceId namespaceId = registerParcel();

        assertEq(
            NamespaceOwner.get(namespaceId),
            address(this),
            "PCO owner should be namespace owner"
        );
    }

    function testClaimParcelNamespace() public {
        uint256 parcelId = 1;
        ResourceId namespaceId = registerParcel();
        mockERC721.transferFrom(address(this), address(0x1), parcelId);

        vm.startPrank(address(0x1));
        world.claimParcelNamespace(parcelId);
        vm.stopPrank();

        assertEq(
            NamespaceOwner.get(namespaceId),
            address(0x1),
            "PCO owner should be namespace owner"
        );
    }

    function test_CannotDeleteRecord() public {
        ResourceId namespaceId = registerParcel();
        mockERC721.burn(1);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        vm.expectRevert(PCOOwnershipHook.PCOOwnership_CannotDelete.selector);
        NamespaceOwner.deleteRecord(namespaceId);
        vm.stopBroadcast();
    }

    function test_CannotRegisterAnotherParcel() public {
        uint256 parcelId = 1;
        mockERC721.mint(address(0x1), parcelId);

        ResourceId namespaceId = world.getNamespaceIdForParcel(parcelId);

        vm.expectRevert(PCOOwnershipHook.PCOOwnership_NotPCOOwner.selector);
        world.registerParcelNamespace(parcelId);
    }

    function test_CannotRegisterAnotherNamespace() public {
        uint256 parcelId = 1;
        mockERC721.mint(address(0x1), parcelId);

        ResourceId namespaceId = world.getNamespaceIdForParcel(parcelId);

        vm.expectRevert(PCOOwnershipHook.PCOOwnership_NotFound.selector);
        world.registerNamespace(namespaceId);
    }

    function test_CannotRegisterNamespaceDirectly() public {
        uint256 parcelId = 1;
        mockERC721.mint(address(this), parcelId);

        ResourceId namespaceId = world.getNamespaceIdForParcel(parcelId);

        vm.expectRevert(PCOOwnershipHook.PCOOwnership_NotFound.selector);
        world.registerNamespace(namespaceId);
    }

    function test_CannotSetNamespaceOwnerNew() public {
        uint256 parcelId = 1;
        mockERC721.mint(address(0x1), parcelId);

        ResourceId namespaceId = world.getNamespaceIdForParcel(parcelId);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        vm.expectRevert(PCOOwnershipHook.PCOOwnership_NotFound.selector);
        NamespaceOwner.setOwner(namespaceId, address(this));
        vm.stopBroadcast();
    }

    function test_CannotSetNamespaceOwnerExisting() public {
        ResourceId namespaceId = registerParcel();

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        vm.expectRevert(PCOOwnershipHook.PCOOwnership_NotPCOOwner.selector);
        NamespaceOwner.setOwner(namespaceId, address(0x1));
        vm.stopBroadcast();
    }

    function test_CannotSetRecord() public {
        uint256 parcelId = 1;
        mockERC721.mint(address(0x1), parcelId);

        ResourceId namespaceId = world.getNamespaceIdForParcel(parcelId);

        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = ResourceId.unwrap(namespaceId);

        (
            bytes memory _staticData,
            PackedCounter _encodedLengths,
            bytes memory _dynamicData
        ) = NamespaceOwner.encode(address(this));

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        vm.expectRevert(PCOOwnershipHook.PCOOwnership_NotFound.selector);
        world.setRecord(
            NamespaceOwnerTableId,
            _keyTuple,
            _staticData,
            _encodedLengths,
            _dynamicData
        );
        vm.stopBroadcast();
    }

    function test_CannotSetRecordExisting() public {
        ResourceId namespaceId = registerParcel();

        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = ResourceId.unwrap(namespaceId);

        (
            bytes memory _staticData,
            PackedCounter _encodedLengths,
            bytes memory _dynamicData
        ) = NamespaceOwner.encode(address(0x1));

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        vm.expectRevert(PCOOwnershipHook.PCOOwnership_NotPCOOwner.selector);
        world.setRecord(
            NamespaceOwnerTableId,
            _keyTuple,
            _staticData,
            _encodedLengths,
            _dynamicData
        );
        vm.stopBroadcast();
    }

    function test_CannotClaimParcelNamespace() public {
        uint256 parcelId = 1;
        ResourceId namespaceId = registerParcel();

        vm.startPrank(address(0x1));
        vm.expectRevert(PCOOwnershipHook.PCOOwnership_NotPCOOwner.selector);
        world.claimParcelNamespace(parcelId);
        vm.stopPrank();
    }
}
