// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BlindBox is ERC721 {
    uint256 public totalSupply;
    mapping(uint256 => bool) blindNFTs;
    uint256 public createdTime;
    uint256 private nonce = 0;

    constructor() ERC721("BlindBoxToken", "BBT") {
        totalSupply = 500;
        createdTime = block.timestamp;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        _requireOwned(tokenId); //驗證nft擁有權
        if (blindNFTs[tokenId]) {
            //true 表示解盲
            return "openBox.json"; //open image metadata
        }
        return "blindBox.json"; //hide image metadata
    }

    function openBox(uint256 tokenId) public {
        require(
            ownerOf(tokenId) == msg.sender,
            "Only the owner can open this token!"
        );
        require(
            block.timestamp - createdTime >= 10 days,
            "It's not the time to open it!"
        );
        blindNFTs[tokenId] = true;
    }

    function mint(address to, uint256 tokenId) public {
        require(totalSupply > 0, "No any tokens left!");
        // 將隨機數當作 tokenId 產生 NFT
        _mint(to, tokenId);
    }
}
