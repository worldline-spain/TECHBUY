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

    // buy://<assetId>#<schemaId>#<amount>#<dappId>#amount

    mapping (address => UserAssets) private userAssets_;

    function buy(uint256 _assetId, uint256 _schemaId, uint256 _amount, string _dappId) public  {
        _buy(msg.sender, _assetId, _schemaId, _amount, _dappId);  
    }

    function getAssets() public view returns (uint256) {
        return (userAssets_[msg.sender].assets.length);
    }

    function _buy(address _user, uint256 _assetId, uint256 _schemaId, uint256 _amount, string _dappId) internal  {
        Schema memory schema = Schemas.getSchema(_schemaId);
        require(schema.amount == _amount, "incorrect amount");
        // mirar que no sea una compra duplicada

        // hacer transferencias

        // registrar la compra
        userAssets_[_user].assets.push(Asset(now + schema.assetLifeTime , _assetId, _schemaId, _dappId));
    }

    
}