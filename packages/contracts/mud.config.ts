import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  enums: {
    // ImageEncodingFormat: ["Jpeg", "Png", "Svg"],
    ModelEncodingFormat: ["Glb", "Usdz"],
    // AudioEncodingFormat: ["Mpeg", "Mp4", "Mp3"],
    // VideoEncodingFormat: ["Mpeg", "Mp4"],
  },
  userTypes: {
    ResourceId: {
      type: "bytes32",
      filePath: "@latticexyz/store/src/ResourceId.sol",
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
      key: ["namespaceId"],
      schema: {
        namespaceId: "ResourceId",
        exists: "bool",
        parcelId: "uint256",
      },
      codegen: {
        outputDirectory: "../modules/pcoownership/tables",
        tableIdArgument: true,
        storeArgument: true,
      },
    },
    Augments: {
      schema: {
        key: "bytes32",
        augmentAddress: "address",
        argumentsHash: "bytes32", // Hash of the params passed to the `install` function
        augmentMetadataURI: "string",
        installedEntities: "bytes32[]",
      },
      key: ["key"],
      codegen: {
        outputDirectory: "../modules/augmentinstallation/tables",
        tableIdArgument: true,
        storeArgument: true,
      },
    },
    NameCom: {
      schema: {
        key: "bytes32",
        value: "string",
      },
      key: ["key"],
      codegen: {
        tableIdArgument: true,
        storeArgument: true,
      },
    },
    ModelCom: {
      schema: {
        key: "bytes32",
        encodingFormat: "ModelEncodingFormat",
        contentURI: "string",
      },
      key: ["key"],
      codegen: {
        tableIdArgument: true,
        storeArgument: true,
      },
    },
    PositionCom: {
      schema: { key: "bytes32", h: "int32", geohash: "string" },
      key: ["key"],
      codegen: {
        tableIdArgument: true,
        storeArgument: true,
      },
    },
    OrientationCom: {
      schema: {
        key: "bytes32",
        x: "int16",
        y: "int16",
        z: "int16",
        w: "int16",
      },
      key: ["key"],
      codegen: {
        tableIdArgument: true,
        storeArgument: true,
      },
    },
    ScaleCom: {
      schema: { key: "bytes32", x: "int16", y: "int16", z: "int16" },
      key: ["key"],
      codegen: {
        tableIdArgument: true,
        storeArgument: true,
      },
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
