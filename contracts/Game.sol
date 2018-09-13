pragma solidity ^0.4.22;

import "./PointBank.sol";
import "./Auction.sol";

contract Game {
    
    enum Option {
        Rock,
        Paper,
        Scissors
    }

    struct Match {
        mapping (address => Option) options;
        address challenging;
        address challenged;
        address winner;
        uint percentage;
    }

    address pointBankAddress;
    address auctionAddress;
    uint percentage;

    function startGame(uint _percentage) public {
        pointBankAddress = address(new PointBank());
        auctionAddress = address(new Auction(pointBankAddress));
        percentage = _percentage;
    }

    function chooseOption(address _challenged, Option option) public {
        // currentMatch.options[msg.sender] = option;
        // count++;
        // currentMatch.challenging = msg.sender;
        // currentMatch.challenged = _challenged;
        // currentMatch.percentage = _percentage;
    }

}