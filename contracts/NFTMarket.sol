// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title A marketplace for NFT trading
/// @dev Implements NFT trading logic with non-reentrant protection
contract NFTMarketplace is ReentrancyGuard {
    using Counters for Counters.Counter;

    /// @dev Track the number of items and the number of items sold
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    /// @notice The owner of the marketplace contract
    address payable public owner;

    /// @notice Contract constructor initializes the owner
    constructor() {
        owner = payable(msg.sender);
    }

    /// @dev Represents a single market item
    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    /// @dev Maps itemIds to MarketItems
    mapping(uint256 => MarketItem) private idToMarketItem;

    /// @dev Emitted when a new market item is created
    /// @param itemId The id of the item
    /// @param nftContract The address of the NFT contract
    /// @param tokenId The token id of the NFT
    /// @param seller The address of the seller
    /// @param owner The address of the owner (zero when created)
    /// @param price The price of the item
    /// @param sold The sold status of the item
    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    /// @notice Creates a market item for sale
    /// @dev Transfers ownership of the NFT to the contract and lists it on the market
    /// @param nftContract The address of the NFT contract
    /// @param tokenId The token id of the NFT to list
    /// @param price The price to list the NFT at
    /// @custom:modifiers nonReentrant - Protects against reentrancy attacks
    function createMarketItem(
        address nftContract, uint256 tokenId, uint256 price
    ) public payable nonReentrant {
        require(price > 0, "Price must be at least 1 wei");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            false
        );
    }

    /// @notice Executes the purchase of a market item
    /// @dev Transfers ownership of the NFT from the contract to the buyer and sends the funds to the seller
    /// @param nftContract The address of the NFT contract
    /// @param itemId The id of the market item to purchase
    /// @custom:modifiers nonReentrant - Protects against reentrancy attacks
    function createMarketSale(
        address nftContract,
        uint256 itemId
    ) public payable nonReentrant {
        uint256 price = idToMarketItem[itemId].price;
        uint256 tokenId = idToMarketItem[itemId].tokenId;
        require(msg.value == price, "Please submit the asking price in order to complete the purchase");
        require(!idToMarketItem[itemId].sold, "This item has already been sold");

        idToMarketItem[itemId].seller.transfer(msg.value);
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        idToMarketItem[itemId].owner = payable(msg.sender);
        _itemsSold.increment();
        idToMarketItem[itemId].sold = true;
    }

    /// @notice Retrieves all unsold market items
    /// @dev Loops through all market items to find unsold ones
    /// @return items An array of MarketItem structs representing unsold items
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _itemIds.current();
        uint256 unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(0)) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    /// @notice Fetches all market items that a user has purchased
    /// @dev Loops through all market items to find those owned by the caller
    /// @return items An array of MarketItem structs representing the caller's items
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}
