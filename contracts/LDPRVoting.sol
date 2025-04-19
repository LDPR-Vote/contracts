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

    struct VoteData {
        string question;
        string[] options;
        uint startTime;
        uint endTime;
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

    constructor(address _sbt) payable {
        owner = msg.sender;
        sbt = ISBT(_sbt);
    }

    function createVote(
        string memory _question,
        string[] memory _options,
        uint durationSec
    ) external payable onlyOwner {
        require(_options.length > 1, "Need at least 2 options");
        VoteSession storage s = sessions[++sessionCount];
        s.question = _question;
        s.options = _options;
        s.startTime = block.timestamp;
        s.endTime = block.timestamp + durationSec;
        s.exists = true;
    }

    function vote(uint sessionId, uint optionId) external onlyVerified {
        VoteSession storage s = sessions[sessionId];
        require(s.exists, "No such session");
        require(!(block.timestamp < s.startTime), "Voting not active");
        require(!(block.timestamp > s.endTime), "Voting not active");
        require(optionId < s.options.length, "Invalid option");
        require(!s.hasVoted[msg.sender], "Already voted");

        s.hasVoted[msg.sender] = true;
        s.results[optionId]++;
    }

    function getVote(
        uint sessionId
    ) external view returns (VoteData memory data) {
        VoteSession storage s = sessions[sessionId];
        require(s.exists, "No such session");

        data = VoteData(s.question, s.options, s.startTime, s.endTime);
    }

    function getResults(
        uint sessionId
    ) external view returns (uint[] memory resultCounts) {
        VoteSession storage s = sessions[sessionId];
        require(block.timestamp > s.endTime, "Voting not ended");

        resultCounts = new uint[](s.options.length);

        uint length = s.options.length;

        for (uint i = 0; i < length; ) {
            resultCounts[i] = s.results[i];

            unchecked {
                ++i;
            }
        }
    }
}
