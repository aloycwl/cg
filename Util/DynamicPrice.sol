// SPDX-License-Identifier: None
pragma solidity 0.8.18;

contract DynamicPrice {

    bytes32 constant private STO = 0x79030946dd457157e4aa08fcb4907c422402e75f0f0ecb4f2089cb35021ff964;
    bytes32 constant private OWN = 0x658a3ae51bffe958a5b16701df6cfe4c3e73eac576c08ff07c35cf359a8a002e;
    bytes32 constant private ERR = 0x08c379a000000000000000000000000000000000000000000000000000000000;
    bytes32 constant private LI2 = 0xdf0188db00000000000000000000000000000000000000000000000000000000;
    bytes32 constant private TFM = 0x23b872dd00000000000000000000000000000000000000000000000000000000;

    constructor() {
        assembly {
            sstore(OWN, caller())
        }
    }

    function owner() external view returns (address a) {
        assembly {
            a := sload(OWN)
        }
    }

    function pay(address adr, uint lst, address toa, uint qty, uint fee) internal {
        assembly {
            // listData(address,address,uint256)
            mstore(0x80, LI2) 
            mstore(0x84, address())
            mstore(0xa4, adr)
            mstore(0xc4, lst)
            pop(staticcall(gas(), sload(STO), 0x80, 0x64, 0x00, 0x40))
            let tka := mload(0x00)
            let amt := mul(qty, mload(0x20))
            // 有价格才执行
            if gt(tka, 0x00) {
                fee := mul(qty, div(mul(amt, sub(0x2710, fee)), 0x2710))
                // 转货币
                if eq(tka, 0x01) {
                    // require(msg.value > amt)
                    if gt(amt, callvalue()) { 
                        mstore(0x80, ERR) 
                        mstore(0x84, 0x20)
                        mstore(0xA4, 0x08)
                        mstore(0xC4, "coin err")
                        revert(0x80, 0x64)
                    }
                    pop(call(gas(), toa, sub(amt, fee), 0x00, 0x00, 0x00, 0x00))
                    pop(call(gas(), sload(OWN), selfbalance(), 0x00, 0x00, 0x00, 0x00))
                }
                // 转代币
                if gt(tka, 0x01) {
                    // transferFrom(origin(), to, amt)
                    mstore(0x80, TFM)
                    mstore(0x84, origin())
                    // require(transferForm(origin(), to, fee) = true)
                    mstore(0xa4, toa)
                    mstore(0xc4, fee)    
                    if iszero(call(gas(), tka, 0x00, 0x80, 0x64, 0x00, 0x00)) {
                        mstore(0x80, ERR) 
                        mstore(0x84, 0x20)
                        mstore(0xA4, 0x09)
                        mstore(0xC4, "token err")
                        revert(0x80, 0x64)
                    }
                    // require(transferForm(origin(), owner, fee) = true)
                    if gt(fee, 0x00) {
                        mstore(0xa4, sload(OWN))
                        mstore(0xc4, sub(amt, fee))
                        if iszero(call(gas(), tka, 0x00, 0x80, 0x64, 0x00, 0x00)) {
                            mstore(0x80, ERR) 
                            mstore(0x84, 0x20)
                            mstore(0xA4, 0x07)
                            mstore(0xC4, "fee err")
                            revert(0x80, 0x64)
                        }
                    }
                }
            }
        }
    }
}