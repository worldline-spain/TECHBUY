pragma solidity ^0.4.22;

import "./PointBank.sol";
import "./Auction.sol";
import "./lib/Utils.sol";
import "./lib/Helper.sol";
import "./lib/Pausable.sol";
import "./lib/Random.sol";

contract Game is Pausable, Helper, NoETH, Random {

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
    uint initialized;
    mapping (string => bool) codesRedeemed;
  }

  modifier validOption(int _value) {
    require(int(Option.Scissors) >= _value, "game_validOption_option_notinrange");
    _;
  }

  modifier onlyPlayer() {
    require( players_[msg.sender].initialized > 0, "game_onlyPlayer_notaplayer");
    _;
  } 

  // @dev Game.deployed().then(function(instance){return instance.pointBank()})
  PointBank public pointBank;
  Auction public auction;
  
  mapping (address => Profile) private players_;
  mapping (string => Profile) private playersByName_;
  Profile[] playersArray_;
  mapping (string => uint) private codes_;
  string[] codesArray_;
  

  modifier notDuplicated(string _name){
    require(players_[msg.sender].initialized == 0, "game_notDuplicated_playersnotempty");
    require(playersByName_[_name].initialized == 0, "game_notDuplicated_playersByNamenotempty");
    _;
  }

  constructor() public {
    pointBank = new PointBank();
    auction = new Auction();
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
  function updateOption(int _option) public  whenNotPaused validOption(_option) onlyPlayer {
    players_[msg.sender].defaultOption = _option;
    playersByName_[players_[msg.sender].name].defaultOption = _option;
    emit ProfileUpdate(msg.sender, players_[msg.sender].name);
  }

  // @dev Game.deployed().then(function(instance){return instance.challengeRandom(2)})
  function challengeRandom(int _option) public whenNotPaused onlyPlayer validOption(_option)  {
    require(playersArray_.length>0, "game_challengeRandom_zeroplayers");
    uint idx = randrange(0, playersArray_.length);
    if (msg.sender == playersArray_[idx].addr) {
      idx = (idx + 1) % playersArray_.length;
    }

    Profile storage challenged = playersArray_[idx];
    require(challenged.initialized > 0, "game_challenge_isnotaplayer");
    require(challenged.addr!=msg.sender, "game_challenge_challengingyourself");

    emit Challenge(msg.sender,players_[msg.sender].name,challenged.addr, challenged.name);
    
    if ((_option == int(Option.Rock) ) && ((challenged.defaultOption == int(Option.Scissors))||( challenged.defaultOption == int(Option.Lizard)))) {
      // sender wins
      pointBank.transferFrom(challenged.addr, msg.sender, 100);
      emit ChallengeResult(msg.sender, players_[msg.sender].name, challenged.addr, challenged.name, players_[msg.sender].name); 
    } else if ((_option == int(Option.Spock)) && ((challenged.defaultOption == int(Option.Rock))||( challenged.defaultOption == int(Option.Scissors)))) {
      // sender wins
      pointBank.transferFrom(challenged.addr, msg.sender, 100);
      emit ChallengeResult(msg.sender, players_[msg.sender].name, challenged.addr, challenged.name, players_[msg.sender].name); 
    } else if ((_option == int(Option.Paper)) && ((challenged.defaultOption == int(Option.Rock) )||( challenged.defaultOption == int(Option.Spock) ))) {
      // sender wins
      pointBank.transferFrom(challenged.addr, msg.sender, 100);
      emit ChallengeResult(msg.sender, players_[msg.sender].name, challenged.addr, challenged.name, players_[msg.sender].name); 
    } else if ((_option == int(Option.Lizard) ) && ((challenged.defaultOption == int(Option.Paper))||( challenged.defaultOption == int(Option.Spock) ))) {
      // sender wins
      pointBank.transferFrom(challenged.addr, msg.sender, 100);
      emit ChallengeResult(msg.sender, players_[msg.sender].name, challenged.addr, challenged.name, players_[msg.sender].name); 
    } else if ((_option == int(Option.Scissors) ) && ((challenged.defaultOption == int(Option.Paper))||( challenged.defaultOption == int(Option.Lizard)))) {
      // sender wins
      pointBank.transferFrom(challenged.addr, msg.sender, 100);
      emit ChallengeResult(msg.sender, players_[msg.sender].name, challenged.addr, challenged.name, players_[msg.sender].name); 
    } else if (_option == challenged.defaultOption ) {
      //draw
      emit ChallengeResult(msg.sender, players_[msg.sender].name, challenged.addr, challenged.name , "draw");
    } else {
      // sender lost
      pointBank.transferFrom(msg.sender, challenged.addr, 100);
      emit ChallengeResult(msg.sender, players_[msg.sender].name, challenged.addr, challenged.name , challenged.name);
    }

  }

  // @dev Game.deployed().then(function(instance){return instance.getRandomPlayer()})-
  function getRandomPlayer() public view whenNotPaused returns(address, string) {
    require(playersArray_.length>0, "game_getRandomPlayer_zeroplayers");
    uint idx = randrange(0, playersArray_.length);
    return (playersArray_[idx].addr, playersArray_[idx].name);
  }

  // @dev Game.deployed().then(function(instance){return instance.getMyPlayer()})
  function getMyPlayer() public view  onlyPlayer whenNotPaused returns(string name, address add, int option) {
    Profile storage p = players_[msg.sender];
    name = p.name;
    add = p.addr;
    option = p.defaultOption;
  }

  function getPlayerByAlias(string alias) public view onlyPlayer whenNotPaused returns(address add) {
    Profile storage p = playersByName_[alias];
    return p.addr;
  }

  function addCode( string _code,uint value ) public onlyOwner {
    require(codes_[_code]==0, "game_addCode_codeNotEmpty");
    codes_[_code] = value;
    codesArray_.push(_code);
  }

  function pauseGame() public onlyOwner  {
    pause();
    pointBank.pause();
    auction.pause();
  }
  
  function resumeGame() public onlyOwner  {
    unpause();
    pointBank.unpause();
    auction.unpause();
  }

  function getPlayers() public view  returns (uint256) {
    return(playersArray_.length);
  }

  function getCodes() public view  returns (uint256) {
    return(codesArray_.length);
  }

  function clear() public onlyOwner {
    pointBank.resetInitialBalance();
    auction.clear();
    
    uint i;
    for (i=0; i< playersArray_.length; i++) {

      for (uint j=0; j< codesArray_.length; j++) {
        delete players_[playersArray_[i].addr].codesRedeemed[codesArray_[j]];
      }
      delete playersByName_[playersArray_[i].name];
      delete players_[playersArray_[i].addr];
      pointBank.clear(playersArray_[i].addr);
    }

    for (i=0; i< codesArray_.length; i++) {
      delete codes_[codesArray_[i]];
    }

    delete playersArray_;
    delete codesArray_;
  
  }
}