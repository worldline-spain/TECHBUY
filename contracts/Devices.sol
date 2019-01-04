pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

import "./Assets.sol";

contract Devices  is Assets {

  struct UserDevices {   
    mapping (bytes32 => Device) devices;
  } 

  struct Device {   
    uint256 expirationDate;
    uint256 assetId;
    uint256 schemaId;
    string dappId;
  }

  mapping (address => UserDevices) private userDevices_;

  mapping (bytes32 => address) private deviceHashes_;
    
  function isAllowed(bytes32 _deviceHash) public view returns (bool) {
    bool allowed = userDevices_[deviceHashes_[_deviceHash]].devices[_deviceHash].expirationDate > now ;
    return allowed;
  }

  function handshake(bytes32 _deviceHash, uint256 _assetId, uint256 _schemaId, uint256 _lifeTime, string _dappId) public {
    
    _handshake(msg.sender, _deviceHash, _assetId, _schemaId, _lifeTime, _dappId);
  }

  function removeDevice(bytes32 _deviceHash) public {
    _removeDevice(msg.sender, _deviceHash);
  }
    
  function _handshake(address _owner, bytes32 _deviceHash, uint256 _assetId, uint256 _schemaId, uint256 _lifeTime, string _dappId) internal {

    require(Assets._checkOwnership(_owner, _assetId, _schemaId),"not allowed");

    if ((deviceHashes_[_deviceHash] == address(0)) && (!isAllowed(_deviceHash))) {
      _removeDevice(deviceHashes_[_deviceHash], _deviceHash);
    }

    require(deviceHashes_[_deviceHash] == address(0), "duplicated hash");
    deviceHashes_[_deviceHash] = _owner; 
    userDevices_[_owner].devices[_deviceHash] =  Device(_lifeTime, _assetId, _schemaId, _dappId);
  }

  function _removeDevice(address _owner, bytes32 _deviceHash) internal {
    // recorremos el vector para ver si existe un device con el hash y lo borramos...
    require(deviceHashes_[_deviceHash] == _owner, "same owner");
    delete deviceHashes_[_deviceHash];
    delete userDevices_[_owner].devices[_deviceHash];
  }

}