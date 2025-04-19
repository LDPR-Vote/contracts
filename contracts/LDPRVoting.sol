// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISBT {
    function balanceOf(address owner) external view returns (uint256);
}

contract LDPRVoting {
    address public owner;
    ISBT public sbt;

    struct VoteSession {
        string question;
        string[] options;
        mapping(uint => uint) results;
        mapping(address => bool) hasVoted;
        uint startTime;
        uint endTime;
        bool exists;
    }

    uint public sessionCount;
    mapping(uint => VoteSession) private sessions;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyVerified() {
        require(sbt.balanceOf(msg.sender) > 0, "Not verified (no SBT)");
        _;
    }

    constructor(address _sbt) {
        owner = msg.sender;
        sbt = ISBT(_sbt);
    }

    function createVote(string memory _question, string[] memory _options, uint durationSec) external onlyOwner {
        require(_options.length >= 2, "Need at least 2 options");
        sessionCount++;
        VoteSession storage s = sessions[sessionCount];
        s.question = _question;
        s.options = _options;
        s.startTime = block.timestamp;
        s.endTime = block.timestamp + durationSec;
        s.exists = true;
    }

    function vote(uint sessionId, uint optionId) external onlyVerified {
        VoteSession storage s = sessions[sessionId];
        require(s.exists, "No such session");
        require(block.timestamp >= s.startTime && block.timestamp <= s.endTime, "Voting not active");
        require(optionId < s.options.length, "Invalid option");
        require(!s.hasVoted[msg.sender], "Already voted");

        s.hasVoted[msg.sender] = true;
        s.results[optionId]++;
    }

    function getResults(uint sessionId) external view returns (uint[] memory) {
        VoteSession storage s = sessions[sessionId];
        require(block.timestamp > s.endTime, "Voting not ended");

        uint[] memory resultCounts = new uint[](s.options.length);
        for (uint i = 0; i < s.options.length; i++) {
            resultCounts[i] = s.results[i];
        }

        return resultCounts;
    }
}
