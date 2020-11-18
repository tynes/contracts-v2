// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

/**
 * @title mockOVM_CanonicalTransactionChain
 */
contract mockOVM_CanonicalTransactionChain {
    function getTotalElements()
        public
        view
        returns (
            uint256
        )
    {
        return 99999999;
    }
}
