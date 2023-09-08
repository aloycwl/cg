// SPDX-License-Identifier: None
pragma solidity 0.8.18;
pragma abicoder v1;

import {ItemMgmt} from "../Util/ItemMgmt.sol";

contract Item is ItemMgmt {

    constructor(address sto, string memory nam, string memory sym) {
        assembly {
            sstore(STO, sto)
            sstore(NAM, mload(nam))
            sstore(NA2, mload(add(nam, 0x20)))
            sstore(SYM, mload(sym))
            sstore(SY2, mload(add(sym, 0x20)))
        }
    }

    function supportsInterface(bytes4 a) external pure returns(bool) {
        assembly {
            mstore(0x00, or(eq(a, INF), eq(a, IN2)))
            return(0x00, 0x20)
        }
    }

    function count() external view returns(uint) {
        assembly {
            mstore(0x00, sload(CNT))
            return(0x00, 0x20)
        }
    }

    function name() external view returns(string memory) {
        assembly {
            mstore(0x80, 0x20)
            mstore(0xa0, sload(NAM))
            mstore(0xc0, sload(NA2))
            return(0x80, 0x60)
        }
    }

    function symbol() external view returns(string memory) {
        assembly {
            mstore(0x80, 0x20)
            mstore(0xa0, sload(SYM))
            mstore(0xc0, sload(SY2))
            return(0x80, 0x60)
        }
    }

    function ownerOf(uint tid) external view returns(address) { // 0x6352211e
        assembly {
            // addressData(address(), 0x0, id)
            mstore(0x80, ADR)
            mstore(0x84, address())
            mstore(0xa4, 0x00)
            mstore(0xc4, tid)
            pop(staticcall(gas(), sload(STO), 0x80, 0x64, 0x0, 0x20))
            return(0x00, 0x20)
        }
    }

    function balanceOf(address adr) external view returns (uint) {
        assembly {
            // uintData(address(), addr, 0x0)
            mstore(0x80, UIN)
            mstore(0x84, address())
            mstore(0xa4, adr)
            mstore(0xc4, 0x00)
            pop(staticcall(gas(), sload(STO), 0x80, 0x64, 0x00, 0x20))
            return(0x00, 0x20)
        }
    }

    function tokenURI(uint tid) external view returns (string memory) {
        assembly {
            // CIDData(address(), id)
            mstore(0x80, CI2)
            mstore(0x84, address())
            mstore(0xa4, tid)
            pop(staticcall(gas(), sload(STO), 0x80, 0x44, 0xa0, 0x80))

            // string.concat()
            mstore(0x80, 0x20)
            mstore(0xa0, add(mload(0xc0), 0x20))
            mstore(0xc0, "ipfs://")
            return(0x80, 0xa0)
        }
    }

    function getApproved(uint tid) external view returns(address) {
        assembly {
            // addressData(address(), 0x1, id)
            mstore(0x80, ADR)
            mstore(0x84, address())
            mstore(0xa4, 0x01)
            mstore(0xc4, tid)
            pop(staticcall(gas(), sload(STO), 0x80, 0x64, 0x00, 0x20))
            return(0x00, 0x20)
        }
    }

    function isApprovedForAll(address frm, address toa) external view returns(bool) { // 0xe985e9c5
        assembly {
            // uintData(address(), from, to)
            mstore(0x80, UIN)
            mstore(0x84, address())
            mstore(0xa4, frm)
            mstore(0xc4, toa)
            pop(staticcall(gas(), sload(STO), 0x80, 0x64, 0x00, 0x20))
            return(0x00, 0x20)
        }
    }

    // 获取地址拥有的所有代币的数组
    function tokensOwned(address adr) external view returns(uint[] memory val) {
        uint len;

        // 先拿数组长度
        assembly {
            // uintEnum(address(), addr)
            mstore(0x80, ENU)
            mstore(0x84, address())
            mstore(0xa4, adr)
            pop(staticcall(gas(), sload(STO), 0x80, 0x84, 0x00, 0x40))
            len := mload(0x20)
        }

        val = new uint[](len);

        // 再每格插入
        assembly {
            // uintEnum(address(), addr)
            mstore(0x80, ENU)
            mstore(0x84, address())
            mstore(0xa4, adr)
            pop(staticcall(gas(), sload(STO), 0x80, 0x44, 0xa0, mul(add(len, 0x02), 0x20)))
            
            for { let i := 0x00 } lt(i, add(len, 0x02)) { i := add(i, 0x01) } {
                mstore(add(val, mul(i, 0x20)), mload(add(0xa0, mul(add(i, 0x01), 0x20))))
            }
        }
    }

    // gas: 67909
    function approve(address toa, uint tid) external { // 0x095ea7b3
        assembly {
            let sto := sload(STO)
            // ownerOf(id) = uintData(address(), 0x0, id)
            mstore(0x80, UIN)
            mstore(0x84, address())
            mstore(0xa4, 0x00)
            mstore(0xc4, tid)
            pop(staticcall(gas(), sto, 0x80, 0x64, 0x00, 0x20))
            let oid := mload(0x00)

            // isApprovedForAll(oid, msg.sender)
            mstore(0xa4, oid)
            mstore(0xc4, caller())
            pop(staticcall(gas(), sto, 0x80, 0x64, 0x00, 0x20))

            // require(msg.sender == ownerOf(id) || isApprovedForAll(ownerOf(id), msg.sender))
            if and(iszero(eq(caller(), oid)), iszero(mload(0x00))) {
                mstore(0x80, ERR) 
                mstore(0x84, 0x20)
                mstore(0xA4, 0x09)
                mstore(0xC4, "not owner")
                revert(0x80, 0x64)
            }

            // uintData(address(), 0x1, id, to)
            mstore(0x80, UID)
            mstore(0x84, address())
            mstore(0xa4, 0x01)
            mstore(0xc4, tid)
            mstore(0xe4, toa)
            pop(call(gas(), sto, 0x00, 0x80, 0x84, 0x00, 0x00))

            // emit Approval()
            log4(0x00, 0x00, EAP, oid, toa, tid)
        }
    }

    // gas: 61095
    function setApprovalForAll(address toa, bool bol) external {
        assembly {
            // uintData(address(), caller(), to, bol)
            mstore(0x80, UID)
            mstore(0x84, address())
            mstore(0xa4, caller())
            mstore(0xc4, toa)
            mstore(0xe4, bol)
            pop(call(gas(), sload(STO), 0x00, 0x80, 0x84, 0x00, 0x00))

            // emit ApprovalForAll()
            mstore(0x00, bol)
            log3(0x00, 0x20, EAA, origin(), toa)
        }
    }

    function safeTransferFrom(address frm, address toa, uint tid) external {
        transferFrom(frm, toa, tid); 
    }

    function safeTransferFrom(address frm, address toa, uint tid, bytes memory) external {
        transferFrom(frm, toa, tid); 
    }

    function transferFrom(address, address toa, uint tid) public { // 0x23b872dd
        address oid;

        assembly {
            let sto := sload(STO)
            // ownerOf(id) = uintData(address(), addr, 0x0)
            mstore(0x80, UIN)
            mstore(0x84, address())
            mstore(0xa4, 0x00)
            mstore(0xc4, tid)
            pop(staticcall(gas(), sto, 0x80, 0x64, 0x00, 0x20))
            oid := mload(0x00)

            // balanceOf(oid)
            mstore(0xa4, oid)
            mstore(0xc4, 0x00)
            pop(staticcall(gas(), sto, 0x80, 0x64, 0x00, 0x20))
            let baf := mload(0x00)

            // balanceOf(to)
            mstore(0xa4, toa)
            pop(staticcall(gas(), sto, 0x80, 0x64, 0x00, 0x20))
            let bat := mload(0x00)

            // getApproved(id)
            mstore(0xa4, 0x01)
            mstore(0xc4, tid)
            pop(staticcall(gas(), sto, 0x80, 0x64, 0x00, 0x20))

            // require(所有者 || 被授权)
            if and(iszero(eq(mload(0x00), toa)), iszero(eq(oid, caller()))) {
                mstore(0x80, ERR) 
                mstore(0x84, 0x20)
                mstore(0xA4, 0x0c)
                mstore(0xC4, "approval err")
                revert(0x80, 0x64)
            }

            // tokensOwned()-- intEnum(address(), oid, id, 1)
            mstore(0x80, ENM)
            mstore(0x84, address())
            mstore(0xa4, oid)
            mstore(0xc4, tid)
            mstore(0xe4, 0x01)
            pop(call(gas(), sto, 0x00, 0x80, 0x84, 0x00, 0x00))

            // tokensOwned()++
            if gt(toa, 0x00) {
                mstore(0xa4, toa)
                mstore(0xe4, 0x00)
                pop(call(gas(), sto, 0x00, 0x80, 0x84, 0x00, 0x00))
            }

            // approval[id] = uintData(address(), 1, id, 0) = 0
            mstore(0x80, UID)
            mstore(0x84, address())
            mstore(0xa4, 0x01)
            mstore(0xc4, tid)
            mstore(0xe4, 0x00)
            pop(call(gas(), sto, 0x00, 0x80, 0x84, 0x00, 0x00))

            // ownerOf[id] = to
            mstore(0xa4, 0x00)
            mstore(0xc4, tid)
            mstore(0xe4, toa)
            pop(call(gas(), sto, 0x00, 0x80, 0x84, 0x00, 0x00))

            // --balanceOf(oid)
            mstore(0xa4, oid)
            mstore(0xc4, 0x00)
            mstore(0xe4, sub(baf, 0x01))
            pop(call(gas(), sto, 0x00, 0x80, 0x84, 0x00, 0x00))

            // ++balanceOf(to)
            if gt(toa, 0x00) {
                mstore(0xa4, toa)
                mstore(0xe4, add(0x01, bat))
                pop(call(gas(), sto, 0x00, 0x80, 0x84, 0x00, 0x00))
            }

            // emit Transfer()
            log4(0x00, 0x00, ETF, oid, toa, tid)
        }
        checkSuspend(oid, toa);
    }

    // 用transferFrom烧毁再mint多一次
    function merge(uint[] memory ids, uint lis, string memory uri, uint8 v, bytes32 r, bytes32 s) external payable {
        for(uint i; i < ids.length; i++) transferFrom(address(0x00), address(0x00), ids[i]);
        mint(lis, uri, v, r, s);
    }
    
}