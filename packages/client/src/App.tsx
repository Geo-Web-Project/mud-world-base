import { useComponentValue, useEntityQuery } from "@latticexyz/react";
import { useMUD } from "./MUDContext";
import { singletonEntity } from "@latticexyz/store-sync/recs";
import { Has, getComponentValueStrict } from "@latticexyz/recs";

export const App = () => {
  const {
    components: { Name, MediaObject },
  } = useMUD();

  const name = useComponentValue(Name, singletonEntity);
  const mediaObjects = useEntityQuery([Has(MediaObject)])

  return (
    <>
      <div>
        Name: <span>{name?.value ?? "??"}</span>
      </div>
      <div>
      {mediaObjects.map(mediaObject => (
        <p>{getComponentValueStrict(MediaObject, mediaObject).name}</p>
      ))}
      </div>
    </>
  );
};
