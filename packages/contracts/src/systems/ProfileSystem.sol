// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Name, Url } from "../codegen/Tables.sol";

contract ProfileSystem is System {
  /*
   * @dev - Set name
   */
  function setName(string calldata name) public {
    Name.set(name);
  }

  /*
   * @dev - Set URL
   */
  function setUrl(string calldata url) public {
    Url.set(url);
  }
}
