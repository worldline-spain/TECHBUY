pragma solidity ^0.4.22;

import "./lib/SafeMath.sol";
import "./lib/Utils.sol";
import "./lib/Pausable.sol"; 

contract PointBank is  Pausable, NoETH {
  using SafeMath for uint256;

  mapping (address => uint256) private balances_;

  mapping (address => mapping (address => uint256)) private allowed_;

  uint256 private totalSupply_ = 9000000;

  constructor() public {
    balances_[owner] = balances_[owner].add(totalSupply_);
  }

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );

  function totalSupply() external view returns (uint256) {
    return totalSupply_;
  }

  // @dev PointBank.at("0x7f93432af72e22ec0582a3cdf01ae21b2922e7e4").then(function(instance){return instance.balanceOf('0x34f5c9DE986bc6c26d704b8510330dfFfF9cDAc8')})
  function balanceOf(address _owner) external view returns (uint256) {
    return balances_[_owner];
  }

  function transfer(address _to, uint256 _value) public  {
    require(_value <= balances_[msg.sender]);
    require(_to != address(0));
  
    balances_[msg.sender] = balances_[msg.sender].sub(_value);
    balances_[_to] = balances_[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
  {
    require(_value <= balances_[_from]);

    if( msg.sender!= owner ) {
      require(_value <= allowed_[_from][msg.sender]);
    }
    
    require(_to != address(0));

    balances_[_from] = balances_[_from].sub(_value);
    balances_[_to] = balances_[_to].add(_value);

    if( msg.sender!= owner ) {
      allowed_[_from][msg.sender] = allowed_[_from][msg.sender].sub(_value);
    }

    emit Transfer(_from, _to, _value);
  }
  
  function approveAndCall(address spender, uint tokens, string concept) public  {
    allowed_[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    ApproveAndCallFallBack(spender).receiveApproval(msg.sender, this, tokens,  concept);
  }


}