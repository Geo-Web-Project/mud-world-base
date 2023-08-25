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
  },
});
