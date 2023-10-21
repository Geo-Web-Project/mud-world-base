import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  enums: {
    ImageEncodingFormat: ["Jpeg", "Png", "Svg"],
    ModelEncodingFormat: ["Glb", "Usdz"],
    AudioEncodingFormat: ["Mpeg", "Mp4", "Mp3"],
    VideoEncodingFormat: ["Mpeg", "Mp4"],
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
    // {
    //   name: "PCOOwnershipModule",
    //   root: true,
    //   args: [
    //     {
    //       type: "address",
    //       value: "0xBA1231785A7b4AC0E8dC9a0403938C2182cE4A4e",
    //     },
    //   ],
    // },
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
    },
    Augments: {
      directory: "../modules/augmentinstallation/tables",
      keySchema: {
        augmentAddress: "address",
        argumentsHash: "bytes32", // Hash of the params passed to the `install` function
      },
      valueSchema: {
        augmentMetadata: "bytes",
      },
      tableIdArgument: true,
    },
    NameCom: {
      valueSchema: "string",
      tableIdArgument: true,
    },
    ModelCom: {
      valueSchema: {
        encodingFormat: "ModelEncodingFormat",
        contentHash: "bytes",
      },
      tableIdArgument: true,
    },
    ImageCom: {
      valueSchema: {
        encodingFormat: "ImageEncodingFormat",
        contentHash: "bytes",
      },
      tableIdArgument: true,
    },
    AudioCom: {
      valueSchema: {
        encodingFormat: "AudioEncodingFormat",
        contentHash: "bytes",
      },
      tableIdArgument: true,
    },
    VideoCom: {
      valueSchema: {
        encodingFormat: "VideoEncodingFormat",
        contentHash: "bytes",
      },
      tableIdArgument: true,
    },
    PositionCom: {
      valueSchema: { h: "int32", geohash: "bytes" },
      tableIdArgument: true,
    },
    OrientationCom: {
      valueSchema: { x: "int16", y: "int16", z: "int16", w: "int16" },
      tableIdArgument: true,
    },
    ScaleCom: {
      valueSchema: { x: "int16", y: "int16", z: "int16" },
      tableIdArgument: true,
    },
    TrackedImageCom: {
      valueSchema: {
        physicalWidthInMillimeters: "uint16",
        encodingFormat: "ImageEncodingFormat",
        imageAsset: "bytes",
      },
      tableIdArgument: true,
    },
  },
});
