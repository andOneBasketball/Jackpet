// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

interface VRFConsumerBaseV2PlusLike {
    function rawFulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) external;
}

contract MockVRFCoordinatorV2Plus {
    uint256 public nextRequestId = 1;
    mapping(uint256 => address) public consumers;

    event RandomWordsRequested(
        uint256 indexed requestId,
        address indexed consumer
    );
    event RandomWordsFulfilled(
        uint256 indexed requestId,
        address indexed consumer,
        uint256[] randomWords
    );

    function requestRandomWords(
        VRFV2PlusClient.RandomWordsRequest calldata /*req*/
    ) external returns (uint256 requestId) {
        requestId = nextRequestId++;
        consumers[requestId] = msg.sender;
        emit RandomWordsRequested(requestId, msg.sender);
    }

    function fulfill(
        uint256 requestId,
        uint256[] calldata randomWords
    ) external {
        address consumer = consumers[requestId];
        require(consumer != address(0), "UNKNOWN_REQUEST");
        uint256[] memory words = randomWords;
        VRFConsumerBaseV2PlusLike(consumer).rawFulfillRandomWords(
            requestId,
            words
        );
        emit RandomWordsFulfilled(requestId, consumer, words);
        delete consumers[requestId];
    }
}
