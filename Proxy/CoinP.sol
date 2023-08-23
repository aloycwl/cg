// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

import {UUPSUpgradeable} from "./UUPS.sol";
import {Coin} from "../Coin.sol";

contract CoinP is Coin, UUPSUpgradeable {

    constructor() Coin(address(0), "", "") { }

    function initialize(address sto, string memory nam, string memory syb) external {
        init();
        assembly {
            // 设置string和string.length
            sstore(STO, sto)
            sstore(NAM, mload(nam))
            sstore(NA2, mload(add(nam, 0x20)))
            sstore(SYM, mload(syb))
            sstore(SY2, mload(add(syb, 0x20)))
        } 
    }

}