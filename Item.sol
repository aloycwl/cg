// SPDX-License-Identifier: None
pragma solidity 0.8.18;

import {ItemMgmt} from "../Util/ItemMgmt.sol";

contract Item is ItemMgmt {

    constructor(string memory nam, string memory sym) {
        assembly {
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

    function ownerOf(uint tid) external view returns(address) {
        assembly {
            mstore(0x00, sload(tid))
            return(0x00, 0x20)
        }
    }

    function balanceOf(address adr) external view returns (uint) {
        assembly {
            mstore(0x00, adr)
            mstore(0x00, sload(keccak256(0x00, 0x20)))
            return(0x00, 0x20)
        }
    }

    function tokenURI(uint tid) external view returns (string memory) {
        assembly {
            mstore(0x00, tid)
            let tmp := keccak256(0x00, 0x20)
            mstore(0x80, 0x20)
            mstore(0xa0, 0x35)
            mstore(0xc0, sload(tmp))
            mstore(0xe0, sload(add(tmp, 0x01)))
            return(0x80, 0x80)
        }
    }

    function getApproved(uint tid) external view returns(address) {
        assembly {
            mstore(0x00, APP)
            mstore(0x20, tid)
            mstore(0x00, sload(keccak256(0x00, 0x40)))
            return(0x00, 0x20)
        }
    }

    function isApprovedForAll(address frm, address toa) external view returns(bool) { // 0xe985e9c5
        assembly {
            mstore(0x00, frm)
            mstore(0x00, toa)
            mstore(0x00, sload(keccak256(0x00, 0x40)))
            return(0x00, 0x20)
        }
    }

    // gas: 67909
    function approve(address toa, uint tid) external {
        assembly {
            let sto := sload(STO)
            let oid := sload(tid) // ownerOf(tid)

            // isApprovedForAll(oid, msg.sender)
            mstore(0x00, oid)
            mstore(0x00, toa)
            mstore(0x00, sload(keccak256(0x00, 0x40)))

            // require(msg.sender == ownerOf(tid) || isApprovedForAll(ownerOf(tid), msg.sender))
            if and(iszero(eq(caller(), oid)), iszero(mload(0x00))) {
                mstore(0x80, ERR) 
                mstore(0x84, 0x20)
                mstore(0xA4, 0x09)
                mstore(0xC4, "not owner")
                revert(0x80, 0x64)
            }

            // approve[tid] = toa
            mstore(0x00, APP)
            mstore(0x20, tid)
            sstore(keccak256(0x00, 0x40), toa)

            // emit Approval()
            log4(0x00, 0x00, EAP, oid, toa, tid)
        }
    }

    // gas: 61095
    function setApprovalForAll(address toa, bool bol) external {
        assembly {
            mstore(0x00, caller())
            mstore(0x00, toa)
            sstore(keccak256(0x00, 0x40), bol)
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
            oid := sload(tid) // ownerOf(tid)

            // balanceOf(oid)
            mstore(0xa4, oid)
            mstore(0xc4, 0x02)
            pop(staticcall(gas(), sto, 0x80, 0x64, 0x00, 0x20))
            let baf := mload(0x00)

            // balanceOf(to)
            mstore(0xa4, toa)
            mstore(0xc4, 0x02)
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

            // tokensOwned()-- uintPop(bytes32, id)
            mstore(0x00, address())
            mstore(0x20, oid)
            mstore(0x80, POP)
            mstore(0x84, keccak256(0x00, 0x40))
            mstore(0xa4, tid)
            pop(call(gas(), sto, 0x00, 0x80, 0x44, 0x00, 0x00))

            // tokensOwned()++ uintPush(bytes32, id)
            if gt(toa, 0x00) {
                mstore(0x00, address())
                mstore(0x20, toa)
                mstore(0x80, PUS)
                mstore(0x84, keccak256(0x00, 0x40))
                mstore(0xa4, tid)
                pop(call(gas(), sto, 0x00, 0x80, 0x44, 0x00, 0x00))
            }

            // ownerOf[id] = toa
            sstore(tid, toa)

            // approval[id] = uintData(address(), 1, id, 0) = 0
            mstore(0x80, UID)
            mstore(0x84, address())
            mstore(0xa4, 0x01)
            mstore(0xc4, tid)
            mstore(0xe4, 0x00)
            pop(call(gas(), sto, 0x00, 0x80, 0x84, 0x00, 0x00))

            // --balanceOf(oid)
            mstore(0xa4, oid)
            mstore(0xc4, 0x02)
            mstore(0xe4, sub(baf, 0x01))
            pop(call(gas(), sto, 0x00, 0x80, 0x84, 0x00, 0x00))

            // ++balanceOf(to)
            if gt(toa, 0x00) {
                mstore(0xa4, toa)
                mstore(0xc4, 0x02)
                mstore(0xe4, add(bat, 0x01))
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
        string[] memory ur2 = new string[](1);
        ur2[0] = uri;
        mint(lis, ur2, v, r, s);
    }
    
}