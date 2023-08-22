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
                contentHash: hex"e3010182041220ab3df0316897c82f117f079bcd3466d439a3a87eff3fdaf6f6ebdee27c315bf5",
                contentSize: 33649,
                encodingFormat: EncodingFormat.Png
            })
        );
        IWorld(worldAddress).geoweb_MediaGallerySyst_addToMediaGallery(
            MediaObjectData({
                name: "Buddha",
                mediaType: MediaObjectType.Model3D,
                contentHash: hex"e3010182041220af0a748b2ccc91ee6ad3d7a6b75ab22a9418f2bdc8ee7e9cb2c6613036027027",
                contentSize: 22712008,
                encodingFormat: EncodingFormat.Usdz
            })
        );

        vm.stopBroadcast();
    }
}
