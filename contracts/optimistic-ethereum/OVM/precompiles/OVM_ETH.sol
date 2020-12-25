// SPDX-License-Identifier: MIT
// +build ovm
pragma solidity >0.5.0 <0.8.0;

/* Library Imports */
import { Lib_SmartRequire } from "../../libraries/utils/Lib_SmartRequire.sol";

/* Interface Imports */
import { iOVM_ERC20 } from "../../iOVM/precompiles/iOVM_ERC20.sol";

/**
 * @title OVM_ETH
 * @dev L2 CONTRACT (COMPILED)
 */
contract OVM_ETH is
    Lib_SmartRequire,
    iOVM_ERC20
{

    /*************
     * Constants *
     *************/

    uint256 private constant MAX_UINT256 = 2**256 - 1;


    /*************
     * Variables *
     *************/

    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    // All technically optional w/r/t ERC20 spec.
    string public name;
    uint8 public decimals;
    string public symbol;
    uint256 public override totalSupply;


    /***************
     * Constructor *
     ***************/

    constructor(
        uint256 _initialAmount,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol
    )
        public
        Lib_SmartRequire("OVM_ETH")
    {
        balances[msg.sender] = _initialAmount;
        totalSupply = _initialAmount;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;
    }


    /********************
     * Public Functions *
     ********************/

    function transfer(
        address _to,
        uint256 _value
    )
        override
        external
        returns (
            bool
        )
    {
        require(
            balances[msg.sender] >= _value,
            "Sender does not have enough balance."
        );

        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        override
        external
        returns (
            bool
        )
    {
        uint256 allowance = allowed[_from][msg.sender];
        require(
            balances[_from] >= _value,
            "From account does not have enough balance."
        );
            
        require(
            allowance >= _value,
            "Sending account does not have enough allowance."
        );

        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }

        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(
        address _owner
    )
        override
        external
        view
        returns (
            uint256
        )
    {
        return balances[_owner];
    }

    function approve(
        address _spender,
        uint256 _value
    )
        override
        external
        returns (
            bool
        )
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    )
        override
        external
        view
        returns (
            uint256
        )
    {
        return allowed[_owner][_spender];
    }
}
