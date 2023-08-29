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

    modifier validCandidate(uint16 _canditateId) {
        require(
            _canditateId > 0 &&
                _canditateId <= lastCandidateId &&
                candidates[_canditateId].id != 0,
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
    uint16 lastCandidateId;

    function addCandidate(string memory _name) public nameIsNotEmpty(_name) {
        lastCandidateId++;
        candidates[lastCandidateId] = Candidate(lastCandidateId, _name, 0);

        emit CandidateAdded(lastCandidateId, _name);
    }

    function removeCandidate(uint _id) public {
        delete candidates[_id];
    }

    function getAllCandidates() public view returns (Candidate[] memory) {
        Candidate[] memory _candidates = new Candidate[](lastCandidateId);

        for (uint i = 1; i <= lastCandidateId; i++) {
            _candidates[i - 1] = candidates[i];
        }

        return _candidates;
    }

    function castVote(
        uint16 _candidateId
    ) public validCandidate(_candidateId) voteOnlyOnce {
        voters[msg.sender] = true;
        candidates[_candidateId].voteCount++;

        emit Voted(msg.sender, _candidateId);
    }

    function getWinner() public view returns (Candidate memory) {
        Candidate memory winner = candidates[1];

        for (uint i = 2; i <= lastCandidateId; i++) {
            if (candidates[i].voteCount > winner.voteCount) {
                winner = candidates[i];
            }
        }

        return winner;
    }

    function candidatesCount() public view returns (uint16) {
        uint16 count = 0;

        for (uint i = 1; i <= lastCandidateId; i++) {
            if (candidates[i].id != 0) {
                count++;
            }
        }

        return count;
    }
}
