// SPDX-License-Identifier: MIT
// +build ovm
pragma solidity >0.5.0 <0.8.0;

/* Interface Imports */
import { iOVM_ERC20 } from "../../iOVM/precompiles/iOVM_ERC20.sol";

/**
 * @title OVM_ETH
 * @dev L2 CONTRACT (COMPILED)
 */
contract OVM_ETH is iOVM_ERC20 {
    uint256 private constant MAX_UINT256 = 2**256 - 1;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    string public name;
    uint8 public decimals;
    string public symbol;
    uint256 public override totalSupply;

    constructor(
        uint256 _initialAmount,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol
    ) public {
        balances[msg.sender] = _initialAmount;
        totalSupply = _initialAmount;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;
    }

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
        require(balances[msg.sender] >= _value);
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
        require(balances[_from] >= _value && allowance >= _value);
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
