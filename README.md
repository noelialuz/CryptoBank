# 🏦 CryptoBank

[![Solidity](https://img.shields.io/badge/Solidity-^0.8.24-363636?logo=solidity&logoColor=white)](https://soliditylang.org/)
[![License](https://img.shields.io/badge/License-LGPL--3.0--only-blue.svg)](LICENSE)
[![EVM](https://img.shields.io/badge/EVM-Compatible-3C3C3D?logo=ethereum)](https://ethereum.org/)

> A minimal, multi-user on-chain bank where users deposit and withdraw native ETH under a configurable balance cap, with internal transfers and restricted balance reads.

---

## 📋 Table of Contents

- [About](#-about)
- [Features](#-features)
- [Technologies](#-technologies)
- [Contract Overview](#-contract-overview)
- [Getting Started](#-getting-started)
- [Prerequisites](./PREREQUISITES.md)
- [Testing the Contract](#-testing-the-contract)
- [Versioning](#-versioning)
- [Security Notes](#-security-notes)
- [License](#-license)
- [Author](#-author)

---

## 📖 About

**CryptoBank** is an educational Solidity smart contract that simulates a simple crypto bank on the Ethereum Virtual Machine (EVM). Multiple users can deposit native **ETH**, withdraw only what they previously deposited, transfer part of their balance to another user, and stay within a **maximum balance per user** enforced by the contract.

The **admin** can update the max balance cap and query any user’s balance. Regular users can only read their own balance through dedicated view functions — the `userBalances` mapping is **private**, so there is no public auto-getter for arbitrary addresses.

This project is part of an intermediate Solidity learning path and practices **access control**, **`require` validations**, **private state + controlled getters**, and the **Checks-Effects-Interactions (CEI)** pattern on withdrawals.

---

## ✨ Features

| Feature | Description |
|--------|-------------|
| 👥 Multi-user | Each address has its own balance in a private `userBalances` mapping |
| 💰 ETH deposits | `depositEther()` accepts payable calls |
| 🔐 Self-custody withdrawals | Users can only withdraw their own deposited ETH (CEI) |
| 🤝 Internal transfer | `depositFor()` moves balance from caller to another user |
| 📊 Balance cap | Per-user balance cannot exceed `maxBalance` (example: 5 ETH) |
| 🛡️ Admin controls | Only `admin` can call `modifyMaxBalance()` and `getUserBalance()` |
| 👁️ Private balances | Users call `getMyBalance()`; admin uses `getUserBalance(address)` |
| 📣 Events | `EtherDeposit`, `EtherWithdraw`, `EtherDepositFor` |

---

## 🛠 Technologies

| Technology | Role |
|------------|------|
| **Solidity** `^0.8.24` | Smart contract language |
| **EVM** | Execution environment (Ethereum-compatible chains) |
| **Remix IDE** | Compile, deploy, and interact (recommended for this repo) |
| **Git / GitHub** | Version control and hosting |
| **SPDX** `LGPL-3.0-only` | License identifier in source |

Optional tooling you can add later:

- **Foundry** (`forge test`, `cast`) for local tests and scripting  
- **Hardhat** for Node.js-based testing and deployment  

---

## 📜 Contract Overview

### State

| Variable | Visibility | Type | Description |
|----------|------------|------|-------------|
| `maxBalance` | `public` | `uint256` | Max ETH a single user may hold in the bank |
| `admin` | `public` | `address` | Address allowed to change `maxBalance` and read any balance |
| `userBalances` | `private` | `mapping(address => uint256)` | ETH credited per user (no public getter) |

### Write functions

| Function | Access | Description |
|----------|--------|-------------|
| `depositEther()` | `external payable` | Adds `msg.value` to caller balance if under cap |
| `withdrawEther(uint256 amount_)` | `external` | Withdraws ETH to caller using CEI |
| `depositFor(address receiver_, uint256 amount_)` | `external payable` | Moves `amount_` from caller’s bank balance to `receiver_` |
| `modifyMaxBalance(uint256 newMaxBalance_)` | `onlyAdmin` | Updates the per-user balance cap |

### View functions

| Function | Access | Description |
|----------|--------|-------------|
| `getMyBalance()` | any user | Returns `userBalances[msg.sender]` |
| `getUserBalance(address user_)` | `onlyAdmin` | Returns balance of any `user_` |

### Events

```solidity
event EtherDeposit(address user_, uint256 etherAmount_);
event EtherWithdraw(address user_, uint256 etherAmount_);
event EtherDepositFor(address sender_, address receiver_, uint256 etherAmount_);
```

### `depositFor` rules

- Caller and receiver must be different (`"You cannot deposit for yourself"`).
- `amount_` must be greater than zero.
- Caller must have at least `amount_` in their bank balance.
- Receiver’s new balance must not exceed `maxBalance`.

---

## 🚀 Getting Started

### Prerequisites

See **[PREREQUISITES.md](./PREREQUISITES.md)** for the full checklist: knowledge, software, wallets, testnet ETH, Remix/Foundry/Hardhat setup, and pre-flight verification.

**Quick minimum:** modern browser + [Remix IDE](https://remix.ethereum.org/) + Solidity compiler **0.8.24**.

### Deploy (Remix)

1. Open [Remix](https://remix.ethereum.org/) and import `CryptoBank.sol`.
2. Compile with Solidity **0.8.24** (or compatible `^0.8.24`).
3. In **Deploy & Run**:
   - **Contract:** `CryptoBank`
   - **Constructor args:**
     - `maxBalance_`: e.g. `5000000000000000000` (5 ETH in wei)
     - `_admin`: your wallet address (or Remix account #0)
4. Deploy and copy the contract address.

---

## 🧪 Testing the Contract

Use **Account 0** as admin and **Account 1** / **Account 2** as users in Remix.

> **Note:** `userBalances` is private. Use `getMyBalance()` or `getUserBalance(address)` — do not look for a public `userBalances` button in Remix.

### 1. Deposit ETH (`depositEther`)

| Step | Action |
|------|--------|
| 1 | Select **Account 1** |
| 2 | Set **Value** to `1 ether` |
| 3 | Call `depositEther()` |
| 4 | Call `getMyBalance()` → should return `1000000000000000000` |

Repeat until `maxBalance`; next deposit should revert with `"Max balance reached"`.

### 2. Withdraw ETH (`withdrawEther`)

| Step | Action |
|------|--------|
| 1 | Stay on **Account 1** |
| 2 | Call `withdrawEther` with `amount_` = `500000000000000000` (0.5 ETH) |
| 3 | Call `getMyBalance()` → balance should decrease |
| 4 | Account 1 wallet ETH should increase |

Withdrawing more than balance → `"Not enough ether"`.

### 3. Transfer balance to another user (`depositFor`)

| Step | Action |
|------|--------|
| 1 | **Account 1** deposits e.g. `2 ether` via `depositEther()` |
| 2 | **Account 1** calls `depositFor(Account2Address, 1000000000000000000)` (1 ETH) |
| 3 | **Account 1** → `getMyBalance()` → `1000000000000000000` |
| 4 | Switch to **Account 0** (admin) → `getUserBalance(Account2Address)` → `1000000000000000000` |

Edge cases to try:

- Same sender and receiver → `"You cannot deposit for yourself"`
- `amount_` greater than sender balance → `"Not enough ether"`
- Transfer that would exceed receiver `maxBalance` → `"Max balance reached"`

### 4. Read balances (access control)

| Caller | Function | Result |
|--------|----------|--------|
| Any user | `getMyBalance()` | Own balance only |
| Admin | `getUserBalance(anyAddress)` | Any user’s balance |
| Non-admin | `getUserBalance(other)` | Reverts `"Not allowed"` |

### 5. Admin — change cap (`modifyMaxBalance`)

| Step | Action |
|------|--------|
| 1 | **Account 0** (admin) |
| 2 | `modifyMaxBalance(10000000000000000000)` (10 ETH) |
| 3 | `maxBalance()` → updated value |

Non-admin call → `"Not allowed"`.

### 6. Events

Confirm in Remix **Transactions**:

- `EtherDeposit` on `depositEther`
- `EtherWithdraw` on `withdrawEther`
- `EtherDepositFor` on `depositFor`

---

### Option B — Foundry `cast` (CLI, after deploy)

```bash
# Deposit 1 ETH
cast send 0xYourContractAddress "depositEther()" --value 1ether --private-key $USER_PK

# Read own balance
cast call 0xYourContractAddress "getMyBalance()(uint256)" --from $USER_ADDRESS

# Admin: read any user balance
cast call 0xYourContractAddress "getUserBalance(address)(uint256)" 0xUserAddress --from $ADMIN_ADDRESS

# Withdraw 0.5 ETH
cast send 0xYourContractAddress "withdrawEther(uint256)" 500000000000000000 --private-key $USER_PK

# Internal transfer 0.25 ETH to another user
cast send 0xYourContractAddress "depositFor(address,uint256)" 0xReceiverAddress 250000000000000000 --private-key $USER_PK

# Admin: set max balance to 10 ETH
cast send 0xYourContractAddress "modifyMaxBalance(uint256)" 10000000000000000000 --private-key $ADMIN_PK
```

---

### Option C — Example Foundry test (snippet)

```solidity
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../CryptoBank.sol";

contract CryptoBankTest is Test {
    CryptoBank bank;
    address admin = address(0xA11CE);
    address user = address(0xB0B);
    address user2 = address(0xC0C);

    function setUp() public {
        bank = new CryptoBank(5 ether, admin);
        vm.deal(user, 10 ether);
        vm.deal(user2, 1 ether);
    }

    function test_DepositWithdrawAndGetBalance() public {
        vm.prank(user);
        bank.depositEther{value: 2 ether}();
        assertEq(bank.getMyBalance(), 2 ether);

        vm.prank(user);
        bank.withdrawEther(1 ether);
        assertEq(bank.getMyBalance(), 1 ether);
    }

    function test_DepositFor() public {
        vm.prank(user);
        bank.depositEther{value: 2 ether}();

        vm.prank(user);
        bank.depositFor(user2, 1 ether);

        assertEq(bank.getMyBalance(), 1 ether);
        assertEq(bank.getUserBalance(user2), 1 ether);
    }

    function test_OnlyAdminCanReadOtherBalance() public {
        vm.prank(user);
        bank.depositEther{value: 1 ether}();

        vm.prank(admin);
        assertEq(bank.getUserBalance(user), 1 ether);

        vm.expectRevert("Not allowed");
        vm.prank(user2);
        bank.getUserBalance(user);
    }
}
```

Run with: `forge test -vv`

---

## 📌 Versioning

This project follows **[Semantic Versioning 2.0.0](https://semver.org/)**:

| Segment | Meaning |
|---------|---------|
| **MAJOR** | Breaking changes to contract interface or behavior |
| **MINOR** | New features, backward-compatible |
| **PATCH** | Bug fixes, docs, no breaking API changes |

### Release history

| Version | Status | Notes |
|---------|--------|-------|
| **0.2.0** | Current | `depositFor`, private `userBalances`, `getMyBalance`, `getUserBalance`, `EtherDepositFor` |
| **0.1.0** | — | Initial release: deposit, withdraw, admin cap, CEI on withdraw |

Tag releases on GitHub:

```bash
git tag -a v0.2.0 -m "Add depositFor and restricted balance getters"
git push origin v0.2.0
```

---

## 🔒 Security Notes

> ⚠️ This contract is for **learning purposes**. Do not use it in production without a professional audit.

- Withdrawals use **CEI** (check → update mapping → `call` transfer).
- `userBalances` is **private**, but on-chain data can still be read by advanced tools; getters enforce contract-level access only.
- `depositFor` moves internal balances; review `payable` and ETH `call` behavior before mainnet use.
- No `ReentrancyGuard` beyond CEI; consider OpenZeppelin guards for production.
- Admin is a single EOA; use multisig or timelock for real deployments.
- Always test on a **testnet** or Remix VM before mainnet.

---

## 📄 License

This project is licensed under **GNU Lesser General Public License v3.0 only** — see the SPDX header in `CryptoBank.sol`.

---

## 👩‍💻 Author

**Noelia Luz** ([@noelialuz](https://github.com/noelialuz))

- 🌐 GitHub: [github.com/noelialuz](https://github.com/noelialuz)
- 📚 Focus: Solidity & EVM smart contract development  
- 🏗️ Building intermediate-level DeFi-style primitives (banks, tokens, access control)

Contributions, issues, and feedback are welcome. If you use or learn from this repo, a ⭐ on GitHub is appreciated!

---

<p align="center">Made with 💜 and Solidity</p>
