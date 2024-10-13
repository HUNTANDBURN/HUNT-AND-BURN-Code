// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC20Interface {
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function transfer(address to, uint256 tokens) external returns (bool success);
    function decimals() external view returns (uint8);
    event Transfer(address indexed from, address indexed to, uint256 tokens);
}

contract HABCrowdsale {
    address public owner;
    ERC20Interface public tokenContract;
    uint256 public tokensPerEther;
    uint256 public weiRaised;

    event TokensPurchased(address indexed purchaser, uint256 amount, uint256 value);
    event EtherWithdrawn(address indexed to, uint256 amount);
    event TokensWithdrawn(address indexed to, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(ERC20Interface _tokenContract) {
        owner = msg.sender;
        tokenContract = _tokenContract;
        tokensPerEther = 1_000_000 * 10 ** uint256(tokenContract.decimals());
    }

    function buyTokens() public payable {
        require(msg.value > 0, "You need to send some ether");
        uint256 tokensToBuy = (msg.value * tokensPerEther) / 1 ether;
        require(tokenContract.balanceOf(address(this)) >= tokensToBuy, "Not enough tokens in contract");
        tokenContract.transfer(msg.sender, tokensToBuy);
        weiRaised += msg.value;
        emit TokensPurchased(msg.sender, tokensToBuy, msg.value);
    }

    function withdrawEther() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ether to withdraw");
        payable(owner).transfer(balance);
        emit EtherWithdrawn(owner, balance);
    }

    function withdrawTokens(uint256 amount) public onlyOwner {
        require(tokenContract.balanceOf(address(this)) >= amount, "Not enough tokens in contract");
        tokenContract.transfer(owner, amount);
        emit TokensWithdrawn(owner, amount);
    }

    function contractEtherBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function contractTokenBalance() public view returns (uint256) {
        return tokenContract.balanceOf(address(this));
    }

    function totalFundsRaised() public view returns (uint256) {
        return weiRaised;
    }
}
