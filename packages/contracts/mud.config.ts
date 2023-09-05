import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  namespace: "geoweb",
  enums: {
    MediaObjectType: ["Image", "Audio", "Video", "Model"],
    MediaObjectEncodingFormat: [
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
    ImageEncodingFormat: ["Jpeg", "Png", "Svg"],
    ModelEncodingFormat: ["Glb", "Usdz"],
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
        encodingFormat: "MediaObjectEncodingFormat",
        name: "string",
        contentHash: "bytes",
      },
    },
    PositionComponent: {
      schema: { x: "int16", y: "int16", z: "int16" },
    },
    ScaleComponent: {
      schema: { x: "int16", y: "int16", z: "int16" },
    },
    OrientationComponent: {
      schema: { x: "int16", y: "int16", z: "int16", w: "int16" },
    },
    ModelComponent: {
      schema: { encodingFormat: "ModelEncodingFormat", contentHash: "bytes" },
    },
    TrackedImageComponent: {
      schema: {
        physicalWidthInMillimeters: "uint16",
        encodingFormat: "ImageEncodingFormat",
        imageAsset: "bytes",
      },
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
