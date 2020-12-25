// SPDX-License-Identifier: MIT
// +build ovm
pragma solidity >0.5.0 <0.8.0;

contract Lib_SmartRequire {
    string private name;

    constructor(
        string memory _name
    )
        public
    {
        name = _name;
    }

    function require(
        bool _condition,
        string memory _reason
    )
        internal
        view
    {
        if (_condition) {
            revert(
                string(abi.encodePacked(
                    name,
                    ": ",
                    _reason
                ))
            );
        }
    }
}
