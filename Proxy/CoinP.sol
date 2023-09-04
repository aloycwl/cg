// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

import {UUPSUpgradeable} from "./UUPS.sol";
import {Coin} from "../Coin.sol";

contract CoinP is Coin, UUPSUpgradeable {

    constructor() Coin(address(0), "", "") { }

    function initialize(address sto) external {
        init();
        assembly {
            // 设置string和string.length
            sstore(STO, sto)
            sstore(NAM, "Coin Proxy")
            sstore(NA2, 0x0a)
            sstore(SYM, "CoP")
            sstore(SY2, 0x03)
        } 
    }

}