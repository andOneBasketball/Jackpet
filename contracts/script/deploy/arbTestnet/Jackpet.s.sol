// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Test.sol";
import {Jackpet} from "../../../src/Jackpet.sol";

contract JackpetScript is Script {
    Jackpet public jackpet;
    address public vrfCoordinator =
        address(0x5CE8D5A2BC84beb22a398CCA51996F7930313D61);
    bytes32 public keyHash =
        0x1770bdc7eec7771f7ba4ffd640f34260d7f095b79c92d34a5b2551d6f6cfd2be;
    uint256 public subId =
        40151870665596170781987746063650977219388333038745243125103493267748337392849;
    uint256 public ticketFeeWei = 0.01 ether;
    uint32 public maxTicketRate = 10000;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        jackpet = new Jackpet(
            vrfCoordinator,
            keyHash,
            subId,
            ticketFeeWei,
            maxTicketRate
        );

        console.log(
            string.concat(
                "jackpet contract deployed, owner=",
                vm.toString(jackpet.owner())
            )
        );

        vm.stopBroadcast();
    }
}
