// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

/**
 * @title mockOVM_BondManager
 */
contract mockOVM_BondManager {
    function isCollateralized(
        address _who
    )
        public
        view
        returns (
            bool
        )
    {
        return true;
    }
}
