// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title A token tracker that mints NFTs with unique token URIs
/// @dev Extends ERC721 Non-Fungible Token Standard basic implementation with URI storage
contract messageNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("Base Head", "BASE") Ownable(msg.sender) {}

    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }

    function mintNFT(address recipient, string memory tokenURI)
        public
        onlyOwner
        returns (uint256)
    {
        require(bytes(tokenURI).length > 0, "NFT URI is empty");
        require(recipient != address(0), "Recipient address cannot be zero");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        emit NFTMinted(recipient, newItemId, tokenURI);

        return newItemId;
    }

    event NFTMinted(address indexed recipient, uint256 indexed newItemId, string tokenURI);
}
