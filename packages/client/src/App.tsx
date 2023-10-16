import { useComponentValue, useEntityQuery } from "@latticexyz/react";
import { useMUD } from "@geo-web/mud-world-base-setup";
import { singletonEntity } from "@latticexyz/store-sync/recs";
import { Has, getComponentValueStrict } from "@latticexyz/recs";

export const App = () => {
  const {
    components: { NameComponent },
  } = useMUD();

  return <>Hello World</>;
};
