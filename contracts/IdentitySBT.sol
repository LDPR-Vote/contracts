// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract IdentitySBT is ERC721 {
    uint public nextTokenId;
    address public owner;
    mapping(address => bool) public isVerified;

    constructor() payable ERC721("LDPR Verified Citizen", "LDPRVC") {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function issue(address to) external payable onlyOwner {
        require(!isVerified[to], "Already verified");
        _mint(to, nextTokenId++);
        isVerified[to] = true;
    }

    // Soulbound: запретить передачу
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override returns (address) {
        require(
            auth == address(0) || to == address(0),
            "Soulbound: non-transferable"
        );

        return super._update(to, tokenId, auth);
    }
}
