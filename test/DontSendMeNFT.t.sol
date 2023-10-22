// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {NoUseful, NFTReceiver, MyNFT} from "../src/DontSendMeNFT.sol";

contract DontSendMeNFTTest is Test {
    error ERC721InvalidSender(address sender);

    NoUseful public noUseful;
    MyNFT public myNFT;
    NFTReceiver public nftReceiver;
    uint256 mintedAmount;

    address user1 = makeAddr("Alice");
    address user2 = makeAddr("Bob");

    function setUp() public {
        noUseful = new NoUseful();
        nftReceiver = new NFTReceiver(address(myNFT), address(noUseful));
        myNFT = new MyNFT();
        mintedAmount = 0;
    }

    function testNoUseful() public {
        uint256 tokenId0 = 0;
        uint256 tokenId1 = 1;

        vm.startPrank(user1);
        noUseful.mint(user1, tokenId0);

        // mint 後是否 owner 為 user1
        assertEq(noUseful.ownerOf(tokenId0), user1);
        // name 和 symbol 是否正確
        assertEq(
            keccak256(bytes(noUseful.name())),
            keccak256("Don't send NFT to me")
        );
        assertEq(keccak256(bytes(noUseful.symbol())), keccak256("NONFT"));

        // 如果之前這個 tokenId 有被 mint 過則 revert error
        vm.expectRevert(
            abi.encodeWithSelector(ERC721InvalidSender.selector, address(0))
        );

        noUseful.mint(user1, tokenId0);
        // mint 另一顆來檢查是否都是相同的 meta data
        noUseful.mint(user1, tokenId1);

        assertEq(
            keccak256(bytes(noUseful.tokenURI(tokenId0))),
            keccak256(bytes(noUseful.tokenURI(tokenId1)))
        );

        vm.stopPrank();
    }

    function testNFTReceiver() public {
        uint256 tokenId = 1;

        vm.startPrank(user1);
        // 如果是 NoUseful 這個 NFT 的話，Receiver 可以接收
        noUseful.mint(user1, tokenId);
        noUseful.safeTransferFrom(user1, address(nftReceiver), tokenId);
        assertEq(noUseful.ownerOf(tokenId), address(nftReceiver));
        assertEq(noUseful.balanceOf(address(nftReceiver)), 1);

        // 如果是收到其他 NFT 的話要退還，所以最後的 owner 還是 user1 自己並且 receiver 不會有 MyNFT 的 balance
        myNFT.safeTransferFrom(user1, address(nftReceiver), tokenId); //safeTransferFrom()
        assertEq(myNFT.ownerOf(tokenId), address(user1));
        assertEq(myNFT.balanceOf(address(nftReceiver)), 0);

        // 退還時還要給一顆 NoUseful NFT
        assertEq(noUseful.balanceOf(user1), 1);
        vm.stopPrank();
    }
}
