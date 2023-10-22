// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NoUseful is ERC721 {
    using Strings for uint256; //Strings lib 使用於uint256 type
    uint256 mintedAmount = 0;

    constructor() ERC721("Don't send NFT to me", "NONFT") {
        //name, symbol
    }

    function mint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
        mintedAmount++;
    }

    function _baseURI() internal view override returns (string memory) {
        return "https://imgur.com/IBDi02f/";
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        //return string(abi.encodePacked(_baseURI(), tokenId.toString()));
        return ""; //指向同一份metadata (hardcode)
    }
}

contract MyNFT is ERC721 {
    using Strings for uint256; //Strings lib 使用於uint256 type

    constructor() ERC721("MyNFT", "MNFT") {}

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}

contract NFTReceiver is IERC721Receiver {
    MyNFT public myNFT;
    NoUseful public noUseful;
    uint256 mintedAmount;

    constructor(address _myNFT, address _noUseful) {
        myNFT = MyNFT(_myNFT);
        noUseful = NoUseful(_noUseful);
        mintedAmount = 0;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public override returns (bytes4) {
        // Check whether the tokenId is your ERC721 token
        require(msg.sender == address(noUseful), "Not accepted token");

        // Return the token to the msg.sender
        IERC721(msg.sender).safeTransferFrom(
            address(this),
            from,
            tokenId,
            data
        );

        // Mint a NONFT to the msg.sender
        uint256 newTokenId = mintedAmount;
        mintedAmount++;
        noUseful.mint(from, newTokenId);

        return this.onERC721Received.selector;
    }
}
