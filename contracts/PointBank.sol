pragma solidity ^0.4.22;

import "./lib/SafeMath.sol";
import "./lib/Utils.sol";
import "./lib/Pausable.sol"; 

contract PointBank is  Pausable, NoETH {
  using SafeMath for uint256;

  struct Movements {
    int move0;
    int move1;
    int move2;    
  }

  mapping (address => uint256) private balances_;

  mapping (address => Movements) private balanceMovement_;

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

  function totalSupply() external view whenNotPaused returns (uint256) {
    return totalSupply_;
  }

  function balanceOf(address _owner) external view whenNotPaused returns (uint256) {
    return balances_[_owner];
  }

  function balanceMovements(address _owner) external view whenNotPaused returns (int, int, int) {
    return (balanceMovement_[_owner].move0, balanceMovement_[_owner].move1, balanceMovement_[_owner].move2);
  }

  function transfer(address _to, uint256 _value) public  whenNotPaused {
    require(_value <= balances_[msg.sender], "pointBank_transfer_notenoughmoney");
    require(_to != address(0), "pointBank_transfer_invalidaddress");
  
    balances_[msg.sender] = balances_[msg.sender].sub(_value);
    balances_[_to] = balances_[_to].add(_value);

    balances_[msg.sender] = balances_[msg.sender].sub(_value);
    balanceMovement_[msg.sender].move2=balanceMovement_[msg.sender].move1;
    balanceMovement_[msg.sender].move1=balanceMovement_[msg.sender].move0;
    balanceMovement_[msg.sender].move0 = int(_value) * -1;
    balances_[_to] = balances_[_to].add(_value);
    balanceMovement_[_to].move2=balanceMovement_[_to].move1;
    balanceMovement_[_to].move1=balanceMovement_[_to].move0;
    balanceMovement_[_to].move0= int(_value);

    emit Transfer(msg.sender, _to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public whenNotPaused
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
    balanceMovement_[_from].move2=balanceMovement_[_from].move1;
    balanceMovement_[_from].move1=balanceMovement_[_from].move0;
    balanceMovement_[_from].move0 = int(tmpValue) * -1;
    balances_[_to] = balances_[_to].add(tmpValue);
    balanceMovement_[_to].move2=balanceMovement_[_to].move1;
    balanceMovement_[_to].move1=balanceMovement_[_to].move0;
    balanceMovement_[_to].move0 = int(tmpValue);

    if( msg.sender != owner ) {
      allowed_[_from][msg.sender] = allowed_[_from][msg.sender].sub(tmpValue);
    }

    emit Transfer(_from, _to, tmpValue);
  }
  
  // @dev PointBank.at("0x0c38512b4daee599cf586a46ec9b8c5061f6ec58").then(function(instance){return instance.approveAndCall('0x8f69f06b5d583c832b8e2e15ddebf030308fc48c', 20, "prize1")})
  function approveAndCall(address spender, uint tokens, string concept) public whenNotPaused {
    allowed_[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    ApproveAndCallFallBack(spender).receiveApproval(msg.sender, this, tokens,  concept);
  }
  
  function clear(address user) public onlyOwner {
    delete balances_[user];
    delete balanceMovement_[user];
    delete allowed_[user][msg.sender];
  }

  function resetInitialBalance() public onlyOwner {
    balances_[owner] = totalSupply_; 
  }
  

}