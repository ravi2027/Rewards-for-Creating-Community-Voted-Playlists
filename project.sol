// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CommunityPlaylistRewards {
    struct Playlist {
        string name;
        address creator;
        uint256 votes;
        uint256 creationTime;
    }

    Playlist[] public playlists;
    mapping(address => bool) public hasVoted;
    address public owner;
    uint256 public rewardAmount;

    event PlaylistCreated(string name, address creator);
    event Voted(uint256 playlistId, address voter);
    event RewardClaimed(address recipient, uint256 amount);

    constructor(uint256 _rewardAmount) {
        owner = msg.sender;
        rewardAmount = _rewardAmount;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    modifier hasNotVoted() {
        require(!hasVoted[msg.sender], "You have already voted.");
        _;
    }

    function createPlaylist(string memory _name) public {
        playlists.push(Playlist({
            name: _name,
            creator: msg.sender,
            votes: 0,
            creationTime: block.timestamp
        }));

        emit PlaylistCreated(_name, msg.sender);
    }

    function voteForPlaylist(uint256 playlistId) public hasNotVoted {
        require(playlistId < playlists.length, "Invalid playlist ID.");

        playlists[playlistId].votes++;
        hasVoted[msg.sender] = true;

        emit Voted(playlistId, msg.sender);
    }

    function claimReward() public {
        uint256 maxVotes = 0;
        uint256 winningIndex = 0;

        for (uint256 i = 0; i < playlists.length; i++) {
            if (playlists[i].votes > maxVotes) {
                maxVotes = playlists[i].votes;
                winningIndex = i;
            }
        }

        require(msg.sender == playlists[winningIndex].creator, "Only the creator of the top playlist can claim the reward.");

        payable(msg.sender).transfer(rewardAmount);

        emit RewardClaimed(msg.sender, rewardAmount);
    }

    function fundContract() public payable onlyOwner {}

    function updateRewardAmount(uint256 _rewardAmount) public onlyOwner {
        rewardAmount = _rewardAmount;
    }

    function getPlaylists() public view returns (Playlist[] memory) {
        return playlists;
    }
}