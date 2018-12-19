pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

contract TransferHistory {

    struct Transfer {
        uint256 amount;
        string description;
        uint256 date;
        address from;
        address to;
    }

    mapping (address => Transfer[]) private transfersMap_;
    // mapping (address => uint256) private transfersPerAddress_;
    uint256 private max_ = 100;

    function addTransfer(uint256 _amount, string memory _description, uint256 _date, address _from, address _to) public {
        transfersMap_[_from].push(Transfer(_amount, _description, _date, _from, _to));
        transfersMap_[_to].push(Transfer(_amount, _description, _date, _from, _to));
    }

    function getPaginatedTransfers(address _add, uint256 _page, uint256 _resultsPerPage) public view returns (Transfer[] memory) {
        require(_page > 0 && _page <= max_, 'Invalid page.');
        require(_resultsPerPage > 0 && _resultsPerPage <= max_, 'Invalid results per page number.');
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