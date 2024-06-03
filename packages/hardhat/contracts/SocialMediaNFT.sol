// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract SocialMediaNFT is ERC721Enumerable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    
    mapping(uint256 => uint256) public stakedTokens;
    mapping(uint256 => bool) public isStaked;
    mapping(address => uint256) public userStakeBalance;
    uint256 public totalStakedTokens;
    
    event TokenStaked(uint256 tokenId, uint256 amount);
    event TokenUnstaked(uint256 tokenId, uint256 amount);

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    function stakeToken(uint256 tokenId, uint256 amount) external {
        require(ownerOf(tokenId) == msg.sender, "You do not own this token");
        require(!isStaked[tokenId], "Token is already staked");

        stakedTokens[tokenId] = amount;
        isStaked[tokenId] = true;
        userStakeBalance[msg.sender] += amount;
        totalStakedTokens += amount;

        emit TokenStaked(tokenId, amount);
    }

    function unstakeToken(uint256 tokenId, uint256 amount) external {
        require(ownerOf(tokenId) == msg.sender, "You do not own this token");
        require(isStaked[tokenId], "Token is not staked");
        require(stakedTokens[tokenId] >= amount, "Insufficient staked amount");

        stakedTokens[tokenId] -= amount;
        userStakeBalance[msg.sender] -= amount;
        totalStakedTokens -= amount;

        if (stakedTokens[tokenId] == 0) {
            isStaked[tokenId] = false;
        }

        emit TokenUnstaked(tokenId, amount);
    }

    function mintNFT(address to) external {
        _mint(to, _tokenIdCounter.current());
        _tokenIdCounter.increment();
    }
}