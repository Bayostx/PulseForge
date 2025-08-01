# PulseForge
## Milestone-Powered Decentralized Crowdfunding with Multi-Token Support

PulseForge is an innovative decentralized crowdfunding protocol built on the Stacks blockchain where fund release is conditional on milestone achievements. Unlike traditional crowdfunding platforms, PulseForge ensures accountability through a milestone-based voting system that protects both creators and backers. **Now supports both STX and SIP-010 fungible tokens for maximum flexibility.**

## 🚀 Features

- **Milestone-Based Funding**: Campaign funds are released incrementally as creators complete predefined milestones
- **Multi-Token Support**: Support for both STX and approved SIP-010 fungible tokens
- **Democratic Voting System**: Backers vote to approve milestone completion before funds are released
- **Refundable Escrow**: Tokens are held in escrow and can be refunded if campaigns fail to deliver
- **Transparent Progress Tracking**: Real-time visibility into campaign progress and milestone status
- **Creator Protection**: Anti-spam measures and proper validation ensure legitimate campaigns
- **Backer Protection**: Vote-based approval system prevents fund misuse
- **Token Registry**: Curated list of approved SIP-010 tokens for secure campaign creation

## 🏗️ Architecture

### Smart Contract Components

- **Campaign Management**: Create and manage crowdfunding campaigns with customizable parameters for STX or SIP-010 tokens
- **Token Registry**: Approved token system for SIP-010 fungible tokens
- **Milestone System**: Define time-based or deliverable milestones with voting requirements
- **Voting Mechanism**: Democratic approval system for milestone completion
- **Escrow System**: Secure token holding and conditional release for both STX and SIP-010 tokens
- **Refund System**: Automatic refund capability for failed campaigns

### Core Functions

#### Campaign Creation
- `create-stx-campaign`: Launch a new STX crowdfunding campaign
- `create-token-campaign`: Launch a new SIP-010 token crowdfunding campaign
- `add-milestone`: Define milestones with specific voting requirements

#### Token Management
- `approve-token`: Approve SIP-010 tokens for platform use (owner only)
- `remove-token-approval`: Remove token approval (owner only)

#### Campaign Participation
- `back-stx-campaign`: Contribute STX tokens to support a campaign
- `back-token-campaign`: Contribute SIP-010 tokens to support a campaign
- `vote-milestone`: Vote on milestone completion as a campaign backer

#### Fund Release
- `release-stx-milestone-funds`: Release STX funds upon successful milestone approval
- `release-token-milestone-funds`: Release SIP-010 token funds upon successful milestone approval

#### Refunds
- `request-stx-refund`: Claim STX refunds for failed campaigns
- `request-token-refund`: Claim SIP-010 token refunds for failed campaigns

## 🛠️ Installation & Setup

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) v1.0+
- [Stacks CLI](https://docs.stacks.co/docs/command-line-interface)
- Node.js 16+ (for frontend development)

### Local Development

1. Clone the repository:
```bash
git clone https://github.com/your-username/pulseforge.git
cd pulseforge
```

2. Initialize Clarinet project:
```bash
clarinet check
```

3. Run tests:
```bash
clarinet test
```

## 📖 Usage

### Creating an STX Campaign

```clarity
(contract-call? .pulseforge create-stx-campaign 
  "My Innovation Project" 
  "Building the future of decentralized technology" 
  u1000000 ;; Target: 1000 STX
  u1440)   ;; Duration: ~10 days in blocks
```

### Creating a SIP-010 Token Campaign

```clarity
;; First, approve the token (owner only)
(contract-call? .pulseforge approve-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.some-token)

;; Then create the campaign
(contract-call? .pulseforge create-token-campaign 
  "DeFi Innovation Hub" 
  "Revolutionary DeFi platform development" 
  u500000000 ;; Target amount in token units
  u2160      ;; Duration: ~15 days in blocks
  'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.some-token)
```

### Adding Milestones

```clarity
(contract-call? .pulseforge add-milestone 
  u1 ;; campaign-id
  "Complete MVP development" 
  u720  ;; Target block (~5 days)
  u10)  ;; Required votes
```

### Backing Campaigns

#### STX Campaign
```clarity
(contract-call? .pulseforge back-stx-campaign u1 u100000) ;; 100 STX
```

#### SIP-010 Token Campaign
```clarity
(contract-call? .pulseforge back-token-campaign 
  u2 
  u1000000  ;; Amount in token units
  'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.some-token)
```

### Voting on Milestones

```clarity
(contract-call? .pulseforge vote-milestone u1 u1) ;; Vote on milestone 1 of campaign 1
```

### Releasing Funds

#### STX Milestone
```clarity
(contract-call? .pulseforge release-stx-milestone-funds u1 u1)
```

#### SIP-010 Token Milestone
```clarity
(contract-call? .pulseforge release-token-milestone-funds 
  u2 
  u1
  'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.some-token)
```

### Requesting Refunds

#### STX Refund
```clarity
(contract-call? .pulseforge request-stx-refund u1)
```

#### SIP-010 Token Refund
```clarity
(contract-call? .pulseforge request-token-refund 
  u2 
  'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.some-token)
```

## 🪙 Supported Tokens

### STX (Native)
- **Always supported**: STX is the native token of the Stacks blockchain
- **No approval needed**: STX campaigns can be created immediately

### SIP-010 Fungible Tokens
- **Approval required**: SIP-010 tokens must be approved by the contract owner before use
- **Security focused**: Only vetted tokens are approved to ensure campaign safety
- **Check approval status**: Use `is-token-approved` to verify token status

### Token Approval Process
1. Contract owner reviews token contract for security and legitimacy
2. Owner calls `approve-token` with the token contract principal
3. Token becomes available for campaign creation
4. Creators can now use the approved token for campaigns

## 🧪 Testing

The contract includes comprehensive error handling and validation:

- Parameter validation for all inputs
- Access control for campaign creators and contract owner
- Token type validation and approval checks
- Anti-spam measures for voting
- Proper escrow management for both STX and SIP-010 tokens
- Edge case handling for refunds
- Token transfer error handling

## 🔒 Security Features

- **Token Approval System**: Only pre-approved SIP-010 tokens can be used
- **Type Safety**: Clear separation between STX and SIP-010 token operations
- **Transfer Validation**: Comprehensive error handling for token transfers
- **Access Control**: Proper authorization checks for all sensitive operations
- **Anti-Spam Protection**: Voting and backing restrictions prevent abuse

## 🗺️ Roadmap

### Phase 1: Multi-Token Support ✅
- STX campaign support
- SIP-010 token integration
- Token approval registry
- Enhanced security measures

### Phase 2: Advanced Features
- **NFT Rewards**: Issue campaign-specific NFTs to backers
- **Tiered Backing**: Different contribution levels with varying rewards
- **Campaign Categories**: Organize campaigns by industry/type
- **Advanced Analytics**: Detailed campaign performance metrics

### Phase 3: Ecosystem Integration
- **Cross-chain Support**: Bridge to other blockchain networks
- **DeFi Integration**: Yield farming for escrowed funds
- **Governance Token**: Platform governance through native token
- **Mobile App**: Native mobile application for campaign management

### Phase 4: Enterprise Features
- **Batch Operations**: Handle multiple campaigns efficiently
- **API Gateway**: RESTful API for third-party integrations
- **White-label Solutions**: Customizable crowdfunding solutions
- **Advanced KYC/AML**: Enhanced compliance features

## 🤝 Contributing

We welcome contributions! Please read our contributing guidelines and submit pull requests for any improvements.

### Development Guidelines
- Follow Clarity best practices
- Include comprehensive tests for new features
- Update documentation for any changes
- Ensure `clarinet check` passes without warnings

## 🔗 Links

- [Stacks Documentation](https://docs.stacks.co/)
- [Clarity Language Reference](https://docs.stacks.co/docs/clarity/)
- [SIP-010 Token Standard](https://github.com/stacksgov/sips/blob/main/sips/sip-010/sip-010-fungible-token-standard.md)

---

**Built with ❤️ on Stacks**