// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {Jackpet} from "../src/Jackpet.sol";
import {
    MockVRFCoordinatorV2Plus
} from "../src/mocks/MockVRFCoordinatorV2Plus.sol";

contract JackpetTest is Test {
    Jackpet public jackpet;
    MockVRFCoordinatorV2Plus public coordinator;
    uint256 public ticketFeeWei = 0.01 ether;
    uint32 public maxTicketRate = 1000; // 1x to 10x
    address public owner = address(0x123); // 使用实际的地址
    address public user = address(0x456); // 使用实际的地址
    address public withdrawUser = address(0x789); // 使用实际的地址

    event PlayResult(
        uint256 indexed requestId,
        address indexed player,
        uint8 a,
        uint8 b,
        uint8 c,
        uint32 ticketRate,
        uint256 payoutWei,
        uint256 jackpotPayout
    );

    function setUp() public {
        coordinator = new MockVRFCoordinatorV2Plus();

        // 部署 Jackpet 合约
        bytes32 keyHash = bytes32(0);
        uint64 subId = 1;

        vm.prank(owner);
        jackpet = new Jackpet(
            address(coordinator),
            keyHash,
            subId,
            ticketFeeWei,
            maxTicketRate
        );

        // 向 jackpet 合约转账一定的金额
        uint256 amount = 10 ether;
        payable(address(jackpet)).transfer(amount);

        // 使用设置的地址发送资金
        vm.deal(owner, 10 ether);
        vm.deal(user, 10 ether);

        // 先 play 积累奖池
        uint256 beforePool = jackpet.jackpotPool();
        vm.prank(user);
        uint256 requestId = jackpet.play{value: 10 * ticketFeeWei}(1000);

        uint256[] memory random = new uint256[](1);
        random[0] = 1;
        vm.prank(address(coordinator));

        coordinator.fulfill(requestId, random);
        uint256 afterPool = jackpet.jackpotPool();
        uint256 jackpotContributionRate = jackpet.jackpotContributionRate();
        assertEq(
            ((10 * ticketFeeWei) * jackpotContributionRate) / 10000,
            afterPool
        );
        console.log(
            string.concat(
                "jackpet contract deployed, owner=",
                vm.toString(jackpet.owner()),
                ", play end, jackpotPool number before=",
                vm.toString(beforePool),
                ", after=",
                vm.toString(afterPool)
            )
        );
    }

    // 测试 exact ticket fee
    function testPlayRequiresExactTicketFee() public {
        vm.prank(user);
        // 检查 fee 太少
        vm.expectRevert(bytes("BAD_FEE"));
        jackpet.play{value: ticketFeeWei - 1}(100);

        vm.prank(user);
        // 检查 fee 太多
        vm.expectRevert(bytes("BAD_FEE"));
        jackpet.play{value: ticketFeeWei + 1}(100);

        vm.prank(user);
        // 检查 rate 超出范围
        vm.expectRevert(bytes("BAD_RATE"));
        jackpet.play{value: (1001 * ticketFeeWei) / 100}(1001);

        vm.prank(user);
        // 检查 rate 超出范围
        vm.expectRevert(bytes("BAD_RATE"));
        jackpet.play{value: (1001 * ticketFeeWei) / 100}(99);
    }

    // 测试 play emits request and can be fulfilled by mock
    function testPlayEmitsRequestAndCanBeFulfilled() public {
        vm.recordLogs();

        uint256 playAmount = ticketFeeWei;
        vm.prank(user);
        uint256 requestId = jackpet.play{value: playAmount}(100);

        // Fulfill with deterministic random number
        uint256[] memory random = new uint256[](1);
        random[0] = 123456789;
        vm.prank(address(coordinator));

        coordinator.fulfill(requestId, random);

        Vm.Log[] memory entries = vm.getRecordedLogs();

        // 4️⃣ 遍历日志，找到 PlayResult 事件
        for (uint256 i = 0; i < entries.length; i++) {
            Vm.Log memory log = entries[i];

            // PlayResult 的事件签名
            bytes32 eventSig = keccak256(
                "PlayResult(uint256,address,uint8,uint8,uint8,uint32,uint256,uint256)"
            );
            if (log.topics[0] == eventSig) {
                uint256 reqId = uint256(log.topics[1]);
                address player = address(uint160(uint256(log.topics[2])));
                (
                    uint8 a,
                    uint8 b,
                    uint8 c,
                    uint32 ticketRate,
                    uint256 payoutWei,
                    uint256 jackpotPayout
                ) = abi.decode(
                        log.data,
                        (uint8, uint8, uint8, uint32, uint256, uint256)
                    );

                assertEq(requestId, reqId);
                assertEq(user, player);
                assertEq(6, a);
                assertEq(4, b);
                assertEq(2, c);
                assertEq(100, ticketRate);
                assertEq(ticketFeeWei + ticketFeeWei / 10, payoutWei);
                assertEq(0, jackpotPayout);
                console.log(
                    string.concat(
                        "PlayResult rid=",
                        vm.toString(reqId),
                        " player=",
                        vm.toString(player),
                        " counts=[",
                        vm.toString(a),
                        ",",
                        vm.toString(b),
                        ",",
                        vm.toString(c),
                        "] ",
                        " ticketRate=",
                        vm.toString(ticketRate),
                        " payout(gwei)=",
                        vm.toString(payoutWei / 1e9),
                        " jackpot=",
                        vm.toString(jackpotPayout)
                    )
                );
            }
        }
    }

    // play 840
    function testPlay840() public {
        vm.recordLogs();

        vm.prank(user);
        uint256 requestId = jackpet.play{value: 5 * ticketFeeWei}(500);

        // Fulfill with deterministic random number
        uint256[] memory random = new uint256[](1);
        random[0] = 8498;
        vm.prank(address(coordinator));
        coordinator.fulfill(requestId, random);

        Vm.Log[] memory entries = vm.getRecordedLogs();

        for (uint256 i = 0; i < entries.length; i++) {
            Vm.Log memory log = entries[i];

            // PlayResult 的事件签名
            bytes32 eventSig = keccak256(
                "PlayResult(uint256,address,uint8,uint8,uint8,uint32,uint256,uint256)"
            );
            if (log.topics[0] == eventSig) {
                uint256 reqId = uint256(log.topics[1]);
                address player = address(uint160(uint256(log.topics[2])));
                (
                    uint8 a,
                    uint8 b,
                    uint8 c,
                    uint32 ticketRate,
                    uint256 payoutWei,
                    uint256 jackpotPayout
                ) = abi.decode(
                        log.data,
                        (uint8, uint8, uint8, uint32, uint256, uint256)
                    );

                assertEq(requestId, reqId);
                assertEq(user, player);
                assertEq(8, a);
                assertEq(4, b);
                assertEq(0, c);
                assertEq(500, ticketRate);
                assertEq((ticketFeeWei * 5500) / 100, payoutWei);
                assertEq(0.00099 ether, jackpotPayout);
                console.log(
                    string.concat(
                        "PlayResult rid=",
                        vm.toString(reqId),
                        " player=",
                        vm.toString(player),
                        " counts=[",
                        vm.toString(a),
                        ",",
                        vm.toString(b),
                        ",",
                        vm.toString(c),
                        "] ",
                        " ticketRate=",
                        vm.toString(ticketRate),
                        " payout(gwei)=",
                        vm.toString(payoutWei / 1e9),
                        " jackpot(gwei)=",
                        vm.toString(jackpotPayout / 1e9)
                    )
                );
            }
        }
    }

    function testLosingTicketContributesToJackpot() public {
        vm.recordLogs();

        uint256 beforePool = jackpet.jackpotPool();
        vm.prank(user);
        uint256 requestId = jackpet.play{value: ticketFeeWei}(100);

        // Fulfill with deterministic random number
        uint256[] memory random = new uint256[](1);
        random[0] = 1;
        vm.prank(address(coordinator));
        coordinator.fulfill(requestId, random);

        uint256 afterPool = jackpet.jackpotPool();

        Vm.Log[] memory entries = vm.getRecordedLogs();

        for (uint256 i = 0; i < entries.length; i++) {
            Vm.Log memory log = entries[i];

            // PlayResult 的事件签名
            bytes32 eventSig = keccak256(
                "PlayResult(uint256,address,uint8,uint8,uint8,uint32,uint256,uint256)"
            );
            if (log.topics[0] == eventSig) {
                uint256 reqId = uint256(log.topics[1]);
                address player = address(uint160(uint256(log.topics[2])));
                (
                    uint8 a,
                    uint8 b,
                    uint8 c,
                    uint32 ticketRate,
                    uint256 payoutWei,
                    uint256 jackpotPayout
                ) = abi.decode(
                        log.data,
                        (uint8, uint8, uint8, uint32, uint256, uint256)
                    );

                assertEq(requestId, reqId);
                assertEq(user, player);
                assertEq(5, a);
                assertEq(4, b);
                assertEq(3, c);
                assertEq(100, ticketRate);
                assertEq(0, payoutWei);
                assertGt(afterPool, beforePool);
                console.log(
                    string.concat(
                        "PlayResult rid=",
                        vm.toString(reqId),
                        " player=",
                        vm.toString(player),
                        " counts=[",
                        vm.toString(a),
                        ",",
                        vm.toString(b),
                        ",",
                        vm.toString(c),
                        "] ",
                        " ticketRate=",
                        vm.toString(ticketRate),
                        " payout(gwei)=",
                        vm.toString(payoutWei / 1e9),
                        " jackpot(gwei)=",
                        vm.toString(jackpotPayout / 1e9),
                        " beforePool(gwei)=",
                        vm.toString(beforePool / 1e9),
                        " afterPool(gwei)=",
                        vm.toString(afterPool / 1e9)
                    )
                );
            }
        }
    }

    function testOwnerWithdraw() public {
        uint256 jackpot = jackpet.jackpotPool();
        uint256 contractBalance = address(jackpet).balance;
        uint256 withdrawable = contractBalance - jackpot;

        vm.prank(owner);
        vm.expectRevert(bytes("INSUFFICIENT_NON_JACKPOT_BAL"));
        jackpet.withdrawFunds(payable(withdrawUser), contractBalance);

        vm.prank(owner);
        jackpet.withdrawFunds(payable(withdrawUser), withdrawable);
        assertEq(address(withdrawUser).balance, withdrawable);
        assertEq(jackpet.jackpotPool(), jackpot);
        console.log(
            string.concat(
                "owner withdraws ",
                vm.toString(withdrawable / 1e9),
                " gwei, contract balance=",
                vm.toString(contractBalance / 1e9),
                " gwei, jackpot=",
                vm.toString(jackpot / 1e9),
                " gwei"
            )
        );
    }

    // 模拟 VRF fulfill 操作
    function fulfill(uint256 requestId, uint256[] memory randomWords) public {
        coordinator.fulfill(requestId, randomWords);
    }
}
