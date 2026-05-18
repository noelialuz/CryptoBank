# 🏦 CryptoBank

[![Solidity](https://img.shields.io/badge/Solidity-^0.8.24-363636?logo=solidity&logoColor=white)](https://soliditylang.org/)
[![License](https://img.shields.io/badge/License-LGPL--3.0--only-blue.svg)](LICENSE)
[![EVM](https://img.shields.io/badge/EVM-Compatible-3C3C3D?logo=ethereum)](https://ethereum.org/)

> A minimal, multi-user on-chain bank where users deposit and withdraw native ETH under a configurable balance cap.

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

**CryptoBank** is an educational Solidity smart contract that simulates a simple crypto bank on the Ethereum Virtual Machine (EVM). Multiple users can deposit native **ETH**, withdraw only what they previously deposited, and stay within a global **maximum balance per user** enforced by the contract.

The **admin** can update the max balance cap. Deposits and withdrawals emit events for easy indexing and debugging.

This project is part of an intermediate Solidity learning path and is designed to practice core patterns such as **access control**, **custom errors via `require`**, and the **Checks-Effects-Interactions (CEI)** pattern on withdrawals.

---

## ✨ Features

| Feature | Description |
|--------|-------------|
| 👥 Multi-user | Each address has its own balance in `userBalances` |
| 💰 ETH deposits | `depositEther()` accepts payable calls |
| 🔐 Self-custody withdrawals | Users can only withdraw their own deposited ETH |
| 📊 Balance cap | Per-user deposits cannot exceed `maxBalance` (default example: 5 ETH) |
| 🛡️ Admin controls | Only `admin` can call `modifyMaxBalance()` |
| 📣 Events | `EtherDeposit` and `EtherWithdraw` for off-chain tracking |

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

| Variable | Type | Description |
|----------|------|-------------|
| `maxBalance` | `uint256` | Max ETH a single user may hold in the bank |
| `admin` | `address` | Address allowed to change `maxBalance` |
| `userBalances` | `mapping(address => uint256)` | ETH credited per user |

### Functions

| Function | Access | Description |
|----------|--------|-------------|
| `depositEther()` | `external payable` | Adds `msg.value` to caller balance if under cap |
| `withdrawEther(uint256 amount_)` | `external` | Withdraws ETH using CEI pattern |
| `modifyMaxBalance(uint256 newMaxBalance_)` | `onlyAdmin` | Updates the per-user deposit cap |

### Events

```solidity
event EtherDeposit(address user_, uint256 etherAmount_);
event EtherWithdraw(address user_, uint256 etherAmount_);
```

---

## 🚀 Getting Started

### Prerequisites

See **[PREREQUISITES.md](./PREREQUISITES.md)** for the full checklist: knowledge, software, wallets, testnet ETH, Remix/Foundry/Hardhat setup, and pre-flight verification.

**Quick minimum:** modern browser + [Remix IDE](https://remix.ethereum.org/) + Solidity compiler **0.8.24**.

### Deploy (Remix)

1. Open [Remix](https://remix.ethereum.org/) and create/import this repo’s `CryptoBank.sol`.
2. Compile with Solidity **0.8.24** (or compatible `^0.8.24`).
3. In **Deploy & Run**:
   - **Contract:** `CryptoBank`
   - **Constructor args:**
     - `maxBalance_`: e.g. `5000000000000000000` (5 ETH in wei)
     - `_admin`: your wallet address (or Remix account #0)
4. Deploy and copy the contract address.

---

## 🧪 Testing the Contract

Below are practical ways to verify each “service” (function) without a full test suite in the repo.

### Option A — Remix (interactive)

Use two accounts in Remix: **Account 0** (admin) and **Account 1** (user).

#### 1. Deposit ETH (`depositEther`)

| Step | Action |
|------|--------|
| 1 | Select **Account 1** |
| 2 | Set **Value** to `1 ether` |
| 3 | Call `depositEther()` |
| 4 | Read `userBalances(<Account1Address>)` → should be `1000000000000000000` |

Repeat until total reaches `maxBalance`; next deposit should revert with `"Max balance reached"`.

#### 2. Withdraw ETH (`withdrawEther`)

| Step | Action |
|------|--------|
| 1 | Stay on **Account 1** |
| 2 | Call `withdrawEther` with `amount_` = `500000000000000000` (0.5 ETH) |
| 3 | Confirm balance mapping decreased and Account 1 ETH balance increased |

Try withdrawing more than deposited → expect `"Not enough ether"`.

#### 3. Admin — change cap (`modifyMaxBalance`)

| Step | Action |
|------|--------|
| 1 | Switch to **Account 0** (admin) |
| 2 | Call `modifyMaxBalance(10000000000000000000)` (10 ETH) |
| 3 | Read `maxBalance()` → should update |

Call from a non-admin account → expect `"Not allowed"`.

#### 4. Listen to events

In Remix **Transactions** or block explorer, confirm:

- `EtherDeposit(user, amount)` on deposit  
- `EtherWithdraw(user, amount)` on withdraw  

---

### Option B — Foundry `cast` (CLI, after deploy)

Replace placeholders with your RPC, keys, and contract address.

```bash
# Deposit 1 ETH
cast send 0xYourContractAddress "depositEther()" --value 1ether --private-key $USER_PK

# Check balance
cast call 0xYourContractAddress "userBalances(address)(uint256)" 0xUserAddress

# Withdraw 0.5 ETH
cast send 0xYourContractAddress "withdrawEther(uint256)" 500000000000000000 --private-key $USER_PK

# Admin: set max balance to 10 ETH
cast send 0xYourContractAddress "modifyMaxBalance(uint256)" 10000000000000000000 --private-key $ADMIN_PK
```

---

### Option C — Example Foundry test (snippet)

You can add `test/CryptoBank.t.sol` later. Minimal flow:

```solidity
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../CryptoBank.sol";

contract CryptoBankTest is Test {
    CryptoBank bank;
    address admin = address(0xA11CE);
    address user = address(0xB0B);

    function setUp() public {
        bank = new CryptoBank(5 ether, admin);
        vm.deal(user, 10 ether);
    }

    function test_DepositAndWithdraw() public {
        vm.prank(user);
        bank.depositEther{value: 2 ether}();
        assertEq(bank.userBalances(user), 2 ether);

        vm.prank(user);
        bank.withdrawEther(1 ether);
        assertEq(bank.userBalances(user), 1 ether);
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
| **0.1.0** | Current | Initial release: deposit, withdraw, admin cap, CEI on withdraw |

Tag releases on GitHub when you ship changes:

```bash
git tag -a v0.1.0 -m "Initial CryptoBank release"
git push origin v0.1.0
```

---

## 🔒 Security Notes

> ⚠️ This contract is for **learning purposes**. Do not use it in production without a professional audit.

- Withdrawals use **CEI** (check balance → update mapping → `call` transfer).  
- No reentrancy guard beyond CEI; consider `ReentrancyGuard` for production.  
- Admin is a single EOA; consider multisig or timelock for real deployments.  
- Always test on a **testnet** before mainnet.

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
