pragma solidity ^0.4.22;


contract Random {

  function rand(uint seed) internal pure returns (uint) {
    bytes32 data;
    if (seed % 2 == 0){
      data = keccak256(abi.encodePacked(seed)); 
    }else{
      data = keccak256(abi.encodePacked(keccak256(abi.encodePacked(seed))));
    }
    uint sum;
    for(uint i;i < 32;i++){
      sum += uint(data[i]);
    }
    return uint(data[sum % data.length])*uint(data[(sum + 2) % data.length]);
  }
    
  function randint() internal view returns(uint) {
    return rand(now);
  }
    
  function randrange(uint a, uint b) internal view returns(uint) {
    return a + (randint() % b);
  }
    
  function randbytes(uint size, uint seed) internal pure returns (byte[]) {
    
    byte[] memory data = new byte[](size);

    uint x = seed;
    for(uint i;i < size;i++){
      x = rand(x);
      data[i] = byte(x % 256);
    }
    return data;
  }
}