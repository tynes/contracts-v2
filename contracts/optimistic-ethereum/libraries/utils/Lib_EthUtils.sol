// SPDX-License-Identifier: UNLICENSED
// +build evm
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

/* Library Imports */
import { Lib_RLPWriter } from "../rlp/Lib_RLPWriter.sol";

/**
 * @title Lib_EthUtils
 */
library Lib_EthUtils {

    /***********************************
     * Internal Functions: Code Access *
     ***********************************/

    /**
     * Gets the code for a given address.
     * @param _address Address to get code for.
     * @param _offset Offset to start reading from.
     * @param _length Number of bytes to read.
     * @return _code Code read from the contract.
     */
    function getCode(
        address _address,
        uint256 _offset,
        uint256 _length
    )
        internal
        view
        returns (
            bytes memory _code
        )
    {
        assembly {
            _code := mload(0x40)
            mstore(0x40, add(_code, add(_length, 0x20)))
            mstore(_code, _length)
            extcodecopy(_address, add(_code, 0x20), _offset, _length)
        }

        return _code;
    }

    /**
     * Gets the full code for a given address.
     * @param _address Address to get code for.
     * @return _code Full code of the contract.
     */
    function getCode(
        address _address
    )
        internal
        view
        returns (
            bytes memory _code
        )
    {
        return getCode(
            _address,
            0,
            getCodeSize(_address)
        );
    }

    /**
     * Gets the size of a contract's code in bytes.
     * @param _address Address to get code size for.
     * @return _codeSize Size of the contract's code in bytes.
     */
    function getCodeSize(
        address _address
    )
        internal
        view
        returns (
            uint256 _codeSize
        )
    {
        assembly {
            _codeSize := extcodesize(_address)
        }

        return _codeSize;
    }

    /**
     * Gets the hash of a contract's code.
     * @param _address Address to get a code hash for.
     * @return _codeHash Hash of the contract's code.
     */
    function getCodeHash(
        address _address
    )
        internal
        view
        returns (
            bytes32 _codeHash
        )
    {
        assembly {
            _codeHash := extcodehash(_address)
        }

        return _codeHash;
    }


    /*****************************************
     * Internal Functions: Contract Creation *
     *****************************************/

    /**
     * Creates a contract with some given initialization code.
     * @param _code Contract initialization code.
     * @return _created Address of the created contract.
     */
    function createContract(
        bytes memory _code
    )
        internal
        returns (
            address _created
        )
    {
        assembly {
            _created := create(
                0,
                add(_code, 0x20),
                mload(_code)
            )
        }

        return _created;
    }

    /**
     * Computes the address that would be generated by CREATE.
     * @param _creator Address creating the contract.
     * @param _nonce Creator's nonce.
     * @return _address Address to be generated by CREATE.
     */
    function getAddressForCREATE(
        address _creator,
        uint256 _nonce
    )
        internal
        pure
        returns (
            address _address
        )
    {
        bytes[] memory encoded = new bytes[](2);
        encoded[0] = Lib_RLPWriter.writeAddress(_creator);
        encoded[1] = Lib_RLPWriter.writeUint(_nonce);

        bytes memory encodedList = Lib_RLPWriter.writeList(encoded);
        return getAddressFromHash(keccak256(encodedList));
    }

    /**
     * Computes the address that would be generated by CREATE2.
     * @param _creator Address creating the contract.
     * @param _bytecode Bytecode of the contract to be created.
     * @param _salt 32 byte salt value mixed into the hash.
     * @return _address Address to be generated by CREATE2.
     */
    function getAddressForCREATE2(
        address _creator,
        bytes memory _bytecode,
        bytes32 _salt
    )
        internal
        pure
        returns (address _address)
    {
        bytes32 hashedData = keccak256(abi.encodePacked(
            byte(0xff),
            _creator,
            _salt,
            keccak256(_bytecode)
        ));

        return getAddressFromHash(hashedData);
    }


    /****************************************
     * Private Functions: Contract Creation *
     ****************************************/

    /**
     * Determines an address from a 32 byte hash. Since addresses are only
     * 20 bytes, we need to retrieve the last 20 bytes from the original
     * hash. Converting to uint256 and then uint160 gives us these bytes.
     * @param _hash Hash to convert to an address.
     * @return _address Hash converted to an address.
     */
    function getAddressFromHash(
        bytes32 _hash
    )
        private
        pure
        returns (
            address _address
        )
    {
        return address(bytes20(uint160(uint256(_hash))));
    }
}
