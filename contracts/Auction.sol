pragma solidity ^0.4.22;

import "./PointBank.sol";

contract Auction {

    address private pointBankAddress;

    struct Prize {
        string name;
        address bestBidder;
        uint bestBid;
    }

    Prize[] prizes;

    constructor(address _pointBankAddress) public {
        pointBankAddress = _pointBankAddress;
        PointBank(pointBankAddress).setAuction(this);
        prizes.push(Prize({name:"Headphones", bestBidder: 0, bestBid: 0}));
        prizes.push(Prize({name:"Pen", bestBidder: 0, bestBid: 0}));
        prizes.push(Prize({name:"Notebook", bestBidder: 0, bestBid: 0}));
    }

    function bidUp(uint _amount, uint8 _prizeId) public {
        Prize storage prize = prizes[_prizeId];
        uint currentAmount = prize.bestBid;
        if (_amount > currentAmount) {
            address currentBidder = prize.bestBidder;
            prize.bestBidder = msg.sender;
            prize.bestBid = _amount;
            if (currentBidder != 0) {
                _returnPoints(currentBidder, currentAmount);
            }
            _takePoints(msg.sender, _amount);
        }
    }

    function _returnPoints(address _to, uint _amount) internal {
        PointBank(pointBankAddress).transfer(_to, _amount);
    }

    function _takePoints(address _from, uint _amount) internal {
        PointBank(pointBankAddress).takePoints(_from, _amount);
    }
    
}