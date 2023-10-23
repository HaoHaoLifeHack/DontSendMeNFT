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
        return
            "https://github.com/HaoHaoLifeHack/DontSendMeNFT/blob/main/src/metadata/poop.json"; //指向同一份metadata (hardcode)
    }
}

contract MyNFT is ERC721 {
    constructor() ERC721("MyNFT", "MNFT") {}

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}

contract NFTReceiver is IERC721Receiver {
    NoUseful public noUseful;
    uint256 mintedAmount;

    constructor(address _noUseful) {
        noUseful = NoUseful(_noUseful);
        mintedAmount = 1;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public override returns (bytes4) {
        // 1. check the msg.sender(NoUseful contract) is same as the NoUseful token
        if (msg.sender != address(noUseful)) {
            // 2. if not, please transfer your token back to the original owner.

            IERC721(msg.sender).safeTransferFrom( //safeTransferFrom(address from, address to, uint256 tokenId)
                address(this),
                operator,
                tokenId,
                data
            );
            // 3. and also mint your NoUseful to the original owner.
            uint256 newTokenId = mintedAmount;
            noUseful.mint(operator, newTokenId);
            mintedAmount++;
        }

        return this.onERC721Received.selector;
    }
}
