// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import { iOVM_BondManager } from "../../iOVM/verification/iOVM_BondManager.sol";
import { Lib_AddressResolver } from "../../libraries/resolver/Lib_AddressResolver.sol";

/// Minimal contract to be inherited by contracts consumed by users that provide
/// data for fraud proofs
abstract contract OVM_FraudContributor is Lib_AddressResolver {
    /// Decorate your functions with this modifier to store how much total gas was
    /// consumed by the sender, to reward users fairly
    modifier contributesToFraudProof(
        bytes32 _preStateRoot,
        bytes32 _txHash
    ) {
        uint256 startGas = gasleft();
        _;
        uint256 gasSpent = startGas - gasleft();

        iOVM_BondManager(resolve('OVM_BondManager')).recordGasSpent(
            _preStateRoot,
            _txHash,
            msg.sender,
            gasSpent
        );
    }
}
