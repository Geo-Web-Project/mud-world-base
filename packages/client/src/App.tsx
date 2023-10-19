import { useComponentValue, useEntityQuery } from "@latticexyz/react";
import { useMUD, getComponentForParcel } from "@geo-web/mud-world-base-setup";
import { singletonEntity } from "@latticexyz/store-sync/recs";
import { Has, getComponentValueStrict } from "@latticexyz/recs";
import mudConfig from "@geo-web/mud-world-base-contracts/mud.config";

export const App = () => {
  const {
    components: { NameComponent },
  } = useMUD();

  const nameComponent = getComponentForParcel(NameComponent, 320);
  const nameComponents = useEntityQuery([Has(nameComponent)]);

  console.log(nameComponents);

  return <>Hello World</>;
};
