// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import "forge-std/Test.sol";
import {MudTest} from "@latticexyz/world/test/MudTest.t.sol";
import {IWorld} from "../src/codegen/world/IWorld.sol";
import {IWorldErrors} from "@latticexyz/world/src/IWorldErrors.sol";
import {IAugment, Augment} from "../src/modules/augmentinstall/Augment.sol";
import {ScaleCom} from "../src/codegen/tables/ScaleCom.sol";
import {NameCom} from "../src/codegen/tables/NameCom.sol";
import {EncodedLengths} from "@latticexyz/store/src/EncodedLengths.sol";
import {ResourceId, WorldResourceIdLib, WorldResourceIdInstance} from "@latticexyz/world/src/WorldResourceId.sol";
import {RESOURCE_TABLE} from "@latticexyz/world/src/worldResourceTypes.sol";
import {TABLE_ID as UNIQUE_ENTITY_TABLE_ID} from "@latticexyz/world-modules/src/modules/uniqueentity/constants.sol";
import {UniqueEntity} from "@latticexyz/world-modules/src/modules/uniqueentity/tables/UniqueEntity.sol";
import {getUniqueEntity} from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";
import {Augments, AugmentsData} from "../src/modules/augmentinstall/tables/Augments.sol";
import {AugmentInstallSystem, AugmentInstallLib, AugmentComponentValue} from "../src/modules/augmentinstall/AugmentInstallSystem.sol";
import {ResourceIds} from "@latticexyz/store/src/StoreCore.sol";
import {Utils} from "@latticexyz/world/src/Utils.sol";
import {SystemSwitch} from "@latticexyz/world-modules/src/utils/SystemSwitch.sol";
import {StoreSwitch} from "@latticexyz/store/src/StoreSwitch.sol";
import {WorldRegistrationSystem} from "@latticexyz/world/src/modules/init/implementations/WorldRegistrationSystem.sol";
import {IStore} from "@latticexyz/store/src/IStore.sol";
import {IBaseWorld} from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import "forge-std/console.sol";

contract AugmentInstallTest is MudTest {
    IWorld world;
    bytes14 testNamespace = bytes14("parcel1");
    bytes14 testNamespace2 = bytes14("parcel2");

    function setUp() public override {
        super.setUp();
        world = IWorld(worldAddress);

        vm.startPrank(address(0x1));
        world.registerNamespace(
            WorldResourceIdLib.encodeNamespace(testNamespace)
        );
        world.registerNamespace(
            WorldResourceIdLib.encodeNamespace(testNamespace2)
        );

        AugmentInstallSystem augmentInstallSystem = new AugmentInstallSystem();
        ResourceId systemResource = world.getAugmentInstallSystemResource(
            testNamespace
        );
        SystemSwitch.call(
            abi.encodeCall(
                WorldRegistrationSystem.registerSystem,
                (systemResource, augmentInstallSystem, false)
            )
        );

        // Register tables
        ScaleCom.register(
            ResourceId.wrap(
                bytes32(
                    abi.encodePacked(
                        RESOURCE_TABLE,
                        testNamespace,
                        bytes16(bytes32("ScaleCom"))
                    )
                )
            )
        );
        NameCom.register(
            ResourceId.wrap(
                bytes32(
                    abi.encodePacked(
                        RESOURCE_TABLE,
                        testNamespace,
                        bytes16(bytes32("NameCom"))
                    )
                )
            )
        );

        vm.stopPrank();
    }

    function grantAccessToTables(IAugment mockAugment) internal {
        bytes16[] memory tables = mockAugment.getRequiredPermissions();
        for (uint256 i = 0; i < tables.length; i++) {
            ResourceId _tableId = ResourceId.wrap(
                bytes32(
                    abi.encodePacked(RESOURCE_TABLE, testNamespace, tables[i])
                )
            );
            world.grantAccess(_tableId, address(mockAugment));
        }
    }

    function testInstallAugment_Single() public {
        MockAugmentSingle mockAugment = new MockAugmentSingle();

        (
            bytes memory staticData,
            EncodedLengths encodedLengths,
            bytes memory dynamicData
        ) = ScaleCom.encode(1, 2, 3);

        AugmentComponentValue memory componentValue = AugmentComponentValue({
            staticData: staticData,
            encodedLengths: encodedLengths,
            dynamicData: dynamicData
        });
        AugmentComponentValue[][]
            memory componentValues = new AugmentComponentValue[][](1);
        componentValues[0] = new AugmentComponentValue[](1);
        componentValues[0][0] = componentValue;

        ResourceId _tableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("ScaleCom"))
                )
            )
        );

        vm.startPrank(address(0x1));
        world.call(
            world.getAugmentInstallSystemResource(testNamespace),
            abi.encodeWithSignature(
                "installAugment(address,bytes)",
                mockAugment,
                abi.encode(componentValues)
            )
        );
        vm.stopPrank();

        uint256 augmentKey = UniqueEntity.get(UNIQUE_ENTITY_TABLE_ID);
        uint256 entityId = augmentKey - 1;

        assertEq(
            ScaleCom.getX(world, _tableId, bytes32(entityId)),
            1,
            "Scale X should be set"
        );
        assertEq(
            ScaleCom.getY(world, _tableId, bytes32(entityId)),
            2,
            "Scale Y should be set"
        );
        assertEq(
            ScaleCom.getZ(world, _tableId, bytes32(entityId)),
            3,
            "Scale Z should be set"
        );

        assertEq(
            Augments.lengthInstalledEntities(
                world,
                AugmentInstallLib.getAugmentsTableId(
                    WorldResourceIdLib.encodeNamespace(testNamespace)
                ),
                bytes32(augmentKey)
            ),
            1,
            "Augment should be installed"
        );
    }

    function testInstallAugment_MultipleComponents() public {
        MockAugmentMultipleComponents mockAugment = new MockAugmentMultipleComponents();

        AugmentComponentValue[][]
            memory componentValues = new AugmentComponentValue[][](1);
        componentValues[0] = new AugmentComponentValue[](2);

        {
            (
                bytes memory staticData,
                EncodedLengths encodedLengths,
                bytes memory dynamicData
            ) = ScaleCom.encode(1, 2, 3);
            componentValues[0][0] = AugmentComponentValue(
                staticData,
                encodedLengths,
                dynamicData
            );
        }

        {
            (
                bytes memory staticData,
                EncodedLengths encodedLengths,
                bytes memory dynamicData
            ) = NameCom.encode("test");
            componentValues[0][1] = AugmentComponentValue(
                staticData,
                encodedLengths,
                dynamicData
            );
        }

        vm.startPrank(address(0x1));
        world.call(
            world.getAugmentInstallSystemResource(testNamespace),
            abi.encodeWithSignature(
                "installAugment(address,bytes)",
                mockAugment,
                abi.encode(componentValues)
            )
        );
        vm.stopPrank();

        ResourceId _scaleTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("ScaleCom"))
                )
            )
        );
        ResourceId _nameTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("NameCom"))
                )
            )
        );
        uint256 augmentKey = UniqueEntity.get(UNIQUE_ENTITY_TABLE_ID);
        uint256 entityId = augmentKey - 1;

        assertEq(
            ScaleCom.getX(world, _scaleTableId, bytes32(entityId)),
            1,
            "Scale X should be set"
        );
        assertEq(
            ScaleCom.getY(world, _scaleTableId, bytes32(entityId)),
            2,
            "Scale Y should be set"
        );
        assertEq(
            ScaleCom.getZ(world, _scaleTableId, bytes32(entityId)),
            3,
            "Scale Z should be set"
        );
        assertEq(
            NameCom.get(world, _nameTableId, bytes32(entityId)),
            "test",
            "Name should be set"
        );
        assertEq(
            Augments
                .get(
                    world,
                    AugmentInstallLib.getAugmentsTableId(
                        WorldResourceIdLib.encodeNamespace(testNamespace)
                    ),
                    bytes32(augmentKey)
                )
                .augmentAddress,
            address(mockAugment),
            "Augment should be installed"
        );
    }

    function testInstallAugment_MultipleEntities() public {
        MockAugmentMultipleEntities mockAugment = new MockAugmentMultipleEntities();

        AugmentComponentValue[][]
            memory componentValues = new AugmentComponentValue[][](2);

        {
            (
                bytes memory staticData,
                EncodedLengths encodedLengths,
                bytes memory dynamicData
            ) = ScaleCom.encode(1, 2, 3);
            componentValues[0] = new AugmentComponentValue[](1);
            componentValues[0][0] = AugmentComponentValue(
                staticData,
                encodedLengths,
                dynamicData
            );
        }

        {
            (
                bytes memory staticData,
                EncodedLengths encodedLengths,
                bytes memory dynamicData
            ) = NameCom.encode("test");
            componentValues[1] = new AugmentComponentValue[](1);
            componentValues[1][0] = AugmentComponentValue(
                staticData,
                encodedLengths,
                dynamicData
            );
        }

        vm.startPrank(address(0x1));
        world.call(
            world.getAugmentInstallSystemResource(testNamespace),
            abi.encodeWithSignature(
                "installAugment(address,bytes)",
                mockAugment,
                abi.encode(componentValues)
            )
        );
        vm.stopPrank();

        ResourceId _scaleTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("ScaleCom"))
                )
            )
        );
        ResourceId _nameTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("NameCom"))
                )
            )
        );
        uint256 augmentKey = UniqueEntity.get(UNIQUE_ENTITY_TABLE_ID);
        uint256 entityId1 = augmentKey - 2;
        uint256 entityId2 = entityId1 + 1;

        assertEq(
            ScaleCom.getX(world, _scaleTableId, bytes32(entityId1)),
            1,
            "Scale X should be set"
        );
        assertEq(
            ScaleCom.getY(world, _scaleTableId, bytes32(entityId1)),
            2,
            "Scale Y should be set"
        );
        assertEq(
            ScaleCom.getZ(world, _scaleTableId, bytes32(entityId1)),
            3,
            "Scale Z should be set"
        );
        assertEq(
            NameCom.get(world, _nameTableId, bytes32(entityId2)),
            "test",
            "Name should be set"
        );
        assertEq(
            Augments
                .get(
                    world,
                    AugmentInstallLib.getAugmentsTableId(
                        WorldResourceIdLib.encodeNamespace(testNamespace)
                    ),
                    bytes32(augmentKey)
                )
                .augmentAddress,
            address(mockAugment),
            "Augment should be installed"
        );
    }

    function testInstallAugment_SetOverride() public {
        MockAugmentSetOverride mockAugment = new MockAugmentSetOverride();

        AugmentComponentValue[][]
            memory componentValues = new AugmentComponentValue[][](1);

        (
            bytes memory staticData,
            EncodedLengths encodedLengths,
            bytes memory dynamicData
        ) = ScaleCom.encode(1, 2, 3);
        componentValues[0] = new AugmentComponentValue[](1);
        componentValues[0][0] = AugmentComponentValue(
            staticData,
            encodedLengths,
            dynamicData
        );

        ResourceId _scaleTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("ScaleCom"))
                )
            )
        );
        ResourceId _nameTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("NameCom"))
                )
            )
        );

        vm.startPrank(address(0x1));
        grantAccessToTables(mockAugment);
        world.call(
            world.getAugmentInstallSystemResource(testNamespace),
            abi.encodeWithSignature(
                "installAugment(address,bytes)",
                mockAugment,
                abi.encode(componentValues)
            )
        );
        vm.stopPrank();

        uint256 augmentKey = UniqueEntity.get(UNIQUE_ENTITY_TABLE_ID);
        uint256 entityId1 = augmentKey - 2;
        uint256 entityId2 = entityId1 + 1;

        assertEq(
            ScaleCom.getX(world, _scaleTableId, bytes32(entityId1)),
            1,
            "Scale X should be set"
        );
        assertEq(
            ScaleCom.getY(world, _scaleTableId, bytes32(entityId1)),
            2,
            "Scale Y should be set"
        );
        assertEq(
            ScaleCom.getZ(world, _scaleTableId, bytes32(entityId1)),
            3,
            "Scale Z should be set"
        );
        assertEq(
            NameCom.get(world, _nameTableId, bytes32(entityId2)),
            "test1",
            "Name should be set"
        );
        assertEq(
            Augments
                .get(
                    world,
                    AugmentInstallLib.getAugmentsTableId(
                        WorldResourceIdLib.encodeNamespace(testNamespace)
                    ),
                    bytes32(augmentKey)
                )
                .augmentAddress,
            address(mockAugment),
            "Augment should be installed"
        );
    }

    function testInstallAugment_SpliceOverride() public {
        MockAugmentSpliceOverride mockAugment = new MockAugmentSpliceOverride();

        AugmentComponentValue[][]
            memory componentValues = new AugmentComponentValue[][](1);

        (
            bytes memory staticData,
            EncodedLengths encodedLengths,
            bytes memory dynamicData
        ) = ScaleCom.encode(1, 2, 3);
        componentValues[0] = new AugmentComponentValue[](1);
        componentValues[0][0] = AugmentComponentValue(
            staticData,
            encodedLengths,
            dynamicData
        );

        ResourceId _scaleTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("ScaleCom"))
                )
            )
        );

        vm.startPrank(address(0x1));
        grantAccessToTables(mockAugment);
        world.call(
            world.getAugmentInstallSystemResource(testNamespace),
            abi.encodeWithSignature(
                "installAugment(address,bytes)",
                mockAugment,
                abi.encode(componentValues)
            )
        );
        vm.stopPrank();

        uint256 augmentKey = UniqueEntity.get(UNIQUE_ENTITY_TABLE_ID);
        uint256 entityId1 = augmentKey - 1;

        assertEq(
            ScaleCom.getX(world, _scaleTableId, bytes32(entityId1)),
            10,
            "Scale X should be set"
        );
        assertEq(
            ScaleCom.getY(world, _scaleTableId, bytes32(entityId1)),
            2,
            "Scale Y should be set"
        );
        assertEq(
            ScaleCom.getZ(world, _scaleTableId, bytes32(entityId1)),
            3,
            "Scale Z should be set"
        );
        assertEq(
            Augments
                .get(
                    world,
                    AugmentInstallLib.getAugmentsTableId(
                        WorldResourceIdLib.encodeNamespace(testNamespace)
                    ),
                    bytes32(augmentKey)
                )
                .augmentAddress,
            address(mockAugment),
            "Augment should be installed"
        );
    }

    function test_CannotInstallWithoutPermission() public {
        MockAugmentSingle mockAugment = new MockAugmentSingle();

        (
            bytes memory staticData,
            EncodedLengths encodedLengths,
            bytes memory dynamicData
        ) = ScaleCom.encode(1, 2, 3);

        AugmentComponentValue memory componentValue = AugmentComponentValue({
            staticData: staticData,
            encodedLengths: encodedLengths,
            dynamicData: dynamicData
        });
        AugmentComponentValue[][]
            memory componentValues = new AugmentComponentValue[][](1);
        componentValues[0] = new AugmentComponentValue[](1);
        componentValues[0][0] = componentValue;

        vm.startPrank(address(0x2));
        ResourceId systemResource = world.getAugmentInstallSystemResource(
            testNamespace
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                IWorldErrors.World_AccessDenied.selector,
                WorldResourceIdInstance.toString(systemResource),
                address(0x2)
            )
        );
        world.call(
            systemResource,
            abi.encodeWithSignature(
                "installAugment(address,bytes)",
                mockAugment,
                abi.encode(componentValues)
            )
        );
        vm.stopPrank();
    }

    function test_CannotOverrideWithoutPermission() public {
        MockAugmentSetOverride mockAugment = new MockAugmentSetOverride();

        AugmentComponentValue[][]
            memory componentValues = new AugmentComponentValue[][](1);

        (
            bytes memory staticData,
            EncodedLengths encodedLengths,
            bytes memory dynamicData
        ) = ScaleCom.encode(1, 2, 3);
        componentValues[0] = new AugmentComponentValue[](1);
        componentValues[0][0] = AugmentComponentValue(
            staticData,
            encodedLengths,
            dynamicData
        );

        ResourceId _scaleTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("ScaleCom"))
                )
            )
        );
        ResourceId _nameTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("NameCom"))
                )
            )
        );

        vm.startPrank(address(0x1));
        ResourceId systemResource = world.getAugmentInstallSystemResource(
            testNamespace
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                IWorldErrors.World_AccessDenied.selector,
                WorldResourceIdInstance.toString(_nameTableId),
                address(mockAugment)
            )
        );
        world.call(
            systemResource,
            abi.encodeWithSignature(
                "installAugment(address,bytes)",
                mockAugment,
                abi.encode(componentValues)
            )
        );
        vm.stopPrank();
    }

    function test_BeforeInstallHook() public {
        MockAugmentSingleGated mockAugment = new MockAugmentSingleGated();

        (
            bytes memory staticData,
            EncodedLengths encodedLengths,
            bytes memory dynamicData
        ) = ScaleCom.encode(1, 2, 3);

        AugmentComponentValue memory componentValue = AugmentComponentValue({
            staticData: staticData,
            encodedLengths: encodedLengths,
            dynamicData: dynamicData
        });
        AugmentComponentValue[][]
            memory componentValues = new AugmentComponentValue[][](1);
        componentValues[0] = new AugmentComponentValue[](1);
        componentValues[0][0] = componentValue;

        vm.startPrank(address(0x1));
        ResourceId systemResource = world.getAugmentInstallSystemResource(
            testNamespace
        );
        vm.expectRevert(MockAugmentSingleGated.InstallFailed.selector);
        world.call(
            systemResource,
            abi.encodeWithSignature(
                "installAugment(address,bytes)",
                mockAugment,
                abi.encode(componentValues)
            )
        );
        vm.stopPrank();
    }

    function testUpdateAugment_Single() public {
        MockAugmentSingle mockAugment = new MockAugmentSingle();

        vm.startPrank(address(0x1));

        {
            (
                bytes memory staticData,
                EncodedLengths encodedLengths,
                bytes memory dynamicData
            ) = ScaleCom.encode(1, 2, 3);

            AugmentComponentValue
                memory componentValue = AugmentComponentValue({
                    staticData: staticData,
                    encodedLengths: encodedLengths,
                    dynamicData: dynamicData
                });
            AugmentComponentValue[][]
                memory componentValues = new AugmentComponentValue[][](1);
            componentValues[0] = new AugmentComponentValue[](1);
            componentValues[0][0] = componentValue;

            world.call(
                world.getAugmentInstallSystemResource(testNamespace),
                abi.encodeWithSignature(
                    "installAugment(address,bytes)",
                    mockAugment,
                    abi.encode(componentValues)
                )
            );
        }

        uint256 augmentKey = UniqueEntity.get(UNIQUE_ENTITY_TABLE_ID);

        {
            (
                bytes memory staticData,
                EncodedLengths encodedLengths,
                bytes memory dynamicData
            ) = ScaleCom.encode(2, 4, 6);

            AugmentComponentValue
                memory componentValue = AugmentComponentValue({
                    staticData: staticData,
                    encodedLengths: encodedLengths,
                    dynamicData: dynamicData
                });
            AugmentComponentValue[][]
                memory componentValues = new AugmentComponentValue[][](1);
            componentValues[0] = new AugmentComponentValue[](1);
            componentValues[0][0] = componentValue;

            world.call(
                world.getAugmentInstallSystemResource(testNamespace),
                abi.encodeWithSignature(
                    "updateAugment(bytes32,bytes)",
                    bytes32(augmentKey),
                    abi.encode(componentValues)
                )
            );
        }
        vm.stopPrank();

        ResourceId _tableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("ScaleCom"))
                )
            )
        );
        uint256 entityId = augmentKey - 1;

        assertEq(
            ScaleCom.getX(world, _tableId, bytes32(entityId)),
            2,
            "Scale X should be updated"
        );
        assertEq(
            ScaleCom.getY(world, _tableId, bytes32(entityId)),
            4,
            "Scale Y should be updated"
        );
        assertEq(
            ScaleCom.getZ(world, _tableId, bytes32(entityId)),
            6,
            "Scale Z should be updated"
        );

        assertEq(
            Augments
                .get(
                    world,
                    AugmentInstallLib.getAugmentsTableId(
                        WorldResourceIdLib.encodeNamespace(testNamespace)
                    ),
                    bytes32(augmentKey)
                )
                .augmentAddress,
            address(mockAugment),
            "Augment should be installed"
        );
    }

    function testUpdateAugment_SetOverride() public {
        MockAugmentSetOverride mockAugment = new MockAugmentSetOverride();

        ResourceId _scaleTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("ScaleCom"))
                )
            )
        );
        ResourceId _nameTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("NameCom"))
                )
            )
        );

        vm.startPrank(address(0x1));
        {
            AugmentComponentValue[][]
                memory componentValues = new AugmentComponentValue[][](1);

            (
                bytes memory staticData,
                EncodedLengths encodedLengths,
                bytes memory dynamicData
            ) = ScaleCom.encode(1, 2, 3);
            componentValues[0] = new AugmentComponentValue[](1);
            componentValues[0][0] = AugmentComponentValue(
                staticData,
                encodedLengths,
                dynamicData
            );

            grantAccessToTables(mockAugment);
            world.call(
                world.getAugmentInstallSystemResource(testNamespace),
                abi.encodeWithSignature(
                    "installAugment(address,bytes)",
                    mockAugment,
                    abi.encode(componentValues)
                )
            );
        }

        uint256 augmentKey = UniqueEntity.get(UNIQUE_ENTITY_TABLE_ID);

        {
            AugmentComponentValue[][]
                memory componentValues = new AugmentComponentValue[][](1);

            (
                bytes memory staticData,
                EncodedLengths encodedLengths,
                bytes memory dynamicData
            ) = ScaleCom.encode(2, 4, 6);
            componentValues[0] = new AugmentComponentValue[](1);
            componentValues[0][0] = AugmentComponentValue(
                staticData,
                encodedLengths,
                dynamicData
            );

            world.call(
                world.getAugmentInstallSystemResource(testNamespace),
                abi.encodeWithSignature(
                    "updateAugment(bytes32,bytes)",
                    bytes32(augmentKey),
                    abi.encode(componentValues)
                )
            );
        }

        vm.stopPrank();

        uint256 entityId1 = augmentKey - 2;
        uint256 entityId2 = entityId1 + 1;

        assertEq(
            ScaleCom.getX(world, _scaleTableId, bytes32(entityId1)),
            2,
            "Scale X should be set"
        );
        assertEq(
            ScaleCom.getY(world, _scaleTableId, bytes32(entityId1)),
            4,
            "Scale Y should be set"
        );
        assertEq(
            ScaleCom.getZ(world, _scaleTableId, bytes32(entityId1)),
            6,
            "Scale Z should be set"
        );
        assertEq(
            NameCom.get(world, _nameTableId, bytes32(entityId2)),
            "test1",
            "Name should be set"
        );
        assertEq(
            Augments
                .get(
                    world,
                    AugmentInstallLib.getAugmentsTableId(
                        WorldResourceIdLib.encodeNamespace(testNamespace)
                    ),
                    bytes32(augmentKey)
                )
                .augmentAddress,
            address(mockAugment),
            "Augment should be installed"
        );
        assertEq(
            UniqueEntity.get(UNIQUE_ENTITY_TABLE_ID),
            augmentKey,
            "Should not create new entities"
        );
    }

    function testUpdateAugment_SpliceOverride() public {
        MockAugmentSpliceOverride mockAugment = new MockAugmentSpliceOverride();

        ResourceId _scaleTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("ScaleCom"))
                )
            )
        );

        vm.startPrank(address(0x1));

        {
            AugmentComponentValue[][]
                memory componentValues = new AugmentComponentValue[][](1);

            (
                bytes memory staticData,
                EncodedLengths encodedLengths,
                bytes memory dynamicData
            ) = ScaleCom.encode(1, 2, 3);
            componentValues[0] = new AugmentComponentValue[](1);
            componentValues[0][0] = AugmentComponentValue(
                staticData,
                encodedLengths,
                dynamicData
            );

            grantAccessToTables(mockAugment);
            world.call(
                world.getAugmentInstallSystemResource(testNamespace),
                abi.encodeWithSignature(
                    "installAugment(address,bytes)",
                    mockAugment,
                    abi.encode(componentValues)
                )
            );
        }

        uint256 augmentKey = UniqueEntity.get(UNIQUE_ENTITY_TABLE_ID);

        {
            AugmentComponentValue[][]
                memory componentValues = new AugmentComponentValue[][](1);

            (
                bytes memory staticData,
                EncodedLengths encodedLengths,
                bytes memory dynamicData
            ) = ScaleCom.encode(2, 4, 6);
            componentValues[0] = new AugmentComponentValue[](1);
            componentValues[0][0] = AugmentComponentValue(
                staticData,
                encodedLengths,
                dynamicData
            );

            world.call(
                world.getAugmentInstallSystemResource(testNamespace),
                abi.encodeWithSignature(
                    "updateAugment(bytes32,bytes)",
                    bytes32(augmentKey),
                    abi.encode(componentValues)
                )
            );
        }

        vm.stopPrank();

        uint256 entityId1 = augmentKey - 1;

        assertEq(
            ScaleCom.getX(world, _scaleTableId, bytes32(entityId1)),
            10,
            "Scale X should be set"
        );
        assertEq(
            ScaleCom.getY(world, _scaleTableId, bytes32(entityId1)),
            4,
            "Scale Y should be set"
        );
        assertEq(
            ScaleCom.getZ(world, _scaleTableId, bytes32(entityId1)),
            6,
            "Scale Z should be set"
        );
        assertEq(
            Augments
                .get(
                    world,
                    AugmentInstallLib.getAugmentsTableId(
                        WorldResourceIdLib.encodeNamespace(testNamespace)
                    ),
                    bytes32(augmentKey)
                )
                .augmentAddress,
            address(mockAugment),
            "Augment should be installed"
        );
        assertEq(
            UniqueEntity.get(UNIQUE_ENTITY_TABLE_ID),
            augmentKey,
            "Should not create new entities"
        );
    }

    function testUninstallAugment_Single() public {
        MockAugmentSingle mockAugment = new MockAugmentSingle();

        vm.startPrank(address(0x1));

        (
            bytes memory staticData,
            EncodedLengths encodedLengths,
            bytes memory dynamicData
        ) = ScaleCom.encode(1, 2, 3);

        AugmentComponentValue memory componentValue = AugmentComponentValue({
            staticData: staticData,
            encodedLengths: encodedLengths,
            dynamicData: dynamicData
        });
        AugmentComponentValue[][]
            memory componentValues = new AugmentComponentValue[][](1);
        componentValues[0] = new AugmentComponentValue[](1);
        componentValues[0][0] = componentValue;

        world.call(
            world.getAugmentInstallSystemResource(testNamespace),
            abi.encodeWithSignature(
                "installAugment(address,bytes)",
                mockAugment,
                abi.encode(componentValues)
            )
        );
        uint256 augmentKey = UniqueEntity.get(UNIQUE_ENTITY_TABLE_ID);

        world.call(
            world.getAugmentInstallSystemResource(testNamespace),
            abi.encodeWithSignature(
                "uninstallAugment(bytes32)",
                bytes32(augmentKey)
            )
        );

        vm.stopPrank();

        ResourceId _tableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("ScaleCom"))
                )
            )
        );
        uint256 entityId = augmentKey - 1;

        assertEq(
            ScaleCom.getX(world, _tableId, bytes32(entityId)),
            0,
            "Scale X should be deleted"
        );
        assertEq(
            ScaleCom.getY(world, _tableId, bytes32(entityId)),
            0,
            "Scale Y should be deleted"
        );
        assertEq(
            ScaleCom.getZ(world, _tableId, bytes32(entityId)),
            0,
            "Scale Z should be deleted"
        );

        assertEq(
            Augments.lengthInstalledEntities(
                world,
                AugmentInstallLib.getAugmentsTableId(
                    WorldResourceIdLib.encodeNamespace(testNamespace)
                ),
                bytes32(augmentKey)
            ),
            0,
            "Augment should be uninstalled"
        );
    }

    function testUninstallAugment_SetOverride() public {
        MockAugmentSetOverride mockAugment = new MockAugmentSetOverride();

        ResourceId _scaleTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("ScaleCom"))
                )
            )
        );
        ResourceId _nameTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("NameCom"))
                )
            )
        );

        vm.startPrank(address(0x1));
        {
            AugmentComponentValue[][]
                memory componentValues = new AugmentComponentValue[][](1);

            (
                bytes memory staticData,
                EncodedLengths encodedLengths,
                bytes memory dynamicData
            ) = ScaleCom.encode(1, 2, 3);
            componentValues[0] = new AugmentComponentValue[](1);
            componentValues[0][0] = AugmentComponentValue(
                staticData,
                encodedLengths,
                dynamicData
            );

            grantAccessToTables(mockAugment);
            world.call(
                world.getAugmentInstallSystemResource(testNamespace),
                abi.encodeWithSignature(
                    "installAugment(address,bytes)",
                    mockAugment,
                    abi.encode(componentValues)
                )
            );
        }

        uint256 augmentKey = UniqueEntity.get(UNIQUE_ENTITY_TABLE_ID);

        {
            AugmentComponentValue[][]
                memory componentValues = new AugmentComponentValue[][](1);

            (
                bytes memory staticData,
                EncodedLengths encodedLengths,
                bytes memory dynamicData
            ) = ScaleCom.encode(2, 4, 6);
            componentValues[0] = new AugmentComponentValue[](1);
            componentValues[0][0] = AugmentComponentValue(
                staticData,
                encodedLengths,
                dynamicData
            );

            world.call(
                world.getAugmentInstallSystemResource(testNamespace),
                abi.encodeWithSignature(
                    "uninstallAugment(bytes32)",
                    bytes32(augmentKey)
                )
            );
        }

        vm.stopPrank();

        uint256 entityId1 = augmentKey - 2;
        uint256 entityId2 = entityId1 + 1;

        assertEq(
            ScaleCom.getX(world, _scaleTableId, bytes32(entityId1)),
            0,
            "Scale X should be deleted"
        );
        assertEq(
            ScaleCom.getY(world, _scaleTableId, bytes32(entityId1)),
            0,
            "Scale Y should be deleted"
        );
        assertEq(
            ScaleCom.getZ(world, _scaleTableId, bytes32(entityId1)),
            0,
            "Scale Z should be deleted"
        );
        assertEq(
            NameCom.get(world, _nameTableId, bytes32(entityId2)),
            "",
            "Name should be deleted"
        );
        assertEq(
            Augments.lengthInstalledEntities(
                world,
                AugmentInstallLib.getAugmentsTableId(
                    WorldResourceIdLib.encodeNamespace(testNamespace)
                ),
                bytes32(augmentKey)
            ),
            0,
            "Augment should be uninstalled"
        );
        assertEq(
            UniqueEntity.get(UNIQUE_ENTITY_TABLE_ID),
            augmentKey,
            "Should not create new entities"
        );
    }

    function testUninstallAugment_SpliceOverride() public {
        MockAugmentSpliceOverride mockAugment = new MockAugmentSpliceOverride();

        ResourceId _scaleTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    testNamespace,
                    bytes16(bytes32("ScaleCom"))
                )
            )
        );

        vm.startPrank(address(0x1));

        {
            AugmentComponentValue[][]
                memory componentValues = new AugmentComponentValue[][](1);

            (
                bytes memory staticData,
                EncodedLengths encodedLengths,
                bytes memory dynamicData
            ) = ScaleCom.encode(1, 2, 3);
            componentValues[0] = new AugmentComponentValue[](1);
            componentValues[0][0] = AugmentComponentValue(
                staticData,
                encodedLengths,
                dynamicData
            );

            grantAccessToTables(mockAugment);
            world.call(
                world.getAugmentInstallSystemResource(testNamespace),
                abi.encodeWithSignature(
                    "installAugment(address,bytes)",
                    mockAugment,
                    abi.encode(componentValues)
                )
            );
        }

        uint256 augmentKey = UniqueEntity.get(UNIQUE_ENTITY_TABLE_ID);

        {
            AugmentComponentValue[][]
                memory componentValues = new AugmentComponentValue[][](1);

            (
                bytes memory staticData,
                EncodedLengths encodedLengths,
                bytes memory dynamicData
            ) = ScaleCom.encode(2, 4, 6);
            componentValues[0] = new AugmentComponentValue[](1);
            componentValues[0][0] = AugmentComponentValue(
                staticData,
                encodedLengths,
                dynamicData
            );

            world.call(
                world.getAugmentInstallSystemResource(testNamespace),
                abi.encodeWithSignature(
                    "uninstallAugment(bytes32)",
                    bytes32(augmentKey)
                )
            );
        }

        vm.stopPrank();

        uint256 entityId1 = augmentKey - 1;

        assertEq(
            ScaleCom.getX(world, _scaleTableId, bytes32(entityId1)),
            0,
            "Scale X should be deleted"
        );
        assertEq(
            ScaleCom.getY(world, _scaleTableId, bytes32(entityId1)),
            0,
            "Scale Y should be deleted"
        );
        assertEq(
            ScaleCom.getZ(world, _scaleTableId, bytes32(entityId1)),
            0,
            "Scale Z should be deleted"
        );
        assertEq(
            Augments.lengthInstalledEntities(
                world,
                AugmentInstallLib.getAugmentsTableId(
                    WorldResourceIdLib.encodeNamespace(testNamespace)
                ),
                bytes32(augmentKey)
            ),
            0,
            "Augment should be uninstalled"
        );
        assertEq(
            UniqueEntity.get(UNIQUE_ENTITY_TABLE_ID),
            augmentKey,
            "Should not create new entities"
        );
    }
}

contract MockAugmentSingle is Augment {
    bytes16[][] private componentTypes = [[bytes16(bytes32("ScaleCom"))]];

    function onBeforeInstall(IStore store, bytes14 namespace) external {}

    function getMetadataURI() external view returns (string memory) {
        return "";
    }

    function getComponentTypes() external view returns (bytes16[][] memory) {
        return componentTypes;
    }

    function getRequiredPermissions() external view returns (bytes16[] memory) {
        return new bytes16[](0);
    }

    function installOverrides(
        IStore store,
        bytes14 namespace,
        bytes32 keyOffset
    ) external {}

    function uninstallOverrides(
        IStore store,
        bytes14 namespace,
        bytes32 keyOffset
    ) external {}
}

contract MockAugmentMultipleComponents is Augment {
    bytes16[][] private componentTypes = [
        [bytes16(bytes32("ScaleCom")), bytes16(bytes32("NameCom"))]
    ];

    function onBeforeInstall(IStore store, bytes14 namespace) external {}

    function getMetadataURI() external view returns (string memory) {
        return "";
    }

    function getComponentTypes() external view returns (bytes16[][] memory) {
        return componentTypes;
    }

    function getRequiredPermissions() external view returns (bytes16[] memory) {
        return new bytes16[](0);
    }

    function installOverrides(
        IStore store,
        bytes14 namespace,
        bytes32 keyOffset
    ) external {}

    function uninstallOverrides(
        IStore store,
        bytes14 namespace,
        bytes32 keyOffset
    ) external {}
}

contract MockAugmentMultipleEntities is Augment {
    bytes16[][] private componentTypes = [
        [bytes16(bytes32("ScaleCom"))],
        [bytes16(bytes32("NameCom"))]
    ];

    function onBeforeInstall(IStore store, bytes14 namespace) external {}

    function getMetadataURI() external view returns (string memory) {
        return "";
    }

    function getComponentTypes() external view returns (bytes16[][] memory) {
        return componentTypes;
    }

    function getRequiredPermissions() external view returns (bytes16[] memory) {
        return new bytes16[](0);
    }

    function installOverrides(
        IStore store,
        bytes14 namespace,
        bytes32 keyOffset
    ) external {}

    function uninstallOverrides(
        IStore store,
        bytes14 namespace,
        bytes32 keyOffset
    ) external {}
}

contract MockAugmentSetOverride is Augment {
    bytes16[][] private componentTypes = [[bytes16(bytes32("ScaleCom"))]];

    function onBeforeInstall(IStore store, bytes14 namespace) external {}

    function getMetadataURI() external view returns (string memory) {
        return "";
    }

    function getComponentTypes() external view returns (bytes16[][] memory) {
        return componentTypes;
    }

    function getRequiredPermissions() external view returns (bytes16[] memory) {
        bytes16[] memory tables = new bytes16[](1);
        tables[0] = bytes16(bytes32("NameCom"));
        return tables;
    }

    function installOverrides(
        IStore store,
        bytes14 namespace,
        bytes32 keyOffset
    ) external {
        uint256 lastKey = UniqueEntity.get(store, UNIQUE_ENTITY_TABLE_ID);
        bytes32 key;
        if (lastKey == uint256(keyOffset)) {
            key = getUniqueEntity(IBaseWorld(address(store)));
        } else {
            key = bytes32(uint256(keyOffset) + 1);
        }
        ResourceId _nameTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    namespace,
                    bytes16(bytes32("NameCom"))
                )
            )
        );
        NameCom.set(store, _nameTableId, key, "test1");
    }

    function uninstallOverrides(
        IStore store,
        bytes14 namespace,
        bytes32 keyOffset
    ) external {
        bytes32 key = bytes32(uint256(keyOffset) + 1);

        ResourceId _nameTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    namespace,
                    bytes16(bytes32("NameCom"))
                )
            )
        );
        NameCom.deleteRecord(store, _nameTableId, key);
    }
}

contract MockAugmentSpliceOverride is Augment {
    bytes16[][] private componentTypes = [[bytes16(bytes32("ScaleCom"))]];

    function onBeforeInstall(IStore store, bytes14 namespace) external {}

    function getMetadataURI() external view returns (string memory) {
        return "";
    }

    function getComponentTypes() external view returns (bytes16[][] memory) {
        return componentTypes;
    }

    function getRequiredPermissions() external view returns (bytes16[] memory) {
        bytes16[] memory tables = new bytes16[](1);
        tables[0] = bytes16(bytes32("ScaleCom"));
        return tables;
    }

    function installOverrides(
        IStore store,
        bytes14 namespace,
        bytes32 keyOffset
    ) external {
        ResourceId _scaleTableId = ResourceId.wrap(
            bytes32(
                abi.encodePacked(
                    RESOURCE_TABLE,
                    namespace,
                    bytes16(bytes32("ScaleCom"))
                )
            )
        );
        ScaleCom.setX(store, _scaleTableId, keyOffset, 10);
    }

    function uninstallOverrides(
        IStore store,
        bytes14 namespace,
        bytes32 keyOffset
    ) external {}
}

contract MockAugmentSingleGated is Augment {
    error InstallFailed();

    bytes16[][] private componentTypes = [[bytes16(bytes32("ScaleCom"))]];

    function onBeforeInstall(IStore store, bytes14 namespace) external {
        revert InstallFailed();
    }

    function getMetadataURI() external view returns (string memory) {
        return "";
    }

    function getComponentTypes() external view returns (bytes16[][] memory) {
        return componentTypes;
    }

    function getRequiredPermissions() external view returns (bytes16[] memory) {
        return new bytes16[](0);
    }

    function installOverrides(
        IStore store,
        bytes14 namespace,
        bytes32 keyOffset
    ) external {}

    function uninstallOverrides(
        IStore store,
        bytes14 namespace,
        bytes32 keyOffset
    ) external {}
}
