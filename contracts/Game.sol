pragma solidity ^0.4.22;

import "./PointBank.sol";
import "./Auction.sol";

contract Game {
    
    enum Option {
        Rock,
        Paper,
        Scissors,
        Lizard, 
        Spock
    }

    struct Match {
        mapping (address => Option) options;
        address challenging;
        address challenged;
        address winner;
    }

    Match[] matches;
    address pointBankAddress;
    address auctionAddress;
    uint percentage;

    function startGame(uint _percentage) public {
        pointBankAddress = address(new PointBank());
        auctionAddress = address(new Auction(pointBankAddress));
        percentage = _percentage;
    }

    // @dev Game.deployed().then(function(instance){return instance.challenge('0x54F2208866d60768bC4FB5C2f8e0F18f90b60Af7', 0)});
    function challenge(address _challenged, Option _option) public returns(uint){
        Match memory m = Match({challenging: msg.sender, challenged: _challenged, winner: msg.sender});
        uint id = matches.push(m);
        matches[id].options[msg.sender] = _option;
        return id;
    }

    function challengeAccepted(uint _match_id, Option _option) public {
        Match m = matches[_match_id];
        m.options[m.challenged] = _option;
        uint challenging = name_to_number(m.options[m.challenged]);
        uint challenged = name_to_number(m.options[m.challenging]);
        if (challenging == challenged) {
            //play again
        }
        else if ((challenging - challenged)%5 < 3) {
            m.winner = m.challenging;
        }
        else {
            m.winner = m.challenged;
        }
    }

    function name_to_number(Option _name) internal pure returns(uint){
        if (_name == Option.Rock)
            return 0;
        else if (_name == Option.Spock)
            return 1;
        else if (_name == Option.Paper)
            return 2;
        else if (_name == Option.Lizard)
            return 3;
        else if (_name == Option.Scissors)
            return 4;
        else 
            return 5;
    }

}