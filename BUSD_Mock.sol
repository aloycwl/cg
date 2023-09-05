// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GLDToken is ERC20 {
    constructor() ERC20("USDT Mock", "USDTM") {
        _mint(msg.sender, 1e24);
    }
}