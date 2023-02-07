//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Community {
    Member[] public s_membersArray;
    mapping(address => uint256) internal s_membersMap;
    mapping(address => bool) internal s_memberExists;

    struct Member {
        address memberAddress;
        string name;
        address[] friends;
        mapping(address => bool) hasFriend;
    }

    modifier mustBothBeMembers(address _a, address _b) {
        require(s_memberExists[_a]);
        require(s_memberExists[_b]);
        _;
    }

    modifier mustBeMember() {
        require(s_memberExists[msg.sender]);
        _;
    }

    modifier mustBeNewMember() {
        require(!s_memberExists[msg.sender]);
        _;
    }

    function addMember(string memory _name) public mustBeNewMember {
        //Member memory m;                 //initiailze without array is ok https://ethereum.stackexchange.com/questions/30857/how-to-initialize-an-empty-array-inside-a-struct
        Member storage m = s_membersArray.push();
        m.memberAddress = msg.sender;
        m.name = _name;

        m.hasFriend[msg.sender] = true;

        //add member to map for easy getting
        uint256 arrayLength = s_membersArray.length;
        s_membersMap[msg.sender] = arrayLength - 1;

        //add member to s_memberExists for lookup
        s_memberExists[msg.sender] = true;
    }

    function removeMember(address _i) public {
        require(s_memberExists[_i]);
        s_memberExists[_i] = false;

        uint256 memberPosition = s_membersMap[_i];
        delete s_membersArray[memberPosition];

        s_membersMap[_i] = 0;
    }

    function addFriend(
        address _friendsAddress
    ) public mustBothBeMembers(msg.sender, _friendsAddress) {
        //update array
        uint256 msgSenderArrayPos = s_membersMap[msg.sender]; //get the msg senders friends list
        s_membersArray[msgSenderArrayPos].friends.push(_friendsAddress); //add their friend

        s_membersArray[msgSenderArrayPos].hasFriend[_friendsAddress] = true;

        uint256 friendArrayPos = s_membersMap[_friendsAddress]; //repeat on the friends list
        s_membersArray[friendArrayPos].friends.push(msg.sender);

        s_membersArray[friendArrayPos].hasFriend[msg.sender] = true;
    }

    function removeFriends(
        address _friendsAddress
    ) public mustBothBeMembers(msg.sender, _friendsAddress) {
        //delete friends from each others friends list
        s__setMembersArrayDelete(msg.sender, _friendsAddress);
        _setFriendsMap(msg.sender, _friendsAddress, false);
    }

    //use this to delete an address from the member friends array
    function s__setMembersArrayDelete(address _a, address _b) private {
        uint256 memberA = s_membersMap[_a];
        address[] storage friendsOfA = s_membersArray[memberA].friends;
        for (uint256 i = 0; i < friendsOfA.length; i++) {
            if (friendsOfA[i] == _b) delete friendsOfA[i];
        }

        uint256 memberB = s_membersMap[_b];
        address[] storage friendsOfB = s_membersArray[memberB].friends;
        for (uint256 i = 0; i < friendsOfB.length; i++) {
            if (friendsOfB[i] == _a) {
                delete friendsOfB[i];
            }
        }
    }

    function getFriendsMap(
        address _a,
        address _b
    ) public view returns (bool, bool) {
        uint256 memberArrayPosOfA = s_membersMap[_a];
        bool resA = s_membersArray[memberArrayPosOfA].hasFriend[_b];

        uint256 memberArrayPosOfB = s_membersMap[_b];
        bool resB = s_membersArray[memberArrayPosOfB].hasFriend[_a];

        return (resA, resB);
    }

    function _setFriendsMap(address _a, address _b, bool _bool) public {
        uint256 memberArrayPosOfA = s_membersMap[_a];
        s_membersArray[memberArrayPosOfA].hasFriend[_b] = _bool;

        uint256 memberArrayPosOfB = s_membersMap[_b];
        s_membersArray[memberArrayPosOfB].hasFriend[_a] = _bool;
    }

    function displayLastFriend(address _i) public view returns (address) {
        uint256 memberArrayPos = s_membersMap[_i];
        uint256 friendsArrayLength = s_membersArray[memberArrayPos]
            .friends
            .length - 1;
        return s_membersArray[memberArrayPos].friends[friendsArrayLength];
    }
}
