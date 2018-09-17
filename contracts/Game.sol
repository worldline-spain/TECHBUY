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

    struct Match {
        uint challengingChoice;
        address challenging;
        address challenged;
        address winner;
    }

    modifier validOption(uint _value) {
        require(uint(Option.Spock) >= _value);
        _;
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

    // @dev Game.deployed().then(function(instance){return instance.challenge('', 0)});
    function challenge(address _challenged, uint _option) public validOption(_option) returns(uint) {
        Match memory m;
        m.challenging = msg.sender;
        m.challenged = _challenged;
        m.challengingChoice = _option;
        uint id = matches.push(m); // solidity converts here the memory variable into storage, so we can access the mapping inside.
        return id;
    }

    function challengeAccepted(uint _matchId, uint _option) public validOption(_option) {
        Match storage m = matches[_matchId];
        uint challengingChoice = m.challengingChoice;
        if (challengingChoice == _option) {
            // play again. EVENT
        } else if ((challengingChoice - _option)%5 < 3) {
            m.winner = m.challenging;
        } else {
            m.winner = m.challenged;
        }
        delete matches[_matchId];
        // EVENT
    }

    // @dev Game.deployed().then(function(instance){return instance.getPointBankAddress()});
    function getPointBankAddress() public view returns(address) {
        return pointBankAddress;
    }

    function getAuctionAddress() public view returns(address) {
        return auctionAddress;
    }

}