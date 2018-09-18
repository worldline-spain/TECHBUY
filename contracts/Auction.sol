pragma solidity ^0.4.22;

import "./PointBank.sol";
import "./Pausable.sol"; //Source from github

contract Auction is Pausable {

    // @dev var et; Auction.at("0xb6d45dc615c30e9c1da6210e631f5d74975ce7c4").then(function(instance){et = instance;});
    // @dev et.bidUp(12,1).then(function(ret){console.log(ret.logs[1].args.bidAmount)});
    event Bid(address bidder, string prize, uint bidAmount);
    event NewBestBid(address bidder, string prize, uint bidAmount);
    event IgnoredBid(address bidder, string prize, uint bidAmount);

    address private pointBankAddress;

    struct Prize {
        string name;
        address bestBidder;
        uint bestBid;
    }

    // @dev Auction.at('').then(function(instance){return instance.prizes(0)});
    Prize[] public prizes;

    constructor(address _pointBankAddress) public {
        pointBankAddress = _pointBankAddress;
        PointBank(pointBankAddress).setAuction(this);
        prizes.push(Prize({name:"Headphones", bestBidder: 0, bestBid: 0}));
        prizes.push(Prize({name:"Pen", bestBidder: 0, bestBid: 0}));
        prizes.push(Prize({name:"Notebook", bestBidder: 0, bestBid: 0}));
    }

    // @dev Auction.at('').then(function(instance){return instance.bidUp(10, 1)});
    function bidUp(uint _amount, uint8 _prizeId) public whenNotPaused {
        Prize storage prize = prizes[_prizeId];
        emit Bid(msg.sender, prize.name, _amount);
        uint currentAmount = prize.bestBid;
        if (_amount > currentAmount) {
            emit NewBestBid(msg.sender, prize.name, _amount);
            address currentBidder = prize.bestBidder;
            prize.bestBidder = msg.sender;
            prize.bestBid = _amount;
            if (currentBidder != 0) {
                _returnPoints(currentBidder, currentAmount);
            }
            _takePoints(msg.sender, _amount);
        } else {
            emit IgnoredBid(msg.sender, prize.name, _amount);
        }
    }

    function _returnPoints(address _to, uint _amount) internal {
        PointBank(pointBankAddress).transfer(_to, _amount);
    }

    function _takePoints(address _from, uint _amount) internal {
        PointBank(pointBankAddress).takePoints(_from, _amount);
    }
    
}