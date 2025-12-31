
---

# **DeBNB Protocol Whitepaper**

**Neutral Settlement Infrastructure for Decentralized Accommodation**

---

## Abstract

DeBNB Protocol is a minimal, immutable settlement rail for peer-to-peer accommodation.
It provides trustless escrow, deterministic settlement, and time-bounded fund release without operating a platform, enforcing policies, or mediating disputes.

DeBNB is not a marketplace, not a booking service, and not a governance system.
It is infrastructure.

Once deployed, DeBNB requires no operators, administrators, or maintainers.
Its behavior is fully defined by immutable smart contracts and Ethereum consensus.

---

## 1. Motivation

Centralized accommodation platforms combine multiple roles into a single authority:

* Custody of user funds
* Control over listings and visibility
* Mutable fee structures
* Arbitration and dispute enforcement
* Data extraction and behavioral control

This architecture creates systemic risks:

* Funds can be frozen or seized
* Rules can change retroactively
* Participants are locked into platform governance
* Market power concentrates over time

DeBNB separates **settlement** from **platform behavior**.

By removing discretion, governance, and identity from the protocol layer, DeBNB enables open competition, voluntary coordination, and credible exit.

---

## 2. Design Principles

DeBNB is built on five non-negotiable principles:

1. **Neutrality**
   The protocol does not prefer, rank, or control participants.

2. **Finality**
   The protocol is finished infrastructure with no upgrade path.

3. **Determinism**
   Outcomes are derived solely from signatures, time, and math.

4. **Permissionlessness**
   Anyone may integrate, submit settlements, or trigger auto-release.

5. **Non-Extractive Economics**
   The protocol enforces a single, immutable fee and nothing more.

---

## 3. Scope and Non-Goals

### In Scope

* Trustless escrow for stay payments
* Deterministic settlement logic
* Time-bounded fund release
* Cryptographic authorization via signatures

### Explicitly Out of Scope

* Listings, search, or discovery
* Identity, KYC, or reputation
* Compliance, taxation, or regulation
* Dispute resolution or arbitration
* Insurance, guarantees, or consumer protection
* UX, APIs, or platform governance

All such concerns must be handled **off-chain** or **above** the protocol.

---

## 4. System Overview

DeBNB consists of three immutable on-chain components:

### 4.1 StayCore

The settlement state machine governing:

* Booking lifecycle
* Signature-based settlement
* Fee enforcement
* Auto-release timing

StayCore has no owner, no admin keys, and no governance logic.

---

### 4.2 Escrow

A value-holding contract that:

* Holds funds during a stay
* Separates price and deposit ledgers
* Releases funds only when instructed by StayCore

Escrow is permanently bound to StayCore at deployment and cannot be repointed.

---

### 4.3 PropertyRegistry

An ERC-721 registry used as an integrity anchor:

* Represents a unique accommodation unit
* Stores only hashes and optional metadata pointers
* Contains no personal or location data

The NFT does not represent real-estate ownership or legal title.

---

## 5. Settlement Model

### 5.1 Mutual Settlement

Settlement occurs when **both host and guest sign the same settlement intent**.

* The protocol verifies signatures (EIP-712)
* Fees are enforced mechanically
* Anyone may submit the transaction

The protocol does not judge correctness or fairness.

---

### 5.2 Auto-Release

If no mutual settlement is submitted within **12 days of booking**:

* Settlement becomes permissionless
* Price is released to the host (minus fees)
* Deposit is refunded to the guest

Time is the only arbitrator.

Funds cannot be frozen indefinitely.

---

## 6. Economic Model

### 6.1 Protocol Fee

* **0.5% (50 basis points)**
* Hard-coded and immutable
* Paid automatically to the protocol treasury

The fee cannot be changed, removed, or bypassed.

---

### 6.2 Platform Fees

Platforms may define additional fees **off-chain** and include them in settlement intents.

The protocol does not enforce business models, pricing strategies, or revenue distribution beyond the immutable protocol fee.

---

## 7. Security Model

DeBNB intentionally minimizes attack surface:

* No admin roles
* No upgrade hooks
* No pause or emergency controls
* No arbitration branches
* No discretionary logic

Security derives from:

* Ethereum consensus
* Cryptographic signatures
* Deterministic execution
* Bounded time-based release

---

## 8. Trust Model

Participants trust:

* The deployed bytecode
* Ethereum liveness and finality
* Their own signatures

They do **not** trust:

* Platforms
* Operators
* Arbitrators
* The protocol author

Once deployed, DeBNB does not require trust in any human actor.

---

## 9. Long-Term and Non-Standard Use Cases

DeBNB is optimized for short-term accommodation.

Long-term rentals, subscriptions, or complex payment schedules can be implemented **off-chain** by:

* Fronting funds to platform wallets
* Streaming payments externally
* Re-entering the protocol periodically

The protocol remains unchanged.

---

## 10. Comparison to Centralized Platforms

| Dimension        | Centralized Platforms | DeBNB Protocol |
| ---------------- | --------------------- | -------------- |
| Custody          | Platform-controlled   | Trustless      |
| Fees             | Mutable               | Immutable      |
| Governance       | Centralized           | None           |
| Arbitration      | Mandatory             | None           |
| Identity         | Required              | Optional       |
| Data extraction  | Yes                   | No             |
| Exit possibility | Low                   | Always         |

---

## 11. Finality Statement

DeBNB Protocol is **finished infrastructure**.

It will not be upgraded, governed, or extended.

The protocol does not evolve.
Ecosystems around it may.

---

## 12. Conclusion

DeBNB provides a credible alternative to centralized accommodation platforms by removing discretion, custody, and governance from the settlement layer.

It does not promise fairness, safety, or convenience.

It promises **determinism, neutrality, and exit**.

---

**DeBNB Protocol**
Neutral settlement, enforced by code.

---

