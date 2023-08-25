// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

import {Storage} from "../Storage.sol";
import {Item} from "../Item.sol";
import {Coin} from "../Coin.sol";
import {Market} from "../Market.sol";

contract Deployer {

    address public STO;
    address public COI;
    address public ITE;
    address public MKT;

    constructor() {
        (STO, COI, ITE, MKT) = (address(new Storage()),
            address(new Coin(STO, "Coin", "COI")),
            address(new Item(STO, "Item", "ITE")),
            address(new Market(STO)));

        assembly {
            let sto := sload(STO.slot)
            // setAccess()
            mstore(0x80, 0x850bbe8700000000000000000000000000000000000000000000000000000000)
            mstore(0x84, caller())
            mstore(0xa4, 0x01)
            pop(call(gas(), sto, 0x00, 0x80, 0x44, 0xa0, 0x80))
            mstore(0x84, sload(COI.slot))
            mstore(0xa4, 0x01)
            pop(call(gas(), sto, 0x00, 0x80, 0x44, 0xa0, 0x80))
            mstore(0x84, sload(ITE.slot))
            mstore(0xa4, 0x01)
            pop(call(gas(), sto, 0x00, 0x80, 0x44, 0xa0, 0x80))
            mstore(0x84, sload(MKT.slot))
            mstore(0xa4, 0x01)
            pop(call(gas(), sto, 0x00, 0x80, 0x44, 0xa0, 0x80))
        }
    }

}