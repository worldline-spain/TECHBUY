pragma solidity ^0.4.22;

import "./Strings.sol";

contract Helper {

    //@dev https://github.com/Arachnid/solidity-stringutils
    using Strings for *;

    string constant separator = "-";

    modifier restrictedName(string _name) {
        require(_name.toSlice().find(separator.toSlice()).len() == 0);
        _;
    }

}