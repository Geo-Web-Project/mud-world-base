import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  namespace: "geoweb",
  tables: {
    Name: {
      keySchema: {},
      schema: "string",
    },
    Url: {
      keySchema: {},
      schema: "string",
    },
  },
});
