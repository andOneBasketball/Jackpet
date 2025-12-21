# Reward Rules

Jackpet uses a deterministic rule-based system to evaluate each game round.

After drawing 12 pets, the counts of the three pet types are sorted in descending order
and represented as a combination `{a, b, c}`.

Each combination maps to a predefined reward rule.

## Reward Components

Each rule may include one or both of the following components:

1. **Fixed Ticket Payout**  
   A multiplier applied to the base ticket fee, scaled by the player's selected ticket rate.

2. **Jackpot Pool Share**  
   A percentage of the current jackpot pool distributed to the player.

## Example Outcomes

- **Top Jackpot Outcome `{8,4,0}`**  
  - Pays a high multiple of the ticket fee  
  - Distributes nearly the entire jackpot pool  
  - Represents the rarest and most valuable outcome

- **Mid-Tier Winning Outcomes (e.g. `{8,3,1}`, `{7,5,0}`)**  
  - Provide meaningful ticket multipliers  
  - Distribute a portion of the jackpot pool

- **Low-Tier Outcomes (e.g. `{6,4,2}`, `{4,4,4}`)**  
  - Return the ticket fee with a small bonus  
  - Do not affect the jackpot pool

- **Losing Outcome `{5,4,3}`**  
  - Pays no reward  
  - Contributes a portion of the ticket fee to the jackpot pool

## Jackpot Contribution

- When a player receives no payout, **1% of the ticket fee** is added to the jackpot pool.
- The jackpot pool grows organically through gameplay and can only be reduced
  through predefined reward rules.

## Rule Enforcement

All reward rules are enforced entirely on-chain:

- All game rules and parameters are defined and enforced by on-chain smart contracts,
  and any changes must go through transparent, on-chain governance processes.
- There are no discretionary or manual payouts. All rewards and jackpot distributions
  are executed strictly according to publicly verifiable contract logic.
- No individual or entity, including the project team, can influence or manipulate
  the outcome of any game round once it has started.

This guarantees that every player is treated equally under the same transparent rules.
