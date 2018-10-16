pragma solidity ^0.4.22;

contract NoETH {
  function () public payable {
      revert();
  }
}