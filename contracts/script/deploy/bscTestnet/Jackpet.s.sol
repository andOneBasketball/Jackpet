// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Test.sol";
import {Jackpet} from "../../../src/Jackpet.sol";

contract JackpetScript is Script {
    Jackpet public jackpet;
    address public vrfCoordinator =
        address(0xDA3b641D438362C440Ac5458c57e00a712b66700);
    bytes32 public keyHash =
        0x8596b430971ac45bdf6088665b9ad8e8630c9d5049ab54b14dff711bee7c0e26;
    uint256 public subId =
        72280575575369334062451027855862925776312375794399525949111572405623193491458;
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
