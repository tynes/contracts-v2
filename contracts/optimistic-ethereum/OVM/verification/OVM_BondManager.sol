// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

/* Library Imports */
import { Lib_AddressResolver } from "../../libraries/resolver/Lib_AddressResolver.sol";
import { Lib_SmartRequire } from "../../libraries/utils/Lib_SmartRequire.sol";

/* Interface Imports */
import { iOVM_ERC20 } from "../../iOVM/precompiles/iOVM_ERC20.sol";
import { iOVM_BondManager, Errors } from "../../iOVM/verification/iOVM_BondManager.sol";
import { iOVM_FraudVerifier } from "../../iOVM/verification/iOVM_FraudVerifier.sol";

/**
 * @title OVM_BondManager
 */
contract OVM_BondManager is
    Lib_AddressResolver,
    Lib_SmartRequire,
    iOVM_BondManager
{

    /****************************
     * Constants and Parameters *
     ****************************/

    /// The period to find the earliest fraud proof for a publisher
    uint256 public constant multiFraudProofPeriod = 7 days;

    /// The dispute period
    uint256 public constant disputePeriodSeconds = 7 days;

    /// The minimum collateral a sequencer must post
    uint256 public constant requiredCollateral = 1 ether;


    /*************
     * Variables *
     *************/

    /// The bond token
    iOVM_ERC20 immutable public token;

    /// The bonds posted by each proposer
    mapping(address => Bond) public bonds;

    /// For each pre-state root, there's an array of witnessProviders that must be rewarded
    /// for posting witnesses
    mapping(bytes32 => Rewards) public witnessProviders;


    /***************
     * Constructor *
     ***************/

    /// Initializes with a ERC20 token to be used for the fidelity bonds
    /// and with the Address Manager
    constructor(
        iOVM_ERC20 _token,
        address _libAddressManager
    )
        Lib_AddressResolver(_libAddressManager)
        Lib_SmartRequire("OVM_BondManager")
    {
        token = _token;
    }


    /********************
     * Public Functions *
     ********************/

    /// Adds `who` to the list of witnessProviders for the provided `preStateRoot`.
    function recordGasSpent(
        bytes32 _preStateRoot,
        bytes32 _txHash,
        address _who,
        uint256 _gasSpent
    )
        override
        public
    {
        // The sender must be the transitioner that corresponds to the claimed pre-state root
        address transitioner = address(iOVM_FraudVerifier(
            resolve("OVM_FraudVerifier")
        ).getStateTransitioner(_preStateRoot, _txHash));

        require(
            transitioner == msg.sender,
            Errors.ONLY_TRANSITIONER
        );

        witnessProviders[_preStateRoot].total += _gasSpent;
        witnessProviders[_preStateRoot].gasSpent[_who] += _gasSpent;
    }

    /// Slashes + distributes rewards or frees up the sequencer's bond, only called by
    /// `FraudVerifier.finalizeFraudVerification`
    function finalize(
        bytes32 _preStateRoot,
        address _publisher,
        uint256 _timestamp
    )
        override
        public
    {
        require(
            msg.sender == resolve("OVM_FraudVerifier"),
            Errors.ONLY_FRAUD_VERIFIER
        );

        require(
            witnessProviders[_preStateRoot].canClaim == false,
            Errors.ALREADY_FINALIZED
        );

        // allow users to claim from that state root's
        // pool of collateral (effectively slashing the sequencer)
        witnessProviders[_preStateRoot].canClaim = true;

        Bond storage bond = bonds[_publisher];
        if (bond.firstDisputeAt == 0) {
            bond.firstDisputeAt = block.timestamp;
            bond.earliestDisputedStateRoot = _preStateRoot;
            bond.earliestTimestamp = _timestamp;
        } else if (
            // only update the disputed state root for the publisher if it's within
            // the dispute period _and_ if it's before the previous one
            block.timestamp < bond.firstDisputeAt + multiFraudProofPeriod &&
            _timestamp < bond.earliestTimestamp
        ) {
            bond.earliestDisputedStateRoot = _preStateRoot;
            bond.earliestTimestamp = _timestamp;
        }

        // if the fraud proof's dispute period does not intersect with the 
        // withdrawal's timestamp, then the user should not be slashed
        // e.g if a user at day 10 submits a withdrawal, and a fraud proof
        // from day 1 gets published, the user won't be slashed since day 8 (1d + 7d)
        // is before the user started their withdrawal. on the contrary, if the user
        // had started their withdrawal at, say, day 6, they would be slashed
        if (
            bond.withdrawalTimestamp != 0 && 
            uint256(bond.withdrawalTimestamp) > _timestamp + disputePeriodSeconds &&
            bond.state == State.WITHDRAWING
        ) {
            return;
        }

        // slash!
        bond.state = State.NOT_COLLATERALIZED;
    }

    /// Sequencers call this function to post collateral which will be used for
    /// the `appendBatch` call
    function deposit()
        override
        public
    {
        require(
            token.transferFrom(msg.sender, address(this), requiredCollateral),
            Errors.ERC20_ERR
        );

        // This cannot overflow
        bonds[msg.sender].state = State.COLLATERALIZED;
    }

    /// Starts the withdrawal for a publisher
    function startWithdrawal()
        override
        public
    {
        Bond storage bond = bonds[msg.sender];
        require(
            bond.withdrawalTimestamp == 0,
            Errors.WITHDRAWAL_PENDING
        );

        require(
            bond.state == State.COLLATERALIZED,
            Errors.WRONG_STATE
        );

        bond.state = State.WITHDRAWING;
        bond.withdrawalTimestamp = uint32(block.timestamp);
    }

    /// Finalizes a pending withdrawal from a publisher
    function finalizeWithdrawal()
        override
        public
    {
        Bond storage bond = bonds[msg.sender];

        require(
            block.timestamp >= uint256(bond.withdrawalTimestamp) + disputePeriodSeconds, 
            Errors.TOO_EARLY
        );

        require(
            bond.state == State.WITHDRAWING,
            Errors.SLASHED
        );

        // refunds!
        bond.state = State.NOT_COLLATERALIZED;
        bond.withdrawalTimestamp = 0;
        
        require(
            token.transfer(msg.sender, requiredCollateral),
            Errors.ERC20_ERR
        );
    }

    /// Claims the user's reward for the witnesses they provided for the earliest
    /// disputed state root of the designated publisher
    function claim(
        address _who
    )
        override
        public
    {
        Bond storage bond = bonds[_who];
        require(
            block.timestamp >= bond.firstDisputeAt + multiFraudProofPeriod,
            Errors.WAIT_FOR_DISPUTES
        );

        // reward the earliest state root for this publisher
        bytes32 _preStateRoot = bond.earliestDisputedStateRoot;
        Rewards storage rewards = witnessProviders[_preStateRoot];

        // only allow claiming if fraud was proven in `finalize`
        require(
            rewards.canClaim,
            Errors.CANNOT_CLAIM
        );

        // proportional allocation - only reward 50% (rest gets locked in the
        // contract forever
        uint256 amount = (requiredCollateral * rewards.gasSpent[msg.sender]) / (2 * rewards.total);

        // reset the user's spent gas so they cannot double claim
        rewards.gasSpent[msg.sender] = 0;

        // transfer
        require(
            token.transfer(msg.sender, amount),
            Errors.ERC20_ERR
        );
    }

    /// Checks if the user is collateralized
    function isCollateralized(
        address _who
    )
        override
        public
        view
        returns (
            bool
        )
    {
        return bonds[_who].state == State.COLLATERALIZED;
    }

    /// Gets how many witnesses the user has provided for the state root
    function getGasSpent(
        bytes32 _preStateRoot,
        address _who
    )
        override
        public
        view
        returns (
            uint256
        )
    {
        return witnessProviders[_preStateRoot].gasSpent[_who];
    }
}
