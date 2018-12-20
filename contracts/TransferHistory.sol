pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";


    
    using SafeMath for uint256;

    struct Transfer {
        uint256 amount;
        string description;
        uint256 date;
        address from;
        address to;
    }

    mapping (address => Transfer[]) private transfersMap_;
    mapping (address => int256) private currentIndexMap_;
    int256 private max_ = 6;

    function addTransfer(uint256 _amount, string memory _description, uint256 _date, address _from, address _to) public {
        _addTransfer(_amount, _description, _date, _from, _to, _from);
        _addTransfer(_amount, _description, _date, _from, _to, _to);
    }
    
    function _addTransfer(uint256 _amount, string memory _description, uint256 _date, address _from, address _to, address _reference) private {
        if (transfersMap_[_reference].length < uint256(max_)) {
            transfersMap_[_reference].push(Transfer(_amount, _description, _date, _from, _to));
            currentIndexMap_[_reference] = int256(transfersMap_[_reference].length - 1);
        } else if (currentIndexMap_[_reference] == max_ - 1) {
            currentIndexMap_[_reference] = 0;
            transfersMap_[_reference][uint256(currentIndexMap_[_reference])] = Transfer(_amount, _description, _date, _from, _to);
        } else {
            currentIndexMap_[_reference]++;
            transfersMap_[_reference][uint256(currentIndexMap_[_reference])] = Transfer(_amount, _description, _date, _from, _to);
        }
    }

    function getPaginatedTransfers(address _add, int256 _page, int256 _resultsPerPage) public view returns (Transfer[] memory) {
        require(_page > 0 && _page <= max_, "Invalid page.");
        require(_resultsPerPage > 0 && _resultsPerPage <= max_, "Invalid results per page number.");
        int256 _transferIndex = currentIndexMap_[_add] - (_resultsPerPage * (_page - 1));
        
        Transfer[] memory transfers = transfersMap_[_add];
        if (transfers.length == 0) {
            return;
        }
        Transfer[] memory _transfers = new Transfer[](uint256(_resultsPerPage));
        for (int256 i = 0; i < int(_resultsPerPage); i++) {
            if (i == _transferIndex) {
                _transfers[uint256(i)] = transfers[0];
            } else {
                _transfers[uint256(i)] = transfers[uint256((_transferIndex - i) % max_)];
            }
        }
        return _transfers;
    }
}