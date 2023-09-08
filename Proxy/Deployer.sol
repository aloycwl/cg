// SPDX-License-Identifier: None
pragma solidity 0.8.18;
pragma abicoder v1;

import {UUPSUpgradeable} from "../Proxy/UUPS.sol";
import {Storage} from ".././Storage.sol";
import {Item} from ".././Item.sol";
import {Market} from ".././Market.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StorageP is Storage, UUPSUpgradeable {

    function initialize() external {
        init();
        assembly {
            // 设置signer
            mstore(0x80, 0x00)
            mstore(0xa0, 0x00)
            mstore(0xc0, 0x01)
            sstore(keccak256(0x80, 0x60), caller())
            // 设置access, 不能用Access constructor因为写不进
            sstore(caller(), 0xff)
        }
    }

}

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

contract MarketP is Market, UUPSUpgradeable {

    constructor() Market(address(0)) { }

    function initialize(address sto) external {
        init();
        assembly {
            sstore(STO, sto)
            // owner = msg.sender 不能用DynamicPrice constructor因为写不进
            sstore(0x658a3ae51bffe958a5b16701df6cfe4c3e73eac576c08ff07c35cf359a8a002e, caller())
            // 设置access, 不能用Access constructor因为写不进
            sstore(caller(), 0xff)
        }
    }
    
}

contract BUSDmP is ERC20, UUPSUpgradeable {

    constructor() ERC20("", "") { }

    function initialize() external {
        init();
        _mint(msg.sender, 1e24);
    }

    function name() override public pure returns(string memory) {
        assembly {
            mstore(0x0, 0x20)
            mstore(0x20, 0x09)
            mstore(0x40, "BUSD Mock")
            return(0x0, 0x60)
        }
    }

    function symbol() override public pure returns(string memory) { 
        assembly {
            mstore(0x0, 0x20)
            mstore(0x20, 0x05)
            mstore(0x40, "BUSDm")
            return(0x0, 0x60)
        }
    }
    
}