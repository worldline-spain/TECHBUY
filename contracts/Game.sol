pragma solidity ^0.4.22;

import "./PointBank.sol";
import "./Auction.sol";

contract Game {
    
    enum Option {
        Rock,
        Spock,
        Paper,
        Lizard, 
        Scissors
    }

    struct Profile {
        string name;
        address addr;
        int defaultOption;
    }

    modifier validOption(uint _value) {
        require(uint(Option.Scissors) >= _value);
        _;
    }

    Profile[] players;
    address pointBankAddress;
    address auctionAddress;
    uint percentage;

    // @dev Game.deployed().then(function(instance){return instance.startGame(10)});
    function startGame(uint _percentage) public {
        pointBankAddress = address(new PointBank());
        auctionAddress = address(new Auction(pointBankAddress));
        percentage = _percentage;
    }

    // @dev Game.deployed().then(function(instance){return instance.createProfile("raul", 0)});
    function createProfile(string _name, int _option) public {
        //check doesn't exist another Profile with the same address
        players.push(Profile(_name, msg.sender, _option));
        PointBank(pointBankAddress).givePoints(msg.sender, 1000);
    }

    // @dev Game.deployed().then(function(instance){return instance.challenge('', 0)});
    function challenge(address _challenged, int _option) public /* validOption(_option) */ returns(uint) {
        //require(0 < PointBank(pointBankAddress).balanceOf(msg.sender));
        //require(0 < PointBank(pointBankAddress).balanceOf(_challenged));
        for (uint i = 0; i < players.length; ++i) {
            if (players[i].addr == _challenged) {
                //return 3;
                if ((_option - players[i].defaultOption) % 5 < 3) {
                    PointBank(pointBankAddress).transferFromGame(_challenged, msg.sender, 10);
                    return 0; //Has won the challenger
                } else if (_option == players[i].defaultOption) {
                    return 1; //DRAW
                } else {
                    PointBank(pointBankAddress).transferFromGame(msg.sender, _challenged, 10);
                    return 2; //Has won the challenged
                }
            }

        }
    }

    // @dev Game.deployed().then(function(instance){return instance.getPointBankAddress()});
    function getPointBankAddress() public view returns(address) {
        return pointBankAddress;
    }

    function getAuctionAddress() public view returns(address) {
        return auctionAddress;
    }

}