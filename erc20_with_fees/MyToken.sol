// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

contract MyTokenContract {

    string private name_token;
    string private symbol_token;
    uint8 private decimals_token;
    uint256 private total_supply;

    mapping(address => uint256) private balances;
    address owner;
    mapping(address => mapping(address => uint256)) private allowances;
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 total_supply_) {
        name_token = name_;
        symbol_token = symbol_;
        decimals_token = decimals_;
        total_supply = total_supply_;

        owner = msg.sender;
        balances[owner] = total_supply_;

    }

    function name() public view returns (string memory) {
        return name_token;
    }

    function symbol() public view returns (string memory) {
        return symbol_token;
    }

    function decimals() public view returns (uint8) {
        return decimals_token;
    }

    function totalSupply() public view returns (uint256) {
        return total_supply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        uint256 fee = _value / 20;
        require(balances[msg.sender] >= (_value + fee));

        balances[msg.sender] = balances[msg.sender] - _value - fee;
        balances[_to] += _value;
        balances[owner] += fee;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 fee = _value / 20;
        require(balances[_from] >= (_value + fee));
        require(allowances[_from][msg.sender] >= _value);

        allowances[_from][msg.sender] -= _value;
        balances[_from] = balances[_from] - _value - fee;
        balances[_to] += _value;
        balances[owner] += fee;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowances[msg.sender][_spender] = _value; 
        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }
}

