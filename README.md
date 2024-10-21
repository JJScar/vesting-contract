# Time-Unlocked ERC20 Vesting Contract

This project implements a smart contract for time-based vesting of ERC20 tokens. It allows a payer to deposit tokens into the contract, which are then gradually unlocked for withdrawal by a designated receiver over a specified period.

## Features

- Single payer deposits ERC20 tokens
- Tokens are unlocked linearly over a specified number of days
- Receiver can withdraw unlocked tokens daily
- Immutable vesting schedule once deposit is made
- Prevents over-withdrawal of tokens

## Getting Started

### Prerequisites

- Solidity 0.8.25
- OpenZeppelin Contracts library
- Foundry

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/erc20-vesting-contract.git
   ```

2. Install dependencies:
   ```
   forge build
   ```

## Usage

1. Deploy the VestingContract to your chosen network.
2. Call the `deposit` function as the payer to initiate the vesting schedule.
3. The receiver can call `withdraw` function to claim unlocked tokens.

## Testing

Run the test suite:

```
forge test
```

## Security Considerations

- The contract has been designed with security best practices in mind.
- Follow CEI (Checks-Effects-Interactions) pattern to prevent reentrancy.
- Careful consideration has been given to prevent precision loss in calculations.
- Proper checks are implemented for amounts and time-based conditions.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Disclaimer

This smart contract is provided as-is. Users should conduct their own security audit before using it in a production environment.

# Contact 
- [X](https://x.com/JJS_OnChain)
- [LinkedIn](https://www.linkedin.com/in/jordan-solomon-b735b8165/)
- [Email](jjsonchain@gmail.com)