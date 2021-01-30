// SPDX-License-Identifier: MIT
pragma solidity >0.5.0 <0.8.0;
pragma experimental ABIEncoderV2;

/* Interface Imports */
import { iOVM_L1CrossDomainMessenger } from
"../../iOVM/bridge/iOVM_L1CrossDomainMessenger.sol";

/* Contract Imports */
import { Ownable } from "../../libraries/resolver/Lib_Ownable.sol";

contract OVM_MultiRelay is Ownable {

    /**********
     * Events *
     **********/

    event RelaySet(address _newAddress);

    struct L2ToL1Message {
        address target;
        address sender;
        bytes message;
        uint256 messageNonce;
        iOVM_L1CrossDomainMessenger.L2MessageInclusionProof proof;
    }

    address public relay;

    constructor(address _relay) Ownable() {
        relay = _relay;
        emit RelaySet(_relay);
    }

    function updateRelay(address _relay) public onlyOwner {
        relay = _relay;
        emit RelaySet(_relay);
    }

    function relayMessages(L2ToL1Message[] calldata _messages) public onlyOwner {
        for (uint256 i = 0; i < _messages.length; i++) {
            L2ToL1Message memory message = _messages[i];
            iOVM_L1CrossDomainMessenger(relay).relayMessage(
              message.target,
              message.sender,
              message.message,
              message.messageNonce,
              message.proof
            );
        }
    }
}
