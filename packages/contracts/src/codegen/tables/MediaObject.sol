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

// Import user types
import { MediaObjectType, MediaObjectEncodingFormat } from "./../Types.sol";

bytes32 constant _tableId = bytes32(abi.encodePacked(bytes16("geoweb"), bytes16("MediaObject")));
bytes32 constant MediaObjectTableId = _tableId;

struct MediaObjectData {
  uint64 contentSize;
  MediaObjectType mediaType;
  MediaObjectEncodingFormat encodingFormat;
  string name;
  bytes contentHash;
}

library MediaObject {
  /** Get the table's key schema */
  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](1);
    _schema[0] = SchemaType.BYTES32;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's value schema */
  function getValueSchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](5);
    _schema[0] = SchemaType.UINT64;
    _schema[1] = SchemaType.UINT8;
    _schema[2] = SchemaType.UINT8;
    _schema[3] = SchemaType.STRING;
    _schema[4] = SchemaType.BYTES;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's key names */
  function getKeyNames() internal pure returns (string[] memory keyNames) {
    keyNames = new string[](1);
    keyNames[0] = "key";
  }

  /** Get the table's field names */
  function getFieldNames() internal pure returns (string[] memory fieldNames) {
    fieldNames = new string[](5);
    fieldNames[0] = "contentSize";
    fieldNames[1] = "mediaType";
    fieldNames[2] = "encodingFormat";
    fieldNames[3] = "name";
    fieldNames[4] = "contentHash";
  }

  /** Register the table's key schema, value schema, key names and value names */
  function register() internal {
    StoreSwitch.registerTable(_tableId, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /** Register the table's key schema, value schema, key names and value names (using the specified store) */
  function register(IStore _store) internal {
    _store.registerTable(_tableId, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /** Get contentSize */
  function getContentSize(bytes32 key) internal view returns (uint64 contentSize) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 0, getValueSchema());
    return (uint64(Bytes.slice8(_blob, 0)));
  }

  /** Get contentSize (using the specified store) */
  function getContentSize(IStore _store, bytes32 key) internal view returns (uint64 contentSize) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 0, getValueSchema());
    return (uint64(Bytes.slice8(_blob, 0)));
  }

  /** Set contentSize */
  function setContentSize(bytes32 key, uint64 contentSize) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    StoreSwitch.setField(_tableId, _keyTuple, 0, abi.encodePacked((contentSize)), getValueSchema());
  }

  /** Set contentSize (using the specified store) */
  function setContentSize(IStore _store, bytes32 key, uint64 contentSize) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    _store.setField(_tableId, _keyTuple, 0, abi.encodePacked((contentSize)), getValueSchema());
  }

  /** Get mediaType */
  function getMediaType(bytes32 key) internal view returns (MediaObjectType mediaType) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 1, getValueSchema());
    return MediaObjectType(uint8(Bytes.slice1(_blob, 0)));
  }

  /** Get mediaType (using the specified store) */
  function getMediaType(IStore _store, bytes32 key) internal view returns (MediaObjectType mediaType) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 1, getValueSchema());
    return MediaObjectType(uint8(Bytes.slice1(_blob, 0)));
  }

  /** Set mediaType */
  function setMediaType(bytes32 key, MediaObjectType mediaType) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    StoreSwitch.setField(_tableId, _keyTuple, 1, abi.encodePacked(uint8(mediaType)), getValueSchema());
  }

  /** Set mediaType (using the specified store) */
  function setMediaType(IStore _store, bytes32 key, MediaObjectType mediaType) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    _store.setField(_tableId, _keyTuple, 1, abi.encodePacked(uint8(mediaType)), getValueSchema());
  }

  /** Get encodingFormat */
  function getEncodingFormat(bytes32 key) internal view returns (MediaObjectEncodingFormat encodingFormat) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 2, getValueSchema());
    return MediaObjectEncodingFormat(uint8(Bytes.slice1(_blob, 0)));
  }

  /** Get encodingFormat (using the specified store) */
  function getEncodingFormat(
    IStore _store,
    bytes32 key
  ) internal view returns (MediaObjectEncodingFormat encodingFormat) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 2, getValueSchema());
    return MediaObjectEncodingFormat(uint8(Bytes.slice1(_blob, 0)));
  }

  /** Set encodingFormat */
  function setEncodingFormat(bytes32 key, MediaObjectEncodingFormat encodingFormat) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    StoreSwitch.setField(_tableId, _keyTuple, 2, abi.encodePacked(uint8(encodingFormat)), getValueSchema());
  }

  /** Set encodingFormat (using the specified store) */
  function setEncodingFormat(IStore _store, bytes32 key, MediaObjectEncodingFormat encodingFormat) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    _store.setField(_tableId, _keyTuple, 2, abi.encodePacked(uint8(encodingFormat)), getValueSchema());
  }

  /** Get name */
  function getName(bytes32 key) internal view returns (string memory name) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 3, getValueSchema());
    return (string(_blob));
  }

  /** Get name (using the specified store) */
  function getName(IStore _store, bytes32 key) internal view returns (string memory name) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 3, getValueSchema());
    return (string(_blob));
  }

  /** Set name */
  function setName(bytes32 key, string memory name) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    StoreSwitch.setField(_tableId, _keyTuple, 3, bytes((name)), getValueSchema());
  }

  /** Set name (using the specified store) */
  function setName(IStore _store, bytes32 key, string memory name) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    _store.setField(_tableId, _keyTuple, 3, bytes((name)), getValueSchema());
  }

  /** Get the length of name */
  function lengthName(bytes32 key) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    uint256 _byteLength = StoreSwitch.getFieldLength(_tableId, _keyTuple, 3, getValueSchema());
    unchecked {
      return _byteLength / 1;
    }
  }

  /** Get the length of name (using the specified store) */
  function lengthName(IStore _store, bytes32 key) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    uint256 _byteLength = _store.getFieldLength(_tableId, _keyTuple, 3, getValueSchema());
    unchecked {
      return _byteLength / 1;
    }
  }

  /**
   * Get an item of name
   * (unchecked, returns invalid data if index overflows)
   */
  function getItemName(bytes32 key, uint256 _index) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    unchecked {
      bytes memory _blob = StoreSwitch.getFieldSlice(
        _tableId,
        _keyTuple,
        3,
        getValueSchema(),
        _index * 1,
        (_index + 1) * 1
      );
      return (string(_blob));
    }
  }

  /**
   * Get an item of name (using the specified store)
   * (unchecked, returns invalid data if index overflows)
   */
  function getItemName(IStore _store, bytes32 key, uint256 _index) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    unchecked {
      bytes memory _blob = _store.getFieldSlice(_tableId, _keyTuple, 3, getValueSchema(), _index * 1, (_index + 1) * 1);
      return (string(_blob));
    }
  }

  /** Push a slice to name */
  function pushName(bytes32 key, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    StoreSwitch.pushToField(_tableId, _keyTuple, 3, bytes((_slice)), getValueSchema());
  }

  /** Push a slice to name (using the specified store) */
  function pushName(IStore _store, bytes32 key, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    _store.pushToField(_tableId, _keyTuple, 3, bytes((_slice)), getValueSchema());
  }

  /** Pop a slice from name */
  function popName(bytes32 key) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    StoreSwitch.popFromField(_tableId, _keyTuple, 3, 1, getValueSchema());
  }

  /** Pop a slice from name (using the specified store) */
  function popName(IStore _store, bytes32 key) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    _store.popFromField(_tableId, _keyTuple, 3, 1, getValueSchema());
  }

  /**
   * Update a slice of name at `_index`
   * (checked only to prevent modifying other tables; can corrupt own data if index overflows)
   */
  function updateName(bytes32 key, uint256 _index, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    unchecked {
      StoreSwitch.updateInField(_tableId, _keyTuple, 3, _index * 1, bytes((_slice)), getValueSchema());
    }
  }

  /**
   * Update a slice of name (using the specified store) at `_index`
   * (checked only to prevent modifying other tables; can corrupt own data if index overflows)
   */
  function updateName(IStore _store, bytes32 key, uint256 _index, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    unchecked {
      _store.updateInField(_tableId, _keyTuple, 3, _index * 1, bytes((_slice)), getValueSchema());
    }
  }

  /** Get contentHash */
  function getContentHash(bytes32 key) internal view returns (bytes memory contentHash) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 4, getValueSchema());
    return (bytes(_blob));
  }

  /** Get contentHash (using the specified store) */
  function getContentHash(IStore _store, bytes32 key) internal view returns (bytes memory contentHash) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 4, getValueSchema());
    return (bytes(_blob));
  }

  /** Set contentHash */
  function setContentHash(bytes32 key, bytes memory contentHash) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    StoreSwitch.setField(_tableId, _keyTuple, 4, bytes((contentHash)), getValueSchema());
  }

  /** Set contentHash (using the specified store) */
  function setContentHash(IStore _store, bytes32 key, bytes memory contentHash) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    _store.setField(_tableId, _keyTuple, 4, bytes((contentHash)), getValueSchema());
  }

  /** Get the length of contentHash */
  function lengthContentHash(bytes32 key) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    uint256 _byteLength = StoreSwitch.getFieldLength(_tableId, _keyTuple, 4, getValueSchema());
    unchecked {
      return _byteLength / 1;
    }
  }

  /** Get the length of contentHash (using the specified store) */
  function lengthContentHash(IStore _store, bytes32 key) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    uint256 _byteLength = _store.getFieldLength(_tableId, _keyTuple, 4, getValueSchema());
    unchecked {
      return _byteLength / 1;
    }
  }

  /**
   * Get an item of contentHash
   * (unchecked, returns invalid data if index overflows)
   */
  function getItemContentHash(bytes32 key, uint256 _index) internal view returns (bytes memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    unchecked {
      bytes memory _blob = StoreSwitch.getFieldSlice(
        _tableId,
        _keyTuple,
        4,
        getValueSchema(),
        _index * 1,
        (_index + 1) * 1
      );
      return (bytes(_blob));
    }
  }

  /**
   * Get an item of contentHash (using the specified store)
   * (unchecked, returns invalid data if index overflows)
   */
  function getItemContentHash(IStore _store, bytes32 key, uint256 _index) internal view returns (bytes memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    unchecked {
      bytes memory _blob = _store.getFieldSlice(_tableId, _keyTuple, 4, getValueSchema(), _index * 1, (_index + 1) * 1);
      return (bytes(_blob));
    }
  }

  /** Push a slice to contentHash */
  function pushContentHash(bytes32 key, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    StoreSwitch.pushToField(_tableId, _keyTuple, 4, bytes((_slice)), getValueSchema());
  }

  /** Push a slice to contentHash (using the specified store) */
  function pushContentHash(IStore _store, bytes32 key, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    _store.pushToField(_tableId, _keyTuple, 4, bytes((_slice)), getValueSchema());
  }

  /** Pop a slice from contentHash */
  function popContentHash(bytes32 key) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    StoreSwitch.popFromField(_tableId, _keyTuple, 4, 1, getValueSchema());
  }

  /** Pop a slice from contentHash (using the specified store) */
  function popContentHash(IStore _store, bytes32 key) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    _store.popFromField(_tableId, _keyTuple, 4, 1, getValueSchema());
  }

  /**
   * Update a slice of contentHash at `_index`
   * (checked only to prevent modifying other tables; can corrupt own data if index overflows)
   */
  function updateContentHash(bytes32 key, uint256 _index, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    unchecked {
      StoreSwitch.updateInField(_tableId, _keyTuple, 4, _index * 1, bytes((_slice)), getValueSchema());
    }
  }

  /**
   * Update a slice of contentHash (using the specified store) at `_index`
   * (checked only to prevent modifying other tables; can corrupt own data if index overflows)
   */
  function updateContentHash(IStore _store, bytes32 key, uint256 _index, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    unchecked {
      _store.updateInField(_tableId, _keyTuple, 4, _index * 1, bytes((_slice)), getValueSchema());
    }
  }

  /** Get the full data */
  function get(bytes32 key) internal view returns (MediaObjectData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    bytes memory _blob = StoreSwitch.getRecord(_tableId, _keyTuple, getValueSchema());
    return decode(_blob);
  }

  /** Get the full data (using the specified store) */
  function get(IStore _store, bytes32 key) internal view returns (MediaObjectData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    bytes memory _blob = _store.getRecord(_tableId, _keyTuple, getValueSchema());
    return decode(_blob);
  }

  /** Set the full data using individual values */
  function set(
    bytes32 key,
    uint64 contentSize,
    MediaObjectType mediaType,
    MediaObjectEncodingFormat encodingFormat,
    string memory name,
    bytes memory contentHash
  ) internal {
    bytes memory _data = encode(contentSize, mediaType, encodingFormat, name, contentHash);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    StoreSwitch.setRecord(_tableId, _keyTuple, _data, getValueSchema());
  }

  /** Set the full data using individual values (using the specified store) */
  function set(
    IStore _store,
    bytes32 key,
    uint64 contentSize,
    MediaObjectType mediaType,
    MediaObjectEncodingFormat encodingFormat,
    string memory name,
    bytes memory contentHash
  ) internal {
    bytes memory _data = encode(contentSize, mediaType, encodingFormat, name, contentHash);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    _store.setRecord(_tableId, _keyTuple, _data, getValueSchema());
  }

  /** Set the full data using the data struct */
  function set(bytes32 key, MediaObjectData memory _table) internal {
    set(key, _table.contentSize, _table.mediaType, _table.encodingFormat, _table.name, _table.contentHash);
  }

  /** Set the full data using the data struct (using the specified store) */
  function set(IStore _store, bytes32 key, MediaObjectData memory _table) internal {
    set(_store, key, _table.contentSize, _table.mediaType, _table.encodingFormat, _table.name, _table.contentHash);
  }

  /**
   * Decode the tightly packed blob using this table's schema.
   * Undefined behaviour for invalid blobs.
   */
  function decode(bytes memory _blob) internal pure returns (MediaObjectData memory _table) {
    // 10 is the total byte length of static data
    PackedCounter _encodedLengths = PackedCounter.wrap(Bytes.slice32(_blob, 10));

    _table.contentSize = (uint64(Bytes.slice8(_blob, 0)));

    _table.mediaType = MediaObjectType(uint8(Bytes.slice1(_blob, 8)));

    _table.encodingFormat = MediaObjectEncodingFormat(uint8(Bytes.slice1(_blob, 9)));

    // Store trims the blob if dynamic fields are all empty
    if (_blob.length > 10) {
      // skip static data length + dynamic lengths word
      uint256 _start = 42;
      uint256 _end;
      unchecked {
        _end = 42 + _encodedLengths.atIndex(0);
      }
      _table.name = (string(SliceLib.getSubslice(_blob, _start, _end).toBytes()));

      _start = _end;
      unchecked {
        _end += _encodedLengths.atIndex(1);
      }
      _table.contentHash = (bytes(SliceLib.getSubslice(_blob, _start, _end).toBytes()));
    }
  }

  /** Tightly pack full data using this table's schema */
  function encode(
    uint64 contentSize,
    MediaObjectType mediaType,
    MediaObjectEncodingFormat encodingFormat,
    string memory name,
    bytes memory contentHash
  ) internal pure returns (bytes memory) {
    PackedCounter _encodedLengths;
    // Lengths are effectively checked during copy by 2**40 bytes exceeding gas limits
    unchecked {
      _encodedLengths = PackedCounterLib.pack(bytes(name).length, bytes(contentHash).length);
    }

    return
      abi.encodePacked(
        contentSize,
        mediaType,
        encodingFormat,
        _encodedLengths.unwrap(),
        bytes((name)),
        bytes((contentHash))
      );
  }

  /** Encode keys as a bytes32 array using this table's schema */
  function encodeKeyTuple(bytes32 key) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    return _keyTuple;
  }

  /* Delete all data for given keys */
  function deleteRecord(bytes32 key) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    StoreSwitch.deleteRecord(_tableId, _keyTuple, getValueSchema());
  }

  /* Delete all data for given keys (using the specified store) */
  function deleteRecord(IStore _store, bytes32 key) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = key;

    _store.deleteRecord(_tableId, _keyTuple, getValueSchema());
  }
}
