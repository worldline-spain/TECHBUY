pragma solidity ^0.4.22;

contract Game {

    struct Match {
        address challenging;
        address challenged;
    }

    enum Option {
        Rock,
        Paper,
        Scissors
    }

    function chooseOption(Option option) public {

    }

}