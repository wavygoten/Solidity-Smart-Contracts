// SPDX-License-Identifier: None
// solium-disable linebreak-style

/*
  ░░██████   ░░██████   ░░██████  
  ░██        ░██        ░██       
  ░██  ░██   ░██  ░██  ░██  ░██  
   ██░  ░██   ██░  ░██   ██░  ░██ 
    ██████     ██████     ██████ 
            
  Grim Ghostly Ghosts | 2021 | V1.0
*/

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Ghosts is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
	using Counters for Counters.Counter;

	Counters.Counter private _tokenIdCounter;

	uint256 public MAX_SUPPLY = 1111;
	uint256 public PRICE = 0.02 ether;
	uint256 public MINT_COUNT = 0;

	bool public SALE_LIVE;

	constructor() ERC721("Ghosts", "GGG") {
		SALE_LIVE = false;
	}

	function _baseURI() internal pure override returns (string memory) {
		return
			"https://ipfs.io/ipfs/QmUYf7tnmgcum6wi7XeSsTbYqnazbSUa6RUGbLKyMndZEC/";
	}

	function Mint(address to) public payable {
		require(msg.value >= PRICE, "Not Enough Ether Sent.");
		require(MINT_COUNT < MAX_SUPPLY, "All Ghosts Have Been Minted.");
		require(SALE_LIVE, "Sale is Not Live Yet");
		_safeMint(to, _tokenIdCounter.current());
		_tokenIdCounter.increment();
		MINT_COUNT = MINT_COUNT + 1;
	}

	function startSale() public onlyOwner {
		SALE_LIVE = true;
	}

	function stopSale() public onlyOwner {
		SALE_LIVE = false;
	}

	function balance() public view returns (uint256) {
		//view amount of ETH the contract contains
		return address(this).balance;
	}

	function withdraw() public onlyOwner {
		address payable to = payable(msg.sender);
		to.transfer(balance());
	}

	function withdrawTo(address payable _to) public onlyOwner {
		_to.transfer(balance());
	}

	// The following functions are overrides required by Solidity.

	function _beforeTokenTransfer(
		address from,
		address to,
		uint256 tokenId
	) internal override(ERC721, ERC721Enumerable) {
		super._beforeTokenTransfer(from, to, tokenId);
	}

	function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
		super._burn(tokenId);
	}

	function tokenURI(uint256 tokenId)
		public
		view
		override(ERC721, ERC721URIStorage)
		returns (string memory)
	{
		return super.tokenURI(tokenId);
	}

	function supportsInterface(bytes4 interfaceId)
		public
		view
		override(ERC721, ERC721Enumerable)
		returns (bool)
	{
		return super.supportsInterface(interfaceId);
	}
}