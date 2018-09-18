pragma solidity ^0.4.22;

import "./PointBank.sol";
import "./Auction.sol";
import "./Strings.sol";
import "./Pausable.sol"; //Source from github

contract Game is Pausable {

    //@dev https://github.com/Arachnid/solidity-stringutils
    using Strings for *;


    // @dev var et; Game.deployed().then(function(instance){et = instance;});
    // @dev et.challenge('0x34f5c9DE986bc6c26d704b8510330dfFfF9cDAc8', 0).then(function(ret){console.log(ret.logs[0].args.challenger)})
    event ProfileCreated(string name, address addr);
    event Challenge(address challenger, address challenged, int option);
    event ChallengeResult(int challengedOption, address winner, bool draw);
    
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

    modifier validOption(int _value) {
        require(int(Option.Scissors) >= _value);
        _;
    }

    Profile[] private players;
    address[] private addresses;
    PointBank public pointBank;
    Auction public auction;
    uint private percentage;

    string constant separator = "-";

    constructor() public {
        pointBank = new PointBank();
        auction = new Auction(address(pointBank));
        pauseGame();
    }

    // @dev Game.deployed().then(function(instance){return instance.setUp(10)});
    function setUp(uint _percentage) public whenPaused onlyPauser {
        percentage = _percentage;
    }

    // @dev Game.deployed().then(function(instance){return instance.createProfile("Raul", 0)});
    function createProfile(string _name, int _option) public whenNotPaused {
        //check doesn't exist another Profile with the same address
        players.push(Profile(_name, msg.sender, _option));
        addresses.push(msg.sender);
        emit ProfileCreated(_name, msg.sender);
        pointBank.givePoints(msg.sender, 1000); //temp
    }

    // @dev Game.deployed().then(function(instance){return instance.challenge('', 0)});
    function challenge(address _challenged, int _option) public validOption(_option) whenNotPaused returns(uint) {
        for (uint i = 0; i < players.length; ++i) {
            if (players[i].addr == _challenged) {
                emit Challenge(msg.sender, _challenged, _option);
                if (_option == players[i].defaultOption) {
                    emit ChallengeResult(players[i].defaultOption, 0, true); // DRAW
                } else if ((_option - players[i].defaultOption) % 5 < 3) {
                    pointBank.transferFromGame(msg.sender, _challenged, 10);
                    emit ChallengeResult(players[i].defaultOption, _challenged, false); //Has won the challenged
                } else {
                    pointBank.transferFromGame(_challenged, msg.sender, 10);
                    emit ChallengeResult(players[i].defaultOption, msg.sender, false); //Has won the challenger
                }
            }
        }
    }

    function getPlayers() public view returns(address[], string) {
        string memory names;
        for (uint i = 0; i < players.length; ++i) {
            string memory part;
            if (i != 0) {
                part = separator.toSlice().concat(players[i].name.toSlice());
            }
            else {
                part = players[i].name;
            }
            names = names.toSlice().concat(part.toSlice());
        }
        return (addresses, names);
    }

    function pauseGame() public whenNotPaused onlyPauser {
        pause();
        pointBank.pause();
        auction.pause();
    }

    // @dev Game.deployed().then(function(instance){return instance.resumeGame()})
    function resumeGame() public whenPaused onlyPauser {
        unpause();
        pointBank.unpause();
        auction.unpause();
    }
}