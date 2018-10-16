pragma solidity ^0.4.22;

import "./PointBank.sol";
import "./Auction.sol";
import "./lib/Utils.sol";
import "./lib/Helper.sol";
import "./lib/Pausable.sol";

contract Game is Pausable, Helper, NoETH {

  event ProfileCreated(string name);
  event Challenge(string challenger, string challenged);
  event ChallengeResult(string winner);
  event CodeRedeemed(string playerName);

  enum Option {
    Rock,
    Spock,
    Paper,
    Lizard, 
    Scissors
  }

  struct Profile {
    string name;
    address addr;
    int defaultOption;
    uint id;
  }

  modifier validOption(int _value) {
    require(int(Option.Scissors) >= _value, "Invalid option");
    _;
  }

  modifier onlyPlayer() {
    require( players_[msg.sender].id > 0 );
    _;
  } 

  

  PointBank public pointBank;
  Auction public auction;
  
  mapping (address => Profile) private players_;
  mapping (string => Profile) private playersByName_;
  Profile[] playersArray_;
  mapping (string => uint) private codes_;

  modifier notDuplicated(string _name){
    require(players_[msg.sender].id == 0);
    require(playersByName_[_name].id == 0);
    _;
  }

  constructor() public {
    pointBank = new PointBank();
    auction = new Auction();
    codes_['00000']=100;
    codes_['00001']=110;
    codes_['00002']=120;
    codes_['00003']=130;
  }

  function codeRedemption(string _code) public  whenNotPaused onlyPlayer {
    require(codes_[_code]>0);
    pointBank.transfer(msg.sender, 100);
    emit CodeRedeemed(players_[msg.sender].name);
  }

  function userEnrollment(string _name, int _option) public whenNotPaused validOption(_option) notDuplicated(_name) {
    Profile memory newPlayer = Profile(_name, msg.sender, _option, 1);
    players_[newPlayer.addr]= newPlayer;
    playersByName_[newPlayer.name] = newPlayer;
    playersArray_.push(newPlayer);
    emit ProfileCreated(_name);
  }

  function challenge(string _challengedName, int _option) public onlyPlayer validOption(_option) whenNotPaused  {
    require(playersByName_[_challengedName].id > 0);
    require(playersByName_[_challengedName].addr!=msg.sender);

    emit Challenge(players_[msg.sender].name, _challengedName);

    if ((_option - playersByName_[_challengedName].defaultOption) % 5 < 3) {
      pointBank.transferFrom(msg.sender, playersByName_[_challengedName].addr, 100);
      emit ChallengeResult( _challengedName); 
    } else {
      pointBank.transferFrom(playersByName_[_challengedName].addr, msg.sender, 100);
      emit ChallengeResult( players_[msg.sender].name); 
    }

  }

  function getRandomPlayer() public view returns(address, string) {
    require(playersArray_.length>0);
    return (playersArray_[0].addr, playersArray_[0].name);
  }

  function pauseGame() public whenNotPaused onlyOwner {
    pause();
    pointBank.pause();
    auction.pause();
  }
  
  function resumeGame() public whenPaused onlyOwner {
    unpause();
    pointBank.unpause();
    auction.unpause();
  }
}