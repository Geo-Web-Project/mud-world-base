import { useComponentValue } from "@latticexyz/react";
import { useMUD } from "./MUDContext";
import { useState } from "react";

export const App = () => {
  const {
    components: { Name, Url },
    systemCalls: { setName, setUrl },
    network: { singletonEntity },
  } = useMUD();

  const name = useComponentValue(Name, singletonEntity);
  const url = useComponentValue(Url, singletonEntity);

  const [newName, setNewName] = useState<string>(name?.value ?? "");
  const [newUrl, setNewUrl] = useState<string>(url?.value ?? "");

  function handleNameChange(event: React.ChangeEvent<HTMLInputElement>) {
    setNewName(event.target.value);
  }

  function handleUrlChange(event: React.ChangeEvent<HTMLInputElement>) {
    setNewUrl(event.target.value);
  }

  return (
    <>
      <div>
        Name: <span>{name?.value ?? "??"}</span>
        <br />
        Url: <span>{url?.value ?? "??"}</span>
      </div>
      <input type="text" placeholder="New name" onChange={handleNameChange} value={newName}></input>
      <br />
      <input type="text" placeholder="New url" onChange={handleUrlChange} value={newUrl}></input>
      <br />
      <button
        type="button"
        onClick={async (event) => {
          event.preventDefault();
          await setName(newName);
          await setUrl(newUrl);
        }}
      >
        Save
      </button>
    </>
  );
};
