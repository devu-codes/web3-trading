//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Token {
    string public name = "My Token";
    string public symbol = "MTK";
    uint256 public decimals = 18;
    uint256 public totalSupply = 1000000 * (10 ** decimals); // 1 million tokens = 10 ^ 18

    // Track balances
    mapping(address => uint256) public balanceOf;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    constructor(
        string memory _name,
        string memory _symbol, 
        uint256 _totalSupply
       
    ) {
        name = _name;
        symbol = _symbol; 
        totalSupply = _totalSupply * (10 ** decimals);
        balanceOf[msg.sender] = totalSupply; // Assign all tokens to the contract deployer
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        // Deduct the amount from the sender's balance
        balanceOf[msg.sender] = balanceOf[msg.sender] - _value;
        // Add the amount to the recipient's balance
        balanceOf[_to] = balanceOf[_to] + _value;
        // Emit a transfer event
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
}
