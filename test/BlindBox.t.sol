// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import "../src/BlindBox.sol";

contract BlindBoxTest is Test {
    BlindBox blindBox;
    uint256 nonce;
    address user1 = makeAddr("Alice");
    address user2 = makeAddr("Bob");

    function setUp() public {
        nonce = 0;
        blindBox = new BlindBox();
    }

    function testBlindBox() public {
        vm.startPrank(user1);

        // mint 兩顆 NFT
        uint256 randomTokenId1 = getRandomTokenId();
        blindBox.mint(user1, randomTokenId1);
        string memory tokenURI1 = blindBox.tokenURI(randomTokenId1);

        uint256 randomTokenId2 = getRandomTokenId();
        blindBox.mint(user1, randomTokenId2);
        string memory tokenURI2 = blindBox.tokenURI(randomTokenId2);

        // 檢查兩次 mint 所產生的隨機數不一樣
        assertFalse(randomTokenId1 == randomTokenId2);

        // 檢查兩個 NFT 的 tokenURI 是否相同（一開始都是盲盒狀態）
        assertEq(tokenURI1, tokenURI2);
        assertEq(
            keccak256(bytes(tokenURI1)),
            keccak256(bytes("blindBox.json"))
        );

        vm.stopPrank();

        // 只有擁有者可開啟盲盒
        vm.prank(user2);
        vm.expectRevert("Only the owner can open this token!");
        blindBox.openBox(randomTokenId1);

        vm.startPrank(user1);

        // 只有超過發行 NFT 合約10天後可開啟盲盒
        vm.expectRevert("It's not the time to open it!");
        blindBox.openBox(randomTokenId2);

        // 正確執行打開盲盒的 function 後檢查是否是正確的 tokenURI
        vm.warp(blindBox.createdTime() + 10 days);
        blindBox.openBox(randomTokenId1);
        blindBox.openBox(randomTokenId2);

        assertEq(tokenURI1, tokenURI2);
        string memory openedBoxURI1 = blindBox.tokenURI(randomTokenId1);
        assertEq(
            keccak256(bytes(openedBoxURI1)),
            keccak256(bytes("openBox.json"))
        );

        // 經查 totalSupply storageData 位於slot 6, 模擬totalSupply為0的情況
        vm.store(address(blindBox), bytes32(uint256(6)), bytes32(uint256(0)));
        vm.expectRevert("No any tokens left!");
        blindBox.mint(user1, getRandomTokenId());

        vm.stopPrank();
    }

    function getRandomTokenId() public returns (uint256) {
        uint256 randomTokenId = uint256(
            keccak256(abi.encodePacked(block.timestamp, nonce))
        );
        nonce++;
        return randomTokenId;
    }
}
