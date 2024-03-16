import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  enums: {
    // ImageEncodingFormat: ["Jpeg", "Png", "Svg"],
    ModelEncodingFormat: ["Glb", "Usdz"],
    // AudioEncodingFormat: ["Mpeg", "Mp4", "Mp3"],
    // VideoEncodingFormat: ["Mpeg", "Mp4"],
  },
  userTypes: {
    ResourceId: {
      filePath: "@latticexyz/store/src/ResourceId.sol",
      internalType: "bytes32",
    },
  },
  modules: [
    {
      name: "UniqueEntityModule",
      root: true,
    },
  ],
  tables: {
    PCOOwnership: {
      directory: "../modules/pcoownership/tables",
      keySchema: {
        namespaceId: "ResourceId",
      },
      valueSchema: {
        exists: "bool",
        parcelId: "uint256",
      },
      tableIdArgument: true,
      storeArgument: true,
    },
    Augments: {
      directory: "../modules/augmentinstallation/tables",
      valueSchema: {
        augmentAddress: "address",
        argumentsHash: "bytes32", // Hash of the params passed to the `install` function
        augmentMetadataURI: "string",
        installedEntities: "bytes32[]",
      },
      tableIdArgument: true,
      storeArgument: true,
    },
    NameCom: {
      valueSchema: "string",
      tableIdArgument: true,
      storeArgument: true,
    },
    ModelCom: {
      valueSchema: {
        encodingFormat: "ModelEncodingFormat",
        contentURI: "string",
      },
      tableIdArgument: true,
      storeArgument: true,
    },
    PositionCom: {
      valueSchema: { h: "int32", geohash: "string" },
      tableIdArgument: true,
      storeArgument: true,
    },
    OrientationCom: {
      valueSchema: { x: "int16", y: "int16", z: "int16", w: "int16" },
      tableIdArgument: true,
      storeArgument: true,
    },
    ScaleCom: {
      valueSchema: { x: "int16", y: "int16", z: "int16" },
      tableIdArgument: true,
      storeArgument: true,
    },
    // ImageCom: {
    //   valueSchema: {
    //     encodingFormat: "ImageEncodingFormat",
    //     physicalWidthInMillimeters: "uint16",
    //     contentURI: "string",
    //   },
    //   tableIdArgument: true,
    //   storeArgument: true,
    // },
    // AudioCom: {
    //   valueSchema: {
    //     encodingFormat: "AudioEncodingFormat",
    //     contentURI: "string",
    //   },
    //   tableIdArgument: true,
    // },
    // VideoCom: {
    //   valueSchema: {
    //     encodingFormat: "VideoEncodingFormat",
    //     contentURI: "string",
    //   },
    //   tableIdArgument: true,
    // },
    // TrackedImageCom: {
    //   valueSchema: {
    //     physicalWidthInMillimeters: "uint16",
    //     encodingFormat: "ImageEncodingFormat",
    //     imageAsset: "bytes",
    //   },
    //   tableIdArgument: true,
    // },
    // NFTCom: {
    //   valueSchema: {
    //     chainId: "uint64",
    //     tokenAddress: "address",
    //     tokenId: "uint256",
    //   },
    //   tableIdArgument: true,
    // },
  },
});
