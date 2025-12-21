# Core Gameplay Mechanics

Jackpet is a decentralized, luck-based on-chain game built on Arbitrum.

Each game round follows a deterministic and fully on-chain process,
with randomness supplied by verifiable infrastructure.

## Game Entry

- Players participate by purchasing a ticket with a fixed base fee of **0.01 ETH**.
- A player may choose a **ticket rate (multiplier)** up to 100× to increase potential rewards.
- Each game round is initiated by calling the `play` function on the smart contract.

## Game Flow

1. A player submits a transaction with the required ticket fee.
2. The contract requests a random value using Chainlink VRF.
3. Once randomness is fulfilled, the game draws **12 pets** from a predefined pool.
4. The drawn pets are evaluated against predefined reward rules.
5. The contract settles rewards and, if applicable, distributes jackpot funds.

All steps after the initial transaction are executed automatically by the contract,
without any off-chain intervention.

## Pet Drawing Mechanism

- The game uses a pool of **24 pets**, consisting of **3 types**, with **8 pets per type**.
- For each round, **12 pets are drawn without replacement**.
- The resulting counts of each pet type determine the game outcome.

This mechanism ensures that every round has a well-defined probability distribution
and prevents manipulation or repetition within a single draw.

## Settlement

- Rewards are calculated strictly according to the predefined rule table.
- If a round results in no payout, a portion of the ticket fee contributes to the jackpot pool.
- All settlements occur atomically within the same transaction that finalizes the round.
