import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  namespace: "geoweb",
  enums: {
    MediaObjectType: ["Image", "Audio", "Video", "Model3D"],
    EncodingFormat: [
      "Glb",
      "Usdz",
      "Gif",
      "Jpeg",
      "Png",
      "Svg",
      "Mpeg",
      "Mp4",
      "Mp3",
    ],
  },
  modules: [
    {
      name: "UniqueEntityModule",
      root: true,
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("MediaObject")],
    },
  ],
  tables: {
    Name: {
      keySchema: {},
      schema: "string",
    },
    Url: {
      keySchema: {},
      schema: "string",
    },
    MediaObject: {
      schema: {
        contentSize: "uint64",
        mediaType: "MediaObjectType",
        encodingFormat: "EncodingFormat",
        name: "string",
        contentHash: "bytes",
      },
    },
    PositionComponent: {
      schema: { x: "int32", y: "int32", z: "int32" },
    },
    ScaleComponent: {
      schema: { x: "int32", y: "int32", z: "int32" },
    },
    OrientationComponent: {
      schema: { x: "int32", y: "int32", z: "int32", w: "int32" },
    },
    Model3DComponent: {
      schema: { usdz: "bytes" },
    },
    IsAnchorComponent: "bool",
    TrackedImageComponent: {
      schema: { physicalWidthInMeters: "uint32", imageAsset: "bytes" },
    },
    AnchorComponent: {
      schema: {
        anchor: "bytes32",
        position: "bytes",
        orientation: "bytes",
      },
    },
  },
});
