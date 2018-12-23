pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

contract TransferHistory {

    struct Transfer {
        uint256 amount;
        string description;
        uint256 date;
        address from;
    }

    mapping (address => Transfer[]) private transfersMap_;
    mapping (address => int256) private currentIndexMap_;
    int256 constant private MAX = 6;
    int256 constant private PAGE_SIZE = 2;
    int256 constant private MAX_PAGE_NUMBER = MAX/PAGE_SIZE;

    function addTransfer(uint256 _amount, string memory _description, uint256 _date, address _from) public {
        _addTransfer(_amount, _description, _date, _from);
    }
    
    function _addTransfer(uint256 _amount, string memory _description, uint256 _date, address _from) private {
        if (transfersMap_[_from].length < uint256(MAX)) {
            transfersMap_[_from].push(Transfer(_amount, _description, _date, _from));
            currentIndexMap_[_from] = int256(transfersMap_[_from].length - 1);
        } else if (currentIndexMap_[_from] == MAX - 1) {
            currentIndexMap_[_from] = 0;
            transfersMap_[_from][0] = Transfer(_amount, _description, _date, _from);
        } else {
            currentIndexMap_[_from]++;
            transfersMap_[_from][uint256(currentIndexMap_[_from])] = Transfer(_amount, _description, _date, _from);
        }
    }


    function getPaginatedTransfers(address _addr, int256 _page) public view returns (Transfer[] memory) {
        require(_page > 0 && _page <= MAX_PAGE_NUMBER, "Invalid page.");

        uint256 _reqIndexOffset = uint256(PAGE_SIZE * (_page - 1));
        Transfer[] memory transfers = transfersMap_[_addr];
        if (transfers.length <= _reqIndexOffset) {
            return;
        }

        Transfer[] memory _transfersPage = new Transfer[](uint256(PAGE_SIZE));

        for (int256 i = 0; i < int(PAGE_SIZE); i++) {
            int256 _transferIndex = currentIndexMap_[_addr] - int256(_reqIndexOffset) - i;
            if (_transferIndex < 0) {
                if (transfers.length < uint256(MAX) ) {
                    return _transfersPage;
                } else {
                    _transferIndex += MAX;
                }
            }
            _transfersPage[uint256(i)] = transfers[uint256(_transferIndex)];
        }
        
       
        return _transfersPage;
    }

/*
    function getPaginatedTransfers(address _addr, int256 _page) public view returns (Transfer[] memory) {
        require(_page > 0 && _page <= MAX_PAGE_NUMBER, "Invalid page.");

        uint256 _reqIndex = uint256(PAGE_SIZE * (_page - 1));
        if (transfers.length <= _reqIndex) {
            return;
        }

        int256 _transferIndex = currentIndexMap_[_addr] - int256(_reqIndex);
        Transfer[] memory transfers = transfersMap_[_addr];
        
        Transfer[] memory _transfers = new Transfer[](uint256(PAGE_SIZE));
        for (int256 i = 0; i < int(PAGE_SIZE); i++) {
            uint256 idx;
            if (i == _transferIndex) {
                _transfers[uint256(i)] = transfers[0];
            } else if (i > _transferIndex) {
                idx = uint256(MAX + _transferIndex - i);
                _transfers[uint256(i)] = transfers[idx];
            } else {
                idx = uint256(_transferIndex - i);
                _transfers[uint256(i)] = transfers[idx];
            }
        }
        return _transfers;
    }
    */
}