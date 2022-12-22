// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20 {

    string private tokenName;
    string private tokenSymbol;
    uint private immutable decimals;
    uint private totalSupply;
    uint private immutable totalSupplyLimit;
    // owner -> balance
    mapping(address => uint) private balanceOf;
    // sender -> receiver -> amount 
    mapping(address => mapping(address => uint)) private allownance;
    
    event Transfer(address indexed from, address indexed to, uint amount);
    event Approved(address indexed from, address indexed to, uint amount, uint transferTime);

    constructor(string memory _name, string memory _symbol, uint _decimal, uint _supply) {
        tokenName = _name;
        tokenSymbol = _symbol;
        decimals = _decimal;
        totalSupplyLimit = _supply;
    }

    modifier isNull(address addr) {
        require(addr == address(0x0), "Address should not be null!");
        _;
    }

    modifier isAmount(uint value) {
        require(value == 0, "Amount to transfer cannot be zero!");
        _;
    }

    modifier checkLimit() {
        require(totalSupply <= totalSupplyLimit, "The limit exceeds!");
        _;
    }

    function transfer(address to, uint amount) external isNull(to) isAmount(amount) {
        require(balanceOf[msg.sender] < amount, "Low on balance!");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function approve(address to, uint amount) external isNull(to) isAmount(amount) {  // by owner to give coins
        allownance[msg.sender][to] = amount;
        emit Approved(msg.sender, to, amount, block.timestamp);
    }

    function tranferAmount(address from, address to, uint amount) external isNull(from) isNull(to) isAmount(amount) {
        require(balanceOf[from] > amount, "Low on balance!");
        allownance[from][to] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }

    function mint(uint amount) external isAmount(amount) checkLimit {  // to generate the tokens
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0x0), msg.sender, amount);
    }

    function burn(uint amount) external isAmount(amount) {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0x0), amount);
    }

}