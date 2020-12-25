// SPDX-License-Identifier: MIT
pragma solidity >0.5.0 <0.8.0;
pragma experimental ABIEncoderV2;

/* Library Imports */
import { Lib_OVMCodec } from "../../libraries/codec/Lib_OVMCodec.sol";

/**
 * @title iOVM_StateManager
 */
interface iOVM_StateManager {

    /*******************
     * Data Structures *
     *******************/

    enum ItemState {
        ITEM_UNTOUCHED,
        ITEM_LOADED,
        ITEM_CHANGED,
        ITEM_COMMITTED
    }

    /***************************
     * Public Functions: Misc *
     ***************************/

    function isAuthenticated(
        address _address
    )
        external
        view
        returns (
            bool
        );

    /***************************
     * Public Functions: Setup *
     ***************************/

    function owner()
        external
        view
        returns (
            address
        );

    function ovmExecutionManager()
        external
        view
        returns (
            address
        );

    function setExecutionManager(
        address _ovmExecutionManager
    )
        external;


    /************************************
     * Public Functions: Account Access *
     ************************************/

    function putAccount(
        address _address,
        Lib_OVMCodec.Account memory _account
    )
        external;

    function putEmptyAccount(
        address _address
    )
        external;

    function getAccount(
        address _address
    )
        external
        view
        returns (
            Lib_OVMCodec.Account memory
        );

    function hasAccount(
        address _address
    )
        external
        view
        returns (
            bool
        );

    function hasEmptyAccount(
        address _address
    )
        external
        view
        returns (
            bool
        );

    function setAccountNonce(
        address _address,
        uint256 _nonce
    )
        external;

    function getAccountNonce(
        address _address
    )
        external
        view
        returns (
            uint256
        );

    function getAccountEthAddress(
        address _address
    )
        external
        view
        returns (
            address
        );

    function getAccountStorageRoot(
        address _address
    )
        external
        view
        returns (
            bytes32
        );

    function initPendingAccount(
        address _address
    )
        external;

    function commitPendingAccount(
        address _address,
        address _ethAddress,
        bytes32 _codeHash
    )
        external;

    function testAndSetAccountLoaded(
        address _address
    )
        external
        returns (
            bool
        );

    function testAndSetAccountChanged(
        address _address
    )
        external
        returns (
            bool
        );

    function commitAccount(
        address _address
    )
        external
        returns (
            bool
        );

    function incrementTotalUncommittedAccounts()
        external;

    function getTotalUncommittedAccounts()
        external
        view
        returns (
            uint256
        );

    function wasAccountChanged(
        address _address
    )
        external
        view
        returns (
            bool
        );

    function wasAccountCommitted(
        address _address
    )
        external
        view
        returns (
            bool
        );


    /************************************
     * Public Functions: Storage Access *
     ************************************/

    function putContractStorage(
        address _contract,
        bytes32 _key,
        bytes32 _value
    )
        external;

    function getContractStorage(
        address _contract,
        bytes32 _key
    )
        external
        view
        returns (
            bytes32
        );

    function hasContractStorage(
        address _contract,
        bytes32 _key
    )
        external
        returns (
            bool
        );

    function testAndSetContractStorageLoaded(
        address _contract,
        bytes32 _key
    )
        external
        returns (
            bool
        );

    function testAndSetContractStorageChanged(
        address _contract,
        bytes32 _key
    )
        external
        returns (
            bool
        );

    function commitContractStorage(
        address _contract,
        bytes32 _key
    )
        external
        returns (
            bool
        );

    function incrementTotalUncommittedContractStorage()
        external;

    function getTotalUncommittedContractStorage()
        external
        view
        returns (
            uint256
        );

    function wasContractStorageChanged(
        address _contract,
        bytes32 _key
    )   
        external
        view
        returns (
            bool
        );

    function wasContractStorageCommitted(
        address _contract,
        bytes32 _key
    )
        external
        view
        returns (
            bool
        );
}
