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

    // function addTransfer() public {

    // }

    function getPaginatedTransfers(address _add, uint256 _page, uint256 _resultsPerPage) public view returns (Transfer[]) {
        uint256 _transferIndex = _resultsPerPage * _page - _resultsPerPage;
        Transfer[] memory transfers = transfersMap_[_add];
        if (transfers.length == 0 || _transferIndex > transfers.length - 1) {
            return transfers;
        }
        Transfer[] memory _transfers = new Transfer[](_resultsPerPage);
        uint256 _returnCounter = 0;
        for (_transferIndex; _transferIndex < _resultsPerPage * _page; _transferIndex++) {
            if (_transferIndex < transfers.length - 1) {
                _transfers[_returnCounter] = transfers[_transferIndex];
            } else {
                _transfers[_returnCounter].amount = 0;
            }
        }
    }
}