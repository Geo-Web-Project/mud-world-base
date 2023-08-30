// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

// Import schema type
import { SchemaType } from "@latticexyz/schema-type/src/solidity/SchemaType.sol";

// Import store internals
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { StoreCore } from "@latticexyz/store/src/StoreCore.sol";
import { Bytes } from "@latticexyz/store/src/Bytes.sol";
import { Memory } from "@latticexyz/store/src/Memory.sol";
import { SliceLib } from "@latticexyz/store/src/Slice.sol";
import { EncodeArray } from "@latticexyz/store/src/tightcoder/EncodeArray.sol";
import { Schema, SchemaLib } from "@latticexyz/store/src/Schema.sol";
import { PackedCounter, PackedCounterLib } from "@latticexyz/store/src/PackedCounter.sol";

bytes32 constant _tableId = bytes32(abi.encodePacked(bytes16("geoweb"), bytes16("ScaleComponent")));
bytes32 constant ScaleComponentTableId = _tableId;

struct ScaleComponentData {
  int32 x;
  int32 y;
  int32 z;
}

library ScaleComponent {
  /** Get the table's schema */
  function getSchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](3);
    _schema[0] = SchemaType.INT32;
    _schema[1] = SchemaType.INT32;
    _schema[2] = SchemaType.INT32;

    return SchemaLib.encode(_schema);
  }

  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](1);
    _schema[0] = SchemaType.BYTES32;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's metadata */
  function getMetadata() internal pure returns (string memory, string[] memory) {
    string[] memory _fieldNames = new string[](3);
    _fieldNames[0] = "x";
    _fieldNames[1] = "y";
    _fieldNames[2] = "z";
    return ("ScaleComponent", _fieldNames);
  }

  /** Register the table's schema */
  function registerSchema() internal {
    StoreSwitch.registerSchema(_tableId, getSchema(), getKeySchema());
  }

  /** Register the table's schema (using the specified store) */
  function registerSchema(IStore _store) internal {
    _store.registerSchema(_tableId, getSchema(), getKeySchema());
  }

  /** Set the table's metadata */
  function setMetadata() internal {
    (string memory _tableName, string[] memory _fieldNames) = getMetadata();
    StoreSwitch.setMetadata(_tableId, _tableName, _fieldNames);
  }

  /** Set the table's metadata (using the specified store) */
  function setMetadata(IStore _store) internal {
    (string memory _tableName, string[] memory _fieldNames) = getMetadata();
    _store.setMetadata(_tableId, _tableName, _fieldNames);
  }

  /** Get x */
  function getX(bytes32 key) internal view returns (int32 x) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 0);
    return (int32(uint32(Bytes.slice4(_blob, 0))));
  }

  /** Get x (using the specified store) */
  function getX(IStore _store, bytes32 key) internal view returns (int32 x) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 0);
    return (int32(uint32(Bytes.slice4(_blob, 0))));
  }

  /** Set x */
  function setX(bytes32 key, int32 x) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    StoreSwitch.setField(_tableId, _keyTuple, 0, abi.encodePacked((x)));
  }

  /** Set x (using the specified store) */
  function setX(IStore _store, bytes32 key, int32 x) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    _store.setField(_tableId, _keyTuple, 0, abi.encodePacked((x)));
  }

  /** Get y */
  function getY(bytes32 key) internal view returns (int32 y) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 1);
    return (int32(uint32(Bytes.slice4(_blob, 0))));
  }

  /** Get y (using the specified store) */
  function getY(IStore _store, bytes32 key) internal view returns (int32 y) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 1);
    return (int32(uint32(Bytes.slice4(_blob, 0))));
  }

  /** Set y */
  function setY(bytes32 key, int32 y) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    StoreSwitch.setField(_tableId, _keyTuple, 1, abi.encodePacked((y)));
  }

  /** Set y (using the specified store) */
  function setY(IStore _store, bytes32 key, int32 y) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    _store.setField(_tableId, _keyTuple, 1, abi.encodePacked((y)));
  }

  /** Get z */
  function getZ(bytes32 key) internal view returns (int32 z) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 2);
    return (int32(uint32(Bytes.slice4(_blob, 0))));
  }

  /** Get z (using the specified store) */
  function getZ(IStore _store, bytes32 key) internal view returns (int32 z) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 2);
    return (int32(uint32(Bytes.slice4(_blob, 0))));
  }

  /** Set z */
  function setZ(bytes32 key, int32 z) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    StoreSwitch.setField(_tableId, _keyTuple, 2, abi.encodePacked((z)));
  }

  /** Set z (using the specified store) */
  function setZ(IStore _store, bytes32 key, int32 z) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    _store.setField(_tableId, _keyTuple, 2, abi.encodePacked((z)));
  }

  /** Get the full data */
  function get(bytes32 key) internal view returns (ScaleComponentData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    bytes memory _blob = StoreSwitch.getRecord(_tableId, _keyTuple, getSchema());
    return decode(_blob);
  }

  /** Get the full data (using the specified store) */
  function get(IStore _store, bytes32 key) internal view returns (ScaleComponentData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    bytes memory _blob = _store.getRecord(_tableId, _keyTuple, getSchema());
    return decode(_blob);
  }

  /** Set the full data using individual values */
  function set(bytes32 key, int32 x, int32 y, int32 z) internal {
    bytes memory _data = encode(x, y, z);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    StoreSwitch.setRecord(_tableId, _keyTuple, _data);
  }

  /** Set the full data using individual values (using the specified store) */
  function set(IStore _store, bytes32 key, int32 x, int32 y, int32 z) internal {
    bytes memory _data = encode(x, y, z);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    _store.setRecord(_tableId, _keyTuple, _data);
  }

  /** Set the full data using the data struct */
  function set(bytes32 key, ScaleComponentData memory _table) internal {
    set(key, _table.x, _table.y, _table.z);
  }

  /** Set the full data using the data struct (using the specified store) */
  function set(IStore _store, bytes32 key, ScaleComponentData memory _table) internal {
    set(_store, key, _table.x, _table.y, _table.z);
  }

  /** Decode the tightly packed blob using this table's schema */
  function decode(bytes memory _blob) internal pure returns (ScaleComponentData memory _table) {
    _table.x = (int32(uint32(Bytes.slice4(_blob, 0))));

    _table.y = (int32(uint32(Bytes.slice4(_blob, 4))));

    _table.z = (int32(uint32(Bytes.slice4(_blob, 8))));
  }

  /** Tightly pack full data using this table's schema */
  function encode(int32 x, int32 y, int32 z) internal pure returns (bytes memory) {
    return abi.encodePacked(x, y, z);
  }

  /** Encode keys as a bytes32 array using this table's schema */
  function encodeKeyTuple(bytes32 key) internal pure returns (bytes32[] memory _keyTuple) {
    _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;
  }

  /* Delete all data for given keys */
  function deleteRecord(bytes32 key) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /* Delete all data for given keys (using the specified store) */
  function deleteRecord(IStore _store, bytes32 key) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    _store.deleteRecord(_tableId, _keyTuple);
  }
}
