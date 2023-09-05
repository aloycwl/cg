// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

/*
A database to store the CID that could have been reused and
wasted the total storage space. This will be more effective
than ERC-1155 if the CID of the metadate is the same. Instead
of using at least 3 memory lines for string, CID database only
need 1 storage slot to fetch the CID or URL.

Store the CID with a return uint value if it does not exist.
The uint value will be used to call the fetch() function
which will return the string.
*/

contract CIDDB {
    bytes32 constant private CDB = 0x34b90c3fe4058816a5fd62fd112c01472c461559e126623d04d1af72d9ad437e;
    /*mapping(string => uint) public search;
    mapping(uint => string) public fetch;
    
    bytes32 constant private FET = 0x6c1ac4b2af2ca57a4d77eb6a4b0bffbc328fc8319414baf27e6210b191a852a8;

    function setFetch(string memory cid) external returns(uint nwc) {
        if (search[cid] > 0) return search[cid];
        assembly {
            nwc := add(sload(CDB), 1)
            sstore(0x00, nwc)
        }
        search[cid] = nwc;
        fetch[nwc] = cid;
    }

    function count() external view returns(uint) {
        assembly {
            mstore(0x00, sload(CDB))
            return(0x00, 0x20)
        }
    }*/

    function store(string memory str) external returns(uint nwc) {
        assembly {
            // nwc = count++
            nwc := add(sload(CDB), 0x01)
            sstore(CDB, nwc)

            // str(length)
            mstore(0x00, nwc)
            mstore(0x20, CDB)
            let ptr := keccak256(0x00, 0x40)
            sstore(ptr, mload(str))

            // store each line
            for { let i := 0x01 } lt(mul(0x20, sub(i, 0x01)), mload(str)) { i := add(i, 0x01) } {
                sstore(add(ptr, i), mload(add(str, mul(i, 0x20))))
            }
        }
    }

    function fetch(uint cid) external view returns(string memory) {
        assembly {
            // str(length)
            mstore(0x00, cid)
            mstore(0x20, CDB)
            let ptr := keccak256(0x00, 0x40)
            mstore(0x80, 0x20)
            mstore(0xa0, sload(ptr))
            let cnt := 0x40

            //mstore(0xc0, "abcdefghi")
            for { let i := 0x01 } lt(mul(0x20, sub(i, 0x01)), sload(ptr)) { i := add(i, 0x01) } {
                mstore(add(0xa0, mul(0x20, i)), sload(add(ptr, mul(i, 0x20))))
                cnt := add(0x20, cnt)
            }


            return(0x80, cnt)
        }
    }

    
}

