pragma solidity ^0.4.22;

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

    uint count = 0;
    Match currentMatch;

    function chooseOption(Option option) public {
        currentMatch.options[msg.sender] = option;
        count++;
    }

    function startGame(address _challenged, uint _percentage) public {
        currentMatch.challenging = msg.sender;
        currentMatch.challenged = _challenged;
        currentMatch.percentage = _percentage;
    }

}