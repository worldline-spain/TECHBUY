pragma solidity ^0.4.22;

import "./PointBank.sol";
import "./lib/Utils.sol";
import "./lib/Pausable.sol"; 


contract Auction is Pausable, NoETH, ApproveAndCallFallBack {

  event Bid(
    address indexed bidder,
    string indexed prize,
    uint bidAmount
  );

  struct Prize {
    string name;
    address bestBidder;
    address pointBankAddress;
    uint bestBid;
    uint id;
  }

  mapping (string => Prize) private prizes_;

  constructor() public {
    Prize memory tmPrize1 = Prize("prize1", address(0), address(0), 0, 1);
    prizes_[tmPrize1.name] =  tmPrize1;
    
    Prize memory tmPrize2 = Prize("prize2", address(0), address(0), 0, 2);
    prizes_[tmPrize2.name] =  tmPrize2;

    Prize memory tmPrize3 = Prize("prize3", address(0), address(0), 0, 3);
    prizes_[tmPrize3.name] =  tmPrize3;    
  }

  function receiveApproval(address fromAddress, address tokenAddress, uint256 tokens,  string _concept) public whenNotPaused {
    _bidUp(fromAddress, tokenAddress , tokens,  _concept);
  }

  function _bidUp(address _bidder, address _pointBankAddress, uint _amount, string _prize) private  {
    require( prizes_[_prize].id > 0, "auction_bidUp_notaprize" );
    
    Prize storage prize = prizes_[_prize];
    
    require( _amount > prize.bestBid, "auction_bidUp_notenoughbid");
      
    if (prize.bestBidder != address(0)) {
      _returnPoints(prize.bestBidder,prize.pointBankAddress, prize.bestBid);
    }

    _takePoints(_bidder, _pointBankAddress, _amount);

    prize.bestBidder = _bidder;
    prize.bestBid = _amount;
    prize.pointBankAddress = _pointBankAddress; 

    emit Bid(prize.bestBidder, prize.name, _amount);   
  }

  function _returnPoints(address _to, address  pointBankAddress, uint _amount) internal {
    PointBank(pointBankAddress).transfer(_to, _amount);
  }

  function _takePoints(address _from, address  pointBankAddress, uint _amount) internal {
    PointBank(pointBankAddress).transferFrom(_from, this, _amount);
  }
   
}