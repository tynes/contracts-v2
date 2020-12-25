// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

/* Library Imports */
import { Lib_Bytes32Utils } from "../../optimistic-ethereum/libraries/utils/Lib_Bytes32Utils.sol";

/**
 * @title TestLib_Byte32Utils
 */
contract TestLib_Bytes32Utils {

    function toBool(
        bytes32 _in
    )
        public
        pure
        returns (
            bool
        )
    {
        return Lib_Bytes32Utils.toBool(_in);
    }

    function fromBool(
        bool _in
    )
        public
        pure
        returns (
            bytes32
        )
    {
        return Lib_Bytes32Utils.fromBool(_in);
    }

    function toAddress(
        bytes32 _in
    )
        public
        pure
        returns (
            address
        )
    {
        return Lib_Bytes32Utils.toAddress(_in);
    }

    function fromAddress(
        address _in
    )
        public
        pure
        returns (
            bytes32
        )
    {
        return Lib_Bytes32Utils.fromAddress(_in);
    }
}
