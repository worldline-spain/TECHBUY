pragma solidity ^0.4.22;

contract NoETH {
  function () public payable {
    revert();
  }
}

contract ApproveAndCallFallBack {
  function receiveApproval(address fromAddress, address tokenAddress, uint256 tokens,  string _concept) public;
}