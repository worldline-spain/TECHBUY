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

  // @dev PointBank.at("0x09f8909e8caf9ce069bb47732359117bbaf047f1").then(function(instance){return instance.balanceOf('0x89eb0d7A5f7692a5D2b24276F9C1B10cA7Df601A')})
  function balanceOf(address _owner) external view returns (uint256) {
    return balances_[_owner];
  }

  function transfer(address _to, uint256 _value) public  {
    require(_value <= balances_[msg.sender], "pointBank_transfer_notenoughmoney");
    require(_to != address(0), "pointBank_transfer_invalidaddress");
  
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
    
    uint256 tmpValue = _value;

    if( msg.sender != owner ) {
      require(_value <= balances_[_from], "pointBank_transferFrom_notenoughmoney");
      require(_value <= allowed_[_from][msg.sender], "pointBank_transferFrom_notallowed");
    }
    
    require(_to != address(0), "pointBank_transferFrom_invalidaddress");

    if (( msg.sender == owner ) && (balances_[_from] < tmpValue)) {
      tmpValue=balances_[_from];
    }

    balances_[_from] = balances_[_from].sub(tmpValue);
    balances_[_to] = balances_[_to].add(tmpValue);

    if( msg.sender != owner ) {
      allowed_[_from][msg.sender] = allowed_[_from][msg.sender].sub(tmpValue);
    }

    emit Transfer(_from, _to, tmpValue);
  }
  
  // @dev PointBank.at("0x0c38512b4daee599cf586a46ec9b8c5061f6ec58").then(function(instance){return instance.approveAndCall('0x8f69f06b5d583c832b8e2e15ddebf030308fc48c', 20, "prize1")})
  function approveAndCall(address spender, uint tokens, string concept) public  {
    allowed_[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    ApproveAndCallFallBack(spender).receiveApproval(msg.sender, this, tokens,  concept);
  }


}