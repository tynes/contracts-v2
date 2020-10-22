// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

/* Interface Imports */
import { iOVM_SafetyChecker } from "../../iOVM/execution/iOVM_SafetyChecker.sol";

/**
 * @title mockOVM_SafetyChecker
 */
contract mockOVM_SafetyChecker is iOVM_SafetyChecker {
    function isBytecodeSafe(
        bytes memory _bytecode
    )
        override
        external
        pure
        returns (bool)
    {
        return true;
    }
}
