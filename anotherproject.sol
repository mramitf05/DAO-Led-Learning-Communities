// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LearnToEarnDAO {
    address public owner;
    uint256 public proposalCount;
    uint256 public contentIdCounter;

    struct Content {
        uint256 id;
        address creator;
        string title;
        string description;
        uint256 rewardPerView;
        uint256 views;
    }

    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        uint256 contentId; // Optional, for proposals related to content
    }

    mapping(uint256 => Content) public contents;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => uint256) public userEarnings;
    mapping(uint256 => mapping(address => bool)) public hasVoted; // Track who has voted on each proposal

    event ContentAdded(uint256 id, address creator, string title);
    event ContentViewed(uint256 id, address viewer, uint256 reward);
    event ProposalCreated(uint256 id, address proposer, string description);
    event Voted(uint256 proposalId, address voter, bool vote);
    event ProposalExecuted(uint256 id, bool success);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
        contentIdCounter = 0;
        proposalCount = 0;
    }

    function addContent(string memory _title, string memory _description, uint256 _rewardPerView) public onlyOwner {
        contentIdCounter++;
        contents[contentIdCounter] = Content(contentIdCounter, msg.sender, _title, _description, _rewardPerView, 0);
        emit ContentAdded(contentIdCounter, msg.sender, _title);
    }

    function viewContent(uint256 _contentId) public {
        Content storage content = contents[_contentId];
        require(content.id != 0, "Content not found");

        content.views++;
        userEarnings[msg.sender] += content.rewardPerView;

        emit ContentViewed(_contentId, msg.sender, content.rewardPerView);
    }

    function withdrawEarnings() public {
        uint256 earnings = userEarnings[msg.sender];
        require(earnings > 0, "No earnings to withdraw");

        userEarnings[msg.sender] = 0;
        payable(msg.sender).transfer(earnings);
    }

    function depositFunds() public payable onlyOwner {}

    function createProposal(string memory _description, uint256 _contentId) public {
        proposalCount++;
        proposals[proposalCount] = Proposal(proposalCount, msg.sender, _description, 0, 0, false, _contentId);

        emit ProposalCreated(proposalCount, msg.sender, _description);
    }

    function voteOnProposal(uint256 _proposalId, bool _vote) public {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.id != 0, "Proposal not found");
        require(!hasVoted[_proposalId][msg.sender], "Already voted");

        if (_vote) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        hasVoted[_proposalId][msg.sender] = true;

        emit Voted(_proposalId, msg.sender, _vote);
    }

    function executeProposal(uint256 _proposalId) public onlyOwner {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(proposal.votesFor > proposal.votesAgainst, "Proposal rejected");

        proposal.executed = true;

        // Optional: Execute related content action
        if (proposal.contentId != 0) {
            Content storage content = contents[proposal.contentId];
            content.rewardPerView += 1; // Example action: increase reward per view
        }

        emit ProposalExecuted(_proposalId, true);
    }
}