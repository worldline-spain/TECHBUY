pragma solidity ^0.4.22;

import "./PointBank.sol";
import "./lib/Utils.sol";
import "./lib/Pausable.sol"; 


contract Auction is Pausable, NoETH, ApproveAndCallFallBack {

  event Bid(
    address  bidder,
    string  prize,
    uint bidAmount
  );

  struct Prize {
    string name;
    address bestBidder;
    address pointBankAddress;
    uint bestBid;
    uint initialized;
  }

  modifier validPrize(string _prize) {
    require( prizes_[_prize].initialized > 0, "auction_bidUp_notaprize" );
    _;
  }

  mapping (string => Prize) private prizes_;

  constructor() public {  
    _resetPrizes();
  }

  function receiveApproval(address fromAddress, address tokenAddress, uint256 tokens,  string _concept) public whenNotPaused {
    _bidUp(fromAddress, tokenAddress , tokens,  _concept);
  }

  function _bidUp(address _bidder, address _pointBankAddress, uint _amount, string _prize) private  validPrize(_prize) {
    
    Prize storage prize = prizes_[_prize];
    
    require( _amount > prize.bestBid, "auction_bidUp_notenoughbid");
      
    if (prize.bestBidder != address(0)) {
      _returnPoints(prize.bestBidder,prize.pointBankAddress, prize.bestBid);
    }

    _takePoints(_bidder, _pointBankAddress, _amount);
    prize.bestBidder = _bidder;
    prize.bestBid = _amount;
    prize.pointBankAddress = _pointBankAddress; 

    emit Bid(prize.bestBidder, _prize, _amount);   
  }

  function _returnPoints(address _to, address  pointBankAddress, uint _amount) internal {
    PointBank(pointBankAddress).transfer(_to, _amount);
  }

  function _takePoints(address _from, address  pointBankAddress, uint _amount) internal {
    PointBank(pointBankAddress).transferFrom(_from, this, _amount);
  }

  function getPrizeStatus(string _prize)  public view validPrize(_prize) whenNotPaused returns (string,address,uint)  {
    return(prizes_[_prize].name, prizes_[_prize].bestBidder, prizes_[_prize].bestBid);
  }
  
  function _resetPrizes() private {
    prizes_[ "prize1" ] =  Prize("prize1", address(0), address(0), 0, 1);
    prizes_[ "prize2" ] =  Prize("prize2", address(0), address(0), 0, 2);
    prizes_[ "prize3" ] =  Prize("prize3", address(0), address(0), 0, 3);
  }
  
  function clear() public onlyOwner {  
    _resetPrizes();
  }
}