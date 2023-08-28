// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;


contract e {

   function test() external pure returns(bytes32)  {
        uint amt = 800 ether;
        address adr = 0x4D11dF920E0E48c7E132e5a9754C7e754Cd6EBFB;
        uint tme = 1692953302;
        assembly {
            mstore(0x00, add(amt, add(adr, tme)))
            mstore(0x00, keccak256(0x00, 0x20))
            //mstore(0x00, keccak256(0x00, 0x20))
            return(0x00, 0x20)
        }
   }


   function test2() external pure returns(bytes32)  {
        uint amt = 800 ether;
        address adr = 0x4D11dF920E0E48c7E132e5a9754C7e754Cd6EBFB;
        uint tme = 1692953302;
        uint tt;

        assembly {
            tt := add(adr, tme)
        }

        return keccak256(abi.encodePacked(tt+amt));
        
   }

}

// 800000000000000000000
// 0x4D11dF920E0E48c7E132e5a9754C7e754Cd6EBFB
// 1692953302