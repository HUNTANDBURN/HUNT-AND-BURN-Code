// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC20Interface {
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) external view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) external returns (bool success);
    function approve(address spender, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);
    function mint(uint256 tokens) external;
    function burn(uint256 tokens) external;

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
    event Mint(address indexed to, uint256 tokens);
    event Burn(address indexed from, uint256 tokens);
}

contract HABToken is ERC20Interface {
    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 public _totalSupply;
    address public owner;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        symbol = "HAB";
        name = "HABToken";
        decimals = 18;
        _totalSupply = 1_000_000_000 * 10**uint256(decimals);
        owner = msg.sender;
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) external view override returns (uint256 balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint256 tokens) external override returns (bool success) {
        require(to != address(0), "Cannot transfer to zero address");
        require(balances[msg.sender] >= tokens, "Insufficient balance");

        balances[msg.sender] -= tokens;
        balances[to] += tokens;

        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint256 tokens) external override returns (bool success) {
        require(spender != address(0), "Cannot approve zero address");

        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint256 tokens) external override returns (bool success) {
        require(to != address(0), "Cannot transfer to zero address");
        require(balances[from] >= tokens, "Insufficient balance");
        require(allowed[from][msg.sender] >= tokens, "Allowance exceeded");

        balances[from] -= tokens;
        allowed[from][msg.sender] -= tokens;
        balances[to] += tokens;

        emit Transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) external view override returns (uint256 remaining) {
        return allowed[tokenOwner][spender];
    }

    function mint(uint256 tokens) external onlyOwner {
        _totalSupply += tokens;
        balances[owner] += tokens;
        emit Mint(owner, tokens);
        emit Transfer(address(0), owner, tokens);
    }

    function burn(uint256 tokens) external {
        require(balances[msg.sender] >= tokens, "Insufficient balance to burn");
        balances[msg.sender] -= tokens;
        _totalSupply -= tokens;

        emit Burn(msg.sender, tokens);
        emit Transfer(msg.sender, address(0), tokens);
    }

    receive() external payable {
        revert("Contract does not accept Ether");
    }
}