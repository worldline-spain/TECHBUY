pragma solidity ^0.4.22;

import "./PointBank.sol";

contract Auction {

    Bid bestBid;
    address private pointBankAddress;

    struct Bid {
        address bidder;
        uint amount;
    }

    constructor(address _pointBankAddress) public {
        pointBankAddress = _pointBankAddress;
    }

    function bidUp(uint _amount) public {
        uint currentAmount = bestBid.amount;
        if (_amount > currentAmount) {
            address currentBidder = bestBid.bidder;
            bestBid = Bid(msg.sender, _amount); 
            _transferPoints(currentBidder, currentAmount);
        }
    }

    function _transferPoints(address _to, uint _amount) internal {
        PointBank(pointBankAddress).transfer(_to, _amount);
    }
    
}