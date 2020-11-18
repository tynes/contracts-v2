// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

/**
 * @title mockOVM_L1MessageSender
 */
contract mockOVM_L1MessageSender {
    address internal sender;

    function setL1MessageSender(
        address _sender
    )
        public
    {
        sender = _sender;
    }

    function getL1MessageSender()
        public
        view
        returns (
            address
        )
    {
        return sender;
    }
}
