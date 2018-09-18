pragma solidity ^0.4.22;

import "./PointBank.sol";
import "./Auction.sol";
import "./Pausable.sol"; //Source from github

contract Game is Pausable {

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
    PointBank public pointBank;
    Auction public auction;
    uint private percentage;

    constructor() public {
        pointBank = new PointBank();
        auction = new Auction(address(pointBank));
        pauseGame();
    }

    // @dev Game.deployed().then(function(instance){return instance.setUp(10)});
    function setUp(uint _percentage) public whenPaused {
        percentage = _percentage;
    }

    // @dev Game.deployed().then(function(instance){return instance.createProfile("Raul", 0)});
    function createProfile(string _name, int _option) public whenNotPaused {
        //check doesn't exist another Profile with the same address
        players.push(Profile(_name, msg.sender, _option));
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

    function pauseGame() public whenNotPaused {
        pause();
        pointBank.pause();
        auction.pause();
    }

    function resumeGame() public whenPaused {
        unpause();
        pointBank.unpause();
        auction.unpause();
    }
}