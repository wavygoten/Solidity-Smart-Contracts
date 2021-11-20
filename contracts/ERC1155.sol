// SPDX-License-Identifier: MIT
// solium-disable linebreak-style
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC1155, Ownable {
    
	uint256 public TOKEN_PRICE = 0.02 ether;
	uint256 public PUBLIC_TOKEN = 0;
	uint256 public WHITELIST_TOKEN = 0;
	uint256 private MAX_MINT_PER_PURCHASE = 1;
	
	bool public SALE_LIVE = true;

    mapping(address => bool) public whitelist;
    mapping(address => uint256) public whitelistPurchases;


    constructor(string memory tokenURI) public ERC1155(tokenURI) {}
    
    // ADDING ADDRESSES TO WHITELIST
    function addToWhitelist(address[] calldata entries) external onlyOwner {
        for(uint256 i = 0; i < entries.length; i++) {
            address entry = entries[i];
            require(entry != address(0), "NULL_ADDRESS");
            require(!whitelist[entry], "DUPLICATE_ENTRY");
            whitelist[entry] = true;
        }   
    }
    
    // SET NEW PRICE IN WEI
    function setPrice(uint256 newPrice) public onlyOwner {
        TOKEN_PRICE = newPrice;
    }
    
    // SET MAX MINT PER PURCHASE
    function setMaxMint(uint256 newMint) public onlyOwner {
        MAX_MINT_PER_PURCHASE = newMint;
    }
    
    // MINT PUBLIC
    function mint(uint256 numberOfTokens) public payable {
        require(numberOfTokens <= MAX_MINT_PER_PURCHASE, "Exceeded max token purchase");
		require(SALE_LIVE, "Sale is Not Live Yet");
		require(TOKEN_PRICE * numberOfTokens <= msg.value, "Ether value sent is not correct");
		_mint(msg.sender, PUBLIC_TOKEN, numberOfTokens, "");
		PUBLIC_TOKEN = PUBLIC_TOKEN + numberOfTokens;
    }
    
    // MINT WHITELIST
    function whitelistMint(uint256 numberOfTokens) public payable {
        require(SALE_LIVE, "Sale is Not Live Yet");
        require(whitelist[msg.sender], "Invalid Whitelist Address");
        require(numberOfTokens <= MAX_MINT_PER_PURCHASE, "Exceeded max token purchase");
        require(whitelistPurchases[msg.sender] + 1 <= 1, "Only one token per address");
        _mint(msg.sender, WHITELIST_TOKEN, numberOfTokens, "");
        WHITELIST_TOKEN = WHITELIST_TOKEN + numberOfTokens;
    }
    
    // START SALE
	function startSale() public onlyOwner {
		SALE_LIVE = true;
	}

    // STOP SALE
	function stopSale() public onlyOwner {
		SALE_LIVE = false;
	}
	
	// VERIFY OWNERSHIP
    function _ownerOf(uint256 tokenId) internal view returns (bool) {
        return balanceOf(msg.sender, tokenId) != 0;
    }

    // BALANCE OF CONTRACT
	function balance() public view returns (uint256) {
		return address(this).balance;
	}

    // WITHDRAW TO OWNER ADDRESS
	function withdraw() public onlyOwner {
		address payable to = payable(msg.sender);
		to.transfer(balance());
	}

    // WITHDRAW TO SPECIFIC ADDRESS
	function withdrawTo(address payable _to) public onlyOwner {
		_to.transfer(balance());
	}
}