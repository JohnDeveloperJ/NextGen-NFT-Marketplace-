// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title A token tracker that mint NFTs with unique token URIs
/// @dev Extends ERC721 Non-Fungible Token Standard basic implementation with URI storage
contract messageNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    /// @dev Counter to keep track of token ids
    Counters.Counter private _tokenIds;

    /// @notice Contract constructor sets NFT name, symbol, and owner
    /// @dev The Ownable constructor is called with initialOwner, setting the deployer as the initial owner if no address is provided
    /// @param initialOwner The initial owner of the contract, which is capable of minting NFTs
    constructor(address initialOwner) ERC721("Base Head", "BASE") Ownable(initialOwner) {}

    /// @notice Total number of NFTs minted so far
    /// @return The current total supply of minted tokens
    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }

    /// @notice Mints an NFT to a given address with a token URI
    /// @dev Mints a new token to the provided recipient address with the token URI specified
    /// @param recipient The address that will receive the minted NFT
    /// @param tokenURI The URI of the token being minted
    /// @return newItemId The token ID of the minted NFT
    /// @custom:modifiers onlyOwner - Only the owner of the contract can mint NFTs
    function mintNFT(address recipient, string memory tokenURI)
        public
        onlyOwner
        returns (uint256)
    {
        require(bytes(tokenURI).length > 0, "NFT URI is empty");
        
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        emit NFTMinted(recipient, newItemId, tokenURI);

        return newItemId;
    }

    /// @dev Emitted when a new NFT is minted
    /// @param recipient The recipient of the NFT
    /// @param newItemId The token ID of the minted NFT
    /// @param tokenURI The URI of the minted token
    event NFTMinted(address indexed recipient, uint256 indexed newItemId, string tokenURI);
}
