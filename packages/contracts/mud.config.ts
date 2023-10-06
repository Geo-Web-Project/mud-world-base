import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  enums: {
    ImageEncodingFormat: ["Jpeg", "Png", "Svg"],
    ModelEncodingFormat: ["Glb", "Usdz"],
    AudioEncodingFormat: ["Mpeg", "Mp4", "Mp3"],
    VideoEncodingFormat: ["Mpeg", "Mp4", "Mp3"],
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
    ModelComponent: {
      valueSchema: {
        encodingFormat: "ModelEncodingFormat",
        contentHash: "bytes",
      },
      tableIdArgument: true,
    },
    ImageComponent: {
      valueSchema: {
        encodingFormat: "ImageEncodingFormat",
        contentHash: "bytes",
      },
      tableIdArgument: true,
    },
    AudioComponent: {
      valueSchema: {
        encodingFormat: "AudioEncodingFormat",
        contentHash: "bytes",
      },
      tableIdArgument: true,
    },
    VideoComponent: {
      valueSchema: {
        encodingFormat: "VideoEncodingFormat",
        contentHash: "bytes",
      },
      tableIdArgument: true,
    },
    PositionComponent: {
      valueSchema: { h: "int32", geohash: "bytes" },
      tableIdArgument: true,
    },
    OrientationQuaternionComponent: {
      valueSchema: { x: "int16", y: "int16", z: "int16", w: "int16" },
      tableIdArgument: true,
    },
    ScaleComponent: {
      valueSchema: { x: "int16", y: "int16", z: "int16" },
      tableIdArgument: true,
    },
    TrackedImageComponent: {
      valueSchema: {
        physicalWidthInMillimeters: "uint16",
        encodingFormat: "ImageEncodingFormat",
        imageAsset: "bytes",
      },
      tableIdArgument: true,
    },
  },
});
