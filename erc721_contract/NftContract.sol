// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NftContract is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    mapping(uint => bool) public itemIsListed;
    mapping(uint => uint) public itemPrice;
    uint max_minted;
    uint minted;

    constructor() ERC721("NftContract", "ImageToken") {
        minted = 0;
        max_minted = 5;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    function setMaxMinted(uint _max_minted) public onlyOwner{
        max_minted = _max_minted;
    }

    // tokenUri (input) = bafybeiejbznfe2765tbfvs5zu4p53ycd6zsp5xovlfdnqdyhs2ybsw5zcy
    // total tokenURI = baseURI + tokenURI
    function createItem(string memory tokenUri) public onlyOwner{
        require(minted <= max_minted, "You have no more supply");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenUri);
        minted++;
    }

    function listItem(uint tokenId, uint price) public {
        require(msg.sender == ownerOf(tokenId), "You are not the owner");
        require(!itemIsListed[tokenId], "Item is already on sale");

        itemIsListed[tokenId] = true;
        itemPrice[tokenId] = price;
    }

    function buyItem(uint tokenId) public payable{
        uint price = itemPrice[tokenId];
        require(itemIsListed[tokenId], "Item is not available for sale");
        require(msg.value == price, "Please send the correct amount");

        _approve(msg.sender, tokenId);
        _safeTransfer(ownerOf(tokenId), msg.sender, tokenId, "");
        itemIsListed[tokenId] = false;
    }

    function cancel(uint tokenId) public {
        require(msg.sender == ownerOf(tokenId), "You are not the owner");
        require(itemIsListed[tokenId], "Item is not available for sale");
        itemIsListed[tokenId] = false;
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}