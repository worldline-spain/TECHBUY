pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

import "./Schemas.sol";

contract  Assets is Schemas {
    
  struct UserAssets {   
    Asset[] assets;
  } 

  struct Asset {   
    uint expirationDate;
    uint256 assetId;
    uint256 schemaId;
    string dappId;
  }

  uint256 constant private PAGE_SIZE = 10;

  // buy://<assetId>#<schemaId>#<amount>#<dappId>#amount

  mapping (address => UserAssets) private userAssets_;

  function checkOwnership(uint256 _assetId, uint256 _schemaId) public view returns (bool) {
    return _checkOwnership(msg.sender, _assetId, _schemaId);  
  }

  function buy(uint256 _assetId, uint256 _schemaId, uint256 _amount, string _dappId) public  {
    _buy(msg.sender, _assetId, _schemaId, _amount, _dappId);  
  }

  function getAssets(uint256 _page) public view returns (Asset[] memory) {
    
    uint256 transferIndex = PAGE_SIZE * _page - PAGE_SIZE;
    Asset[] memory assets = userAssets_[msg.sender].assets;

    if (assets.length == 0 || transferIndex > assets.length - 1) {
      return;
    }

    Asset[] memory assetsPage = new Asset[](PAGE_SIZE);  
    uint256 returnCounter = 0;

    for (transferIndex; transferIndex < PAGE_SIZE * _page; transferIndex++) {
      if (transferIndex < assets.length) {
        assetsPage[returnCounter] = assets[transferIndex];
      }
      returnCounter++;
    }

    return (assetsPage);
  }

  function _buy(address _user, uint256 _assetId, uint256 _schemaId, uint256 _amount, string _dappId) internal  {
    Schema memory schema = Schemas.getSchema(_schemaId);
    require(schema.amount == _amount, "incorrect amount");    
    require(!_checkOwnership(_user, _assetId, _schemaId), "duplicated");
    // hacer transferencias directamente dado que con el genesis actual Alastria no permite llamadas entre contratos
    // tenemos que usar el erc223 para evitar que en los movimientos del usuario final se vean las transferencias definidas por el schema.



    // registrar la compra
    userAssets_[_user].assets.push(Asset(now + schema.assetLifeTime , _assetId, _schemaId, _dappId));
  }

  function _checkOwnership(address _owner, uint256 _assetId, uint256 _schemaId) internal view returns (bool) {
    
    for (uint i = 0; i < userAssets_[_owner].assets.length; i++) {
      Asset memory asset = userAssets_[_owner].assets[i];

      if ( (asset.assetId == _assetId) && (asset.schemaId == _schemaId) && (asset.expirationDate > now)){
        return true;
      }
    }
    
    return false;
  }

    
}