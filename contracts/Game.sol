pragma solidity ^0.4.22;

import "./PointBank.sol";
import "./Auction.sol";
import "./lib/Utils.sol";
import "./lib/Helper.sol";
import "./lib/Pausable.sol";

contract Game is Pausable, Helper, NoETH {

  event ProfileCreated(
    address indexed owner,
    string name
  );
  
  event ProfileUpdate(
    address indexed owner,
    string name
  );

  event Challenge(
    address indexed challenger,
    string challengerName,
    address indexed challenged, 
    string challengedName
  );

  event ChallengeResult(
    address indexed challenger,
    string challengerName,
    address indexed challenged, 
    string challengedName,
    string winner
  );

  event CodeRedeemed(
    address indexed owner,
    string playerName
  );

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
    mapping (string => bool) codesRedeemed;
  }

  modifier validOption(int _value) {
    require(int(Option.Scissors) >= _value, "game_validOption_option_notinrange");
    _;
  }

  modifier onlyPlayer() {
    require( players_[msg.sender].id > 0, "game_onlyPlayer_notaplayer");
    _;
  } 

  // @dev Game.deployed().then(function(instance){return instance.pointBank()})
  PointBank public pointBank;
  Auction public auction;
  
  mapping (address => Profile) private players_;
  mapping (string => Profile) private playersByName_;
  Profile[] playersArray_;
  mapping (string => uint) private codes_;
  uint private randomUserDelta_;

  modifier notDuplicated(string _name){
    require(players_[msg.sender].id == 0, "game_notDuplicated_playersnotempty");
    require(playersByName_[_name].id == 0, "game_notDuplicated_playersByNamenotempty");
    _;
  }

  constructor() public {
    pointBank = new PointBank();
    auction = new Auction();
    codes_['00000']=100;
    codes_['00001']=110;
    codes_['00002']=120;
    codes_['00003']=130;
    codes_['00004']=100;
    codes_['00005']=110;
    codes_['00006']=120;
    randomUserDelta_=0;
  }

  // @dev Game.deployed().then(function(instance){return instance.codeRedemption("00000")})
  function codeRedemption(string _code) public  whenNotPaused onlyPlayer {
    require(codes_[_code]>0, "game_codeRedemption_invalidcode");
    require(players_[msg.sender].codesRedeemed[_code] != true, "game_codeRedemption_codeused");
    pointBank.transfer(msg.sender, codes_[_code]);
    players_[msg.sender].codesRedeemed[_code] = true;
    emit CodeRedeemed(msg.sender, players_[msg.sender].name);
  }

  // @dev Game.deployed().then(function(instance){return instance.userEnrollment("Raul", 0)})
  function userEnrollment(string _name, int _option) public whenNotPaused validOption(_option) notDuplicated(_name) {
    Profile memory newPlayer = Profile(_name, msg.sender, _option, 1);
    players_[newPlayer.addr]= newPlayer;
    playersByName_[newPlayer.name] = newPlayer;
    playersArray_.push(newPlayer);
    emit ProfileCreated(msg.sender, _name);
  }

  // @dev Game.deployed().then(function(instance){return instance.updateOption(1)})
  function updateOption(int _option) public validOption(_option) onlyPlayer {
    players_[msg.sender].defaultOption = _option;
    playersByName_[players_[msg.sender].name].defaultOption = _option;
    emit ProfileUpdate(msg.sender, players_[msg.sender].name);
  }

  // @dev Game.deployed().then(function(instance){return instance.challenge("Raul", 2)})
  function challenge(string _challengedName, int _option) public onlyPlayer validOption(_option) whenNotPaused  {
    require(playersByName_[_challengedName].id > 0, "game_challenge_isnotaplayer");
    require(playersByName_[_challengedName].addr!=msg.sender, "game_challenge_challengingyourself");

    emit Challenge(msg.sender,players_[msg.sender].name,playersByName_[_challengedName].addr, _challengedName);

    if ((_option - playersByName_[_challengedName].defaultOption) % 5 < 3) {
      pointBank.transferFrom(playersByName_[_challengedName].addr, msg.sender, 100);
      emit ChallengeResult(msg.sender, players_[msg.sender].name,playersByName_[_challengedName].addr,_challengedName, players_[msg.sender].name); 
    } else {
      pointBank.transferFrom(msg.sender, playersByName_[_challengedName].addr, 100);
      emit ChallengeResult(msg.sender, players_[msg.sender].name,playersByName_[_challengedName].addr,_challengedName,_challengedName); 
    }

  }

  function getRandomPlayer(uint _random) public view returns(address, string) {
    require(playersArray_.length>0, "game_getRandomPlayer_zeroplayers");
    require(_random >0, "game_getRandomPlayer_zerorandom");
    uint idx = _random % playersArray_.length;
    return (playersArray_[idx].addr, playersArray_[idx].name);
  }

  // @dev Game.deployed().then(function(instance){return instance.getMyPlayer()})
  function getMyPlayer() public view onlyPlayer returns(string name, address add, int option) {
    //require(players_[msg.sender] != null);
    Profile storage p = players_[msg.sender];
    name = p.name;
    add = p.addr;
    option = p.defaultOption;
  }

  function getPlayerByAlias(string alias) public view onlyPlayer returns(address add) {
    Profile storage p = playersByName_[alias];
    return p.addr;
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