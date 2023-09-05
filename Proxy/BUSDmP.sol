// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

import {UUPSUpgradeable} from "./UUPS.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

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