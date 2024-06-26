// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {IAugment} from "./IAugment.sol";
import {System} from "@latticexyz/world/src/System.sol";
import {WorldContextProviderLib} from "@latticexyz/world/src/WorldContext.sol";
import {Augments, AugmentsData} from "./tables/Augments.sol";
import {requireInterface} from "@latticexyz/world/src/requireInterface.sol";
import {RESOURCE_TABLE} from "@latticexyz/world/src/worldResourceTypes.sol";
import {ResourceId, WorldResourceIdInstance, WorldResourceIdLib} from "@latticexyz/world/src/WorldResourceId.sol";
import {getUniqueEntity} from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";
import {EncodedLengths} from "@latticexyz/store/src/EncodedLengths.sol";
import {AccessControl} from "@latticexyz/world/src/AccessControl.sol";
import {Utils} from "@latticexyz/world/src/Utils.sol";
import {StoreSwitch} from "@latticexyz/store/src/StoreSwitch.sol";
import {IStore} from "@latticexyz/store/src/IStore.sol";

struct AugmentComponentValue {
    bytes staticData;
    EncodedLengths encodedLengths;
    bytes dynamicData;
}

/**
 * @title Augment Installation System
 * @dev A system contract to handle the installation of Augments in the World.
 */
contract AugmentInstallSystem is System {
    /**
     * @notice Installs an augment into the World under a specified namespace.
     * @dev Validates the given augment against the IAugment interface and delegates the installation process.
     * The augment is then registered in the InstalledAugment table.
     * @param augment The augment to be installed.
     * @param args Arguments for the augment installation.
     */
    function installAugment(IAugment augment, bytes calldata args) public {
        bytes14 namespace = Utils.systemNamespace();

        // Require the provided address to implement the IAugment interface
        requireInterface(address(augment), type(IAugment).interfaceId);

        // Before install hook
        augment.onBeforeInstall(IStore(_world()), namespace);

        // Parse args and set records
        bytes16[][] memory augmentTypes = augment.getComponentTypes();
        AugmentComponentValue[][] memory componentValues = abi.decode(
            args,
            (AugmentComponentValue[][])
        );

        bytes32[] memory newEntities = new bytes32[](componentValues.length);

        for (uint256 x = 0; x < componentValues.length; x++) {
            bytes32 key = getUniqueEntity();
            newEntities[x] = key;

            bytes32[] memory _keyTuple = new bytes32[](1);
            _keyTuple[0] = key;

            for (uint256 y = 0; y < componentValues[x].length; y++) {
                ResourceId tableId = ResourceId.wrap(
                    bytes32(
                        abi.encodePacked(
                            RESOURCE_TABLE,
                            namespace,
                            augmentTypes[x][y]
                        )
                    )
                );
                StoreSwitch.setRecord(
                    tableId,
                    _keyTuple,
                    componentValues[x][y].staticData,
                    componentValues[x][y].encodedLengths,
                    componentValues[x][y].dynamicData
                );
            }
        }

        // Perform augment overrides
        augment.installOverrides(IStore(_world()), namespace, newEntities[0]);

        // Register the augment in the Augments table
        bytes32 augmentKey = getUniqueEntity();
        Augments.set(
            AugmentInstallLib.getAugmentsTableId(
                WorldResourceIdLib.encodeNamespace(namespace)
            ),
            augmentKey,
            address(augment),
            keccak256(args),
            augment.getMetadataURI(),
            newEntities
        );
        Augments.setInstalledEntities(
            AugmentInstallLib.getAugmentsTableId(
                WorldResourceIdLib.encodeNamespace(namespace)
            ),
            augmentKey,
            newEntities
        );
    }

    /**
     * @notice Updates an already installed augment.
     * @dev Validates the given augment against the IAugment interface and delegates the installation process.
     * @param augmentKey The key of the previously installed augment
     * @param args Arguments for the augment installation.
     */
    function updateAugment(bytes32 augmentKey, bytes calldata args) public {
        bytes14 namespace = Utils.systemNamespace();

        AugmentsData memory augmentsData = Augments.get(
            AugmentInstallLib.getAugmentsTableId(
                WorldResourceIdLib.encodeNamespace(namespace)
            ),
            augmentKey
        );

        IAugment augment = IAugment(augmentsData.augmentAddress);

        // Require the provided address to implement the IAugment interface
        requireInterface(address(augment), type(IAugment).interfaceId);

        // Parse args and update records
        bytes16[][] memory augmentTypes = augment.getComponentTypes();
        AugmentComponentValue[][] memory componentValues = abi.decode(
            args,
            (AugmentComponentValue[][])
        );

        bytes32[] memory installedEntities = augmentsData.installedEntities;

        require(
            componentValues.length == installedEntities.length,
            "AugmentInstallationSystem: incorrect keys length"
        );

        for (uint256 x = 0; x < componentValues.length; x++) {
            bytes32 key = installedEntities[x];

            bytes32[] memory _keyTuple = new bytes32[](1);
            _keyTuple[0] = key;

            for (uint256 y = 0; y < componentValues[x].length; y++) {
                ResourceId tableId = ResourceId.wrap(
                    bytes32(
                        abi.encodePacked(
                            RESOURCE_TABLE,
                            namespace,
                            augmentTypes[x][y]
                        )
                    )
                );
                StoreSwitch.setRecord(
                    tableId,
                    _keyTuple,
                    componentValues[x][y].staticData,
                    componentValues[x][y].encodedLengths,
                    componentValues[x][y].dynamicData
                );
            }
        }

        // Perform augment overrides
        augment.installOverrides(
            IStore(_world()),
            namespace,
            installedEntities[0]
        );
    }

    /**
     * @notice Uninstalls an already installed augment.
     * @dev Validates the given augment against the IAugment interface and delegates the installation process.
     * @param augmentKey The key of the previously installed augment
     */
    function uninstallAugment(bytes32 augmentKey) public {
        bytes14 namespace = Utils.systemNamespace();

        AugmentsData memory augmentsData = Augments.get(
            AugmentInstallLib.getAugmentsTableId(
                WorldResourceIdLib.encodeNamespace(namespace)
            ),
            augmentKey
        );

        IAugment augment = IAugment(augmentsData.augmentAddress);

        // Require the provided address to implement the IAugment interface
        requireInterface(address(augment), type(IAugment).interfaceId);

        // Parse args and update records
        bytes16[][] memory augmentTypes = augment.getComponentTypes();
        bytes32[] memory installedEntities = augmentsData.installedEntities;

        require(
            augmentTypes.length == installedEntities.length,
            "AugmentInstallationSystem: incorrect keys length"
        );

        for (uint256 x = 0; x < augmentTypes.length; x++) {
            bytes32 key = installedEntities[x];
            bytes32[] memory _keyTuple = new bytes32[](1);
            _keyTuple[0] = key;
            for (uint256 y = 0; y < augmentTypes[x].length; y++) {
                ResourceId tableId = ResourceId.wrap(
                    bytes32(
                        abi.encodePacked(
                            RESOURCE_TABLE,
                            namespace,
                            augmentTypes[x][y]
                        )
                    )
                );
                StoreSwitch.deleteRecord(tableId, _keyTuple);
            }
        }
        // Perform augment overrides
        augment.uninstallOverrides(
            IStore(_world()),
            namespace,
            installedEntities[0]
        );

        // Uninstall
        Augments.setInstalledEntities(
            AugmentInstallLib.getAugmentsTableId(
                WorldResourceIdLib.encodeNamespace(namespace)
            ),
            augmentKey,
            new bytes32[](0)
        );
    }
}

library AugmentInstallLib {
    /**
     * @notice Get table Id for Augments in a particular namespace
     */
    function getAugmentsTableId(
        ResourceId namespaceId
    ) internal pure returns (ResourceId) {
        return
            ResourceId.wrap(
                bytes32(
                    abi.encodePacked(
                        RESOURCE_TABLE,
                        WorldResourceIdInstance.getNamespace(namespaceId),
                        bytes16("Augments")
                    )
                )
            );
    }
}
