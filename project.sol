// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LearnToEarnPlatform {
    address public owner;
    uint256 public contentIdCounter;
    uint256 public totalRewards;

    struct Content {
        uint256 id;
        address creator;
        string title;
        string description;
        uint256 rewardPerView;
        uint256 views;
    }

    mapping(uint256 => Content) public contents;
    mapping(address => uint256) public userEarnings;

    event ContentAdded(uint256 id, address creator, string title);
    event ContentViewed(uint256 id, address viewer, uint256 reward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
        contentIdCounter = 0;
        totalRewards = 0;
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
        totalRewards += content.rewardPerView;

        emit ContentViewed(_contentId, msg.sender, content.rewardPerView);
    }

    function withdrawEarnings() public {
        uint256 earnings = userEarnings[msg.sender];
        require(earnings > 0, "No earnings to withdraw");

        userEarnings[msg.sender] = 0;
        payable(msg.sender).transfer(earnings);
    }

    function depositFunds() public payable onlyOwner {}

    function getContent(uint256 _contentId) public view returns (Content memory) {
        return contents[_contentId];
    }
}