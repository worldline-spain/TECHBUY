pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract TransferHistory {
    
    using SafeMath for uint256;

    struct Transfer {
        uint256 amount;
        string description;
        uint256 date;
        address from;
        address to;
    }

    mapping (address => Transfer[]) private transfersMap_;
    mapping (address => uint256) private currentIndexMap_;
    uint256 private max_ = 5;

    function addTransfer(uint256 _amount, string memory _description, uint256 _date, address _from, address _to) public {
        _addTransfer(_amount, _description, _date, _from, _to, _from);
        _addTransfer(_amount, _description, _date, _from, _to, _to);
    }
    
    function _addTransfer(uint256 _amount, string memory _description, uint256 _date, address _from, address _to, address _reference) private {
        if (transfersMap_[_reference].length < max_) {
            transfersMap_[_reference].push(Transfer(_amount, _description, _date, _from, _to));
            currentIndexMap_[_reference] = transfersMap_[_reference].length - 1;
        } else if (currentIndexMap_[_reference] == max_ - 1) {
            currentIndexMap_[_reference] = 0;
            transfersMap_[_reference][currentIndexMap_[_reference]] = Transfer(_amount, _description, _date, _from, _to);
        } else {
            currentIndexMap_[_reference] = currentIndexMap_[_reference].add(1);
            transfersMap_[_reference][currentIndexMap_[_reference]] = Transfer(_amount, _description, _date, _from, _to);
        }
    }

    function getPaginatedTransfers(address _add, uint256 _page, uint256 _resultsPerPage) public view returns (Transfer[] memory) {
        require(_page > 0 && _page <= max_, "Invalid page.");
        require(_resultsPerPage > 0 && _resultsPerPage <= max_, "Invalid results per page number.");
        uint256 _transferIndex = _resultsPerPage * _page - _resultsPerPage;
        Transfer[] memory transfers = transfersMap_[_add];
        if (transfers.length == 0 || _transferIndex > transfers.length - 1) {
            return;
        }
        Transfer[] memory _transfers = new Transfer[](_resultsPerPage);
        uint256 _returnCounter = 0;
        for (_transferIndex; _transferIndex < _resultsPerPage * _page; _transferIndex++) {
            if (_transferIndex < transfers.length) {
                _transfers[_returnCounter] = transfers[_transferIndex];
            }
            _returnCounter++;
        }
        return _transfers;
    }
}