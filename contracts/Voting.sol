// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Voting {
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    event CandidateAdded(uint id, string name);

    event CandidateRemoved(uint id);

    event Voted(address voter, uint candidateId);

    modifier nameIsNotEmpty(string memory _name) {
        require(bytes(_name).length > 0, "Name cannot be empty");
        _;
    }

    modifier validCandidate(uint _candidateId) {
        require(
            _candidateId > 0 && _candidateId <= candidatesCount,
            "Invalid candidate"
        );
        _;
    }

    modifier voteOnlyOnce() {
        require(!voters[msg.sender], "You already voted");
        _;
    }

    mapping(address => bool) public voters;
    mapping(uint => Candidate) public candidates;
    uint public candidatesCount;

    function addCandidate(string memory _name) public nameIsNotEmpty(_name) {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);

        emit CandidateAdded(candidatesCount, _name);
    }

    function removeCandidate(uint _id) public {
        delete candidates[_id];
    }

    function getAllCandidates() public view returns (Candidate[] memory) {
        Candidate[] memory _candidates = new Candidate[](candidatesCount);

        for (uint i = 1; i <= candidatesCount; i++) {
            _candidates[i - 1] = candidates[i];
        }

        return _candidates;
    }

    function castVote(
        uint _candidateId
    ) public validCandidate(_candidateId) voteOnlyOnce {
        voters[msg.sender] = true;
        candidates[_candidateId].voteCount++;

        emit Voted(msg.sender, _candidateId);
    }

    function getWinner() public view returns (Candidate memory) {
        Candidate memory winner = candidates[1];

        for (uint i = 2; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > winner.voteCount) {
                winner = candidates[i];
            }
        }

        return winner;
    }
}
