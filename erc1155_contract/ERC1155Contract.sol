// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyToken is ERC1155, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    mapping(address => bool) public isWhitelisted;

    constructor()
        ERC1155("https://bafkreidwqlorpottlbm3kv4377bglblamu6plx47qgmmdxn3laojyegwkm.ipfs.nftstorage.link/")
    {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(uint256 amount, bytes memory data) public onlyOwner{
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _mint(msg.sender, tokenId, amount, data);
    }

    function buyNft(uint256 amount, bytes memory data) public payable{
        require(isWhitelisted[msg.sender] == true, "You are not allowed to buy");
        require(msg.value >= 0.1 ether, "You should pay 0.1 ether");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _mint(msg.sender, tokenId, amount, data);
    }
    
    function addWhitelist(address addr) public onlyOwner{
        bool curr_state = isWhitelisted[addr];
        isWhitelisted[addr] = !curr_state; 
    }
}