// SPDX-License-Identifier: None
pragma solidity 0.8.18;
pragma abicoder v1;

abstract contract UUPSUpgradeable {
    bytes32 constant public UUID = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    bytes32 constant private OWN = 0x02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c0;
    bytes32 constant private INI = 0x9016906c42b25b8b9c5a4f8fb96df431241948aae1ac92547e2f35e14403c4d8;
    bytes32 constant private ERR = 0x08c379a000000000000000000000000000000000000000000000000000000000;

    function init() internal {
        assembly {
            // require(INI == 0)
            if sload(INI) {
                mstore(0x80, ERR) 
                mstore(0x84, 0x20) 
                mstore(0xA4, 0x08)
                mstore(0xC4, "init err")
                revert(0x80, 0x64)
            }
            // owner = msg.sender
            sstore(OWN, caller())
            // inited = true;
            sstore(INI, 0x01)
        }
    }

    function upgradeTo(address adr) external {
        //upgradeToAndCall(adr, new bytes(0));
        assembly {
            // require(OWN == msg.sender)
            if iszero(eq(caller(), sload(OWN))) {
                mstore(0x80, ERR) 
                mstore(0x84, 0x20) 
                mstore(0xA4, 0x07)
                mstore(0xC4, "upg err")
                revert(0x80, 0x64)
            }
            sstore(UUID, adr) 
        }
    }

}
