# **STAY Protocol**

**Neutral Settlement Rail for Decentralized Accommodation**

---

## Legal Disclaimer

This repository contains **general-purpose, open-source smart contracts** implementing the STAY Protocol.

The authors and contributors:

* do **not** operate an accommodation service, booking platform, marketplace, or rental business
* do **not** list, curate, rank, promote, or advertise properties
* do **not** verify hosts, guests, properties, identities, ownership, zoning, safety, or compliance
* do **not** provide legal, financial, tax, regulatory, or consumer-protection advice
* do **not** arbitrate disputes, enforce policies, or intervene in settlements
* are **not responsible** for deployments, integrations, bookings, stays, disputes, or real-world outcomes

All deployments and integrations of STAY Protocol are performed **entirely at the risk of the deployer and the integrating application**.

This software is provided **as-is**, without warranty of any kind, express or implied.
The authors are **not liable** for any damages, losses, claims, or liabilities arising from the use, misuse, or failure of this software or any derivative work.

By using, deploying, or interacting with STAY Protocol in any form, you accept full responsibility for compliance, operation, and outcomes.

---

## Protocol Finality and Immutability

**STAY Protocol is finished infrastructure.**

The contracts in this repository are intentionally minimal, deterministic, and **final**.

* No upgrade mechanism
* No governance
* No admin keys
* No pause switches
* No emergency intervention
* No dispute resolution

Once deployed, **the protocol does not require and does not accept human involvement**.

Its behavior is defined **exclusively** by the deployed bytecode and Ethereum consensus.

All innovation, UX, compliance handling, arbitration, reputation systems, insurance, customer support, and market behavior must occur **off-chain or on top of the protocol**, without modifying it.

---

## STAY Protocol Overview

**STAY Protocol** is a neutral, production-ready settlement rail for peer-to-peer accommodation and lodging use cases.

It enables trust-minimized settlement for short-term stays without relying on centralized platforms, custodians, or intermediaries.

**Lifecycle**

Offer -> Booking -> Stay -> Settlement

STAY is **platform-agnostic**, **custody-agnostic**, and **identity-agnostic**.

This repository contains **only immutable smart contracts and deployment scripts**.
It intentionally excludes applications, UIs, APIs, search engines, ranking systems, compliance tooling, or dispute processes.

---

## Immutable Protocol Invariants

The following rules are **hard-coded and permanent**:

### **Protocol Fee**

* **0.5% (50 basis points)**
* Immutable
* Non-configurable
* Automatically paid to the protocol treasury on settlement

### **Auto-Release**

* **12 days** after booking
* Permissionless
* Cannot be extended, paused, or overridden

If no mutual settlement is submitted within 12 days, **anyone** may trigger auto-release.

Time is the only arbitrator.

---

## Ethereum Deployment

**Official Canonical deployment addresses:**

- StayCore: 0x09B9349232CeDB36A9e0efAEa06b5Fda7C49A82a
- PropertyRegistry: 0x24355ae449E6F189884679AF653211549C19d95F
- Escrow: 0x69Cf51FF2389a5af38017eC5B19180c8587B081a
- PROTOCOL_TREASURY: 0x5496cEB0b6468f6F7D5DB2Cf45883BEb92B25D9D

The canonical deployment enforces:

* Immutable **0.5% protocol fee**
* Immutable **12-day auto-release**
* No admin privileges
* No upgrade paths

---

## Repository Structure

```
.
├── contracts
│   ├── Escrow.sol           # Immutable escrow bound to StayCore
│   ├── PropertyRegistry.sol # ERC-721 integrity anchor
│   └── StayCore.sol         # Settlement state machine
├── foundry.toml
├── README.md
└── script
    └── DeployProtocol.s.sol
```

---

## Core Components

### **1. StayCore — Settlement Engine**

* Deterministic stay lifecycle
* Peer-to-peer booking
* Dual-signature settlement (EIP-712)
* Immutable 0.5% protocol fee
* Optional platform fee defined off-chain
* Permissionless settlement submission
* Automatic settlement after 12 days

StayCore has **no owner**, **no governance**, and **no intervention hooks**.

---

### **2. Escrow — Value Custody**

* Holds booking funds during the stay
* Separate ledgers for price and deposit
* Releases funds only via StayCore
* Permanently bound to StayCore at deployment
* Cannot be repointed, upgraded, or controlled

Escrow is a mechanical ledger, not a decision-maker.

---

### **3. PropertyRegistry — Integrity Anchor**

* ERC-721 registry for accommodation units
* Stores only hashes and optional metadata URIs
* No personal data
* No location data required
* No administrative controls

The NFT **does not represent real-estate ownership**.
It only anchors settlement authority for a specific unit.

---

## Settlement Model

### Mutual Settlement

Settlement occurs when **both host and guest sign the same settlement intent**.

The protocol does not evaluate correctness, damages, or fairness.
It only executes the agreement both parties cryptographically approved.

Anyone may submit the signed settlement transaction.

---

### Auto-Release

If no settlement is submitted within **12 days** of booking:

* Price is released to the host (minus fees)
* Deposit is refunded to the guest
* Anyone may trigger the transaction

Funds **cannot be frozen** indefinitely.

---

## Disputes

STAY Protocol **does not arbitrate disputes**.

If a dispute exists, it must be resolved **off-chain**.

The protocol will not:

* Collect evidence
* Assess damages
* Determine fault
* Override signatures
* Delay settlement beyond the auto-release window

---

## NFT as Infrastructure (Not Speculation)

STAY uses NFTs as **non-speculative infrastructure primitives**.

An NFT serves as:

* A globally unique authority anchor
* A transferable control surface
* A deterministic reference point

It does **not** represent:

* Property ownership
* Legal title
* Regulatory compliance
* Investment rights

---

## Centralized Platforms vs STAY

| Function        | Centralized Platforms | STAY Protocol |
| --------------- | --------------------- | -------------- |
| Custody         | Platform-controlled   | Trustless      |
| Fees            | Mutable               | Immutable      |
| Arbitration     | Platform-imposed      | None           |
| Listings        | Curated               | Off-chain      |
| Identity        | Mandatory             | Optional       |
| Governance      | Centralized           | None           |
| Data extraction | Yes                   | No             |
| Market control  | High                  | Neutral        |

---

## Security Model

* No admin settlement powers
* No upgrade paths
* No freeze switches
* No emergency roles
* Escrow permanently bound to core
* Protocol fee enforced by code
* Settlement enforced by signatures or time

---

## Philosophy

STAY Protocol is:

* Minimal
* Permissionless
* Neutral
* Non-extractive

It does not compete with platforms.
It removes their necessity.

Once deployed, **STAY does not need its author, maintainers, or any organization**.

It exists as infrastructure.

---

## Contact

[pablo-chacon-ai@proton.me](mailto:pablo-chacon-ai@proton.me)

---
