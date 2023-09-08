// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

import {UUPSUpgradeable} from "../Proxy/UUPS.sol";
import {Item} from ".././Item.sol";

contract ItemP is Item, UUPSUpgradeable {

    constructor() Item(address(0), "", "") { }

    function initialize(address sto) external {
        init();
        assembly {
            sstore(STO, sto)
            sstore(NAM, 0x0a)
            sstore(NA2, "Item Proxy")
            sstore(SYM, 0x03)
            sstore(SY2, "ItP")
            // owner = msg.sender 不能用DynamicPrice constructor因为写不进
            sstore(0x658a3ae51bffe958a5b16701df6cfe4c3e73eac576c08ff07c35cf359a8a002e, caller())
        }
    }
    
}