import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  namespace: "geoweb",
  enums: {
    ImageEncodingFormat: ["Jpeg", "Png", "Svg"],
    ModelEncodingFormat: ["Glb", "Usdz"],
    AudioEncodingFormat: ["Mpeg", "Mp4", "Mp3"],
    VideoEncodingFormat: ["Mpeg", "Mp4", "Mp3"],
  },
  modules: [
    {
      name: "UniqueEntityModule",
      root: true,
    },
    {
      name: "PCOOwnershipModule",
      root: true,
      args: [
        {
          type: "address",
          value: "0xBA1231785A7b4AC0E8dC9a0403938C2182cE4A4e",
        },
      ],
    },
  ],
  tables: {
    ModelComponent: {
      valueSchema: {
        encodingFormat: "ModelEncodingFormat",
        contentHash: "bytes",
      },
    },
    ImageComponent: {
      valueSchema: {
        encodingFormat: "ImageEncodingFormat",
        contentHash: "bytes",
      },
    },
    AudioComponent: {
      valueSchema: {
        encodingFormat: "AudioEncodingFormat",
        contentHash: "bytes",
      },
    },
    VideoComponent: {
      valueSchema: {
        encodingFormat: "VideoEncodingFormat",
        contentHash: "bytes",
      },
    },
    PositionComponent: {
      valueSchema: { h: "int32", geohash: "bytes" },
    },
    OrientationQuaternionComponent: {
      valueSchema: { x: "int16", y: "int16", z: "int16", w: "int16" },
    },
    ScaleComponent: {
      valueSchema: { x: "int16", y: "int16", z: "int16" },
    },
    TrackedImageComponent: {
      valueSchema: {
        physicalWidthInMillimeters: "uint16",
        encodingFormat: "ImageEncodingFormat",
        imageAsset: "bytes",
      },
    },
  },
});
