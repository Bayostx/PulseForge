# PulseForge
## Milestone-Powered Decentralized Crowdfunding with Multi-Token Support

PulseForge is an innovative decentralized crowdfunding protocol built on the Stacks blockchain where fund release is conditional on milestone achievements. Unlike traditional crowdfunding platforms, PulseForge ensures accountability through a milestone-based voting system that protects both creators and backers. **Now supports both STX and SIP-010 fungible tokens for maximum flexibility, plus advanced milestone types with automated verification.**

## 🚀 Features

- **Milestone-Based Funding**: Campaign funds are released incrementally as creators complete predefined milestones
- **Multi-Token Support**: Support for both STX and approved SIP-010 fungible tokens
- **Advanced Milestone Types**: Multiple milestone verification methods including automated verification
- **Conditional Logic**: Smart milestones with dependencies and automated triggers
- **Democratic Voting System**: Backers vote to approve milestone completion before funds are released
- **Refundable Escrow**: Tokens are held in escrow and can be refunded if campaigns fail to deliver
- **Transparent Progress Tracking**: Real-time visibility into campaign progress and milestone status
- **Creator Protection**: Anti-spam measures and proper validation ensure legitimate campaigns
- **Backer Protection**: Vote-based approval system prevents fund misuse
- **Token Registry**: Curated list of approved SIP-010 tokens for secure campaign creation
- **Automated Verification**: Time-locked, funding-threshold, and conditional milestones

## 🎯 Milestone Types

### 1. Manual Milestones (`milestone-type-manual`)
- **Traditional voting-based**: Requires backer votes to approve completion
- **Creator flexibility**: Allows subjective milestone evaluation
- **Democratic oversight**: Community-driven approval process

### 2. Time-Locked Milestones (`milestone-type-time-locked`)
- **Automatic verification**: Triggers when target block height is reached
- **Deadline enforcement**: Ensures time-based deliverables
- **No voting required**: Streamlined release process

### 3. Funding Threshold Milestones (`milestone-type-funding-threshold`)
- **Goal-based triggers**: Activates when campaign reaches specified funding level
- **Incentive alignment**: Rewards successful fundraising milestones
- **Automatic release**: No manual intervention needed

### 4. Conditional Milestones (`milestone-type-conditional`)
- **Data-driven verification**: Based on external verification data set by creator
- **Flexible conditions**: Customizable success criteria
- **Transparent tracking**: Verification data stored on-chain

### 5. Multi-Dependency Milestones (`milestone-type-multi-dependency`)
- **Sequential execution**: Requires completion of prerequisite milestones
- **Complex workflows**: Enables sophisticated project planning
- **Dependency validation**: Automatic prerequisite checking

## 🏗️ Architecture

### Smart Contract Components

- **Campaign Management**: Create and manage crowdfunding campaigns with customizable parameters for STX or SIP-010 tokens
- **Token Registry**: Approved token system for SIP-010 fungible tokens
- **Advanced Milestone System**: Multiple milestone types with automated verification capabilities
- **Conditional Logic Engine**: Dependency checking and automated milestone verification
- **Voting Mechanism**: Democratic approval system for manual milestone completion
- **Escrow System**: Secure token holding and conditional release for both STX and SIP-010 tokens
- **Refund System**: Automatic refund capability for failed campaigns

### Core Functions

#### Campaign Creation
- `create-stx-campaign`: Launch a new STX crowdfunding campaign
- `create-token-campaign`: Launch a new SIP-010 token crowdfunding campaign
- `add-milestone`: Define basic manual milestones with voting requirements
- `add-advanced-milestone`: Create advanced milestones with specific types and conditions

#### Token Management
- `approve-token`: Approve SIP-010 tokens for platform use (owner only)
- `remove-token-approval`: Remove token approval (owner only)

#### Milestone Management
- `set-milestone-verification`: Set verification data for conditional milestones
- `vote-milestone`: Vote on milestone completion (with automatic verification checks)
- `can-milestone-auto-verify`: Check if milestone can be automatically verified
- `get-milestone-dependency-status`: View milestone dependency information

#### Campaign Participation
- `back-stx-campaign`: Contribute STX tokens to support a campaign
- `back-token-campaign`: Contribute SIP-010 tokens to support a campaign

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

### Adding Advanced Milestones

#### Manual Milestone (Traditional)
```clarity
(contract-call? .pulseforge add-milestone 
  u1 ;; campaign-id
  "Complete MVP development" 
  u720  ;; Target block (~5 days)
  u10)  ;; Required votes
```

#### Time-Locked Milestone
```clarity
(contract-call? .pulseforge add-advanced-milestone 
  u1    ;; campaign-id
  "Development phase 1 deadline"
  u1    ;; milestone-type-time-locked
  u1440 ;; Target block (~10 days)
  u5    ;; Required votes (backup)
  u0    ;; No condition value needed
  none) ;; No dependency
```

#### Funding Threshold Milestone
```clarity
(contract-call? .pulseforge add-advanced-milestone 
  u1        ;; campaign-id
  "Reach 50% funding goal"
  u2        ;; milestone-type-funding-threshold
  u720      ;; Target block
  u3        ;; Required votes (backup)
  u500000   ;; Condition: 500 STX threshold
  none)     ;; No dependency
```

#### Conditional Milestone
```clarity
(contract-call? .pulseforge add-advanced-milestone 
  u1    ;; campaign-id
  "Pass technical audit"
  u3    ;; milestone-type-conditional
  u1440 ;; Target block
  u7    ;; Required votes (backup)
  u100  ;; Condition: audit score >= 100
  none) ;; No dependency
```

#### Multi-Dependency Milestone
```clarity
(contract-call? .pulseforge add-advanced-milestone 
  u1       ;; campaign-id
  "Final release after testing"
  u4       ;; milestone-type-multi-dependency
  u2160    ;; Target block
  u5       ;; Required votes (backup)
  u0       ;; No condition value
  (some u1)) ;; Depends on milestone 1
```

### Setting Verification Data (Conditional Milestones)

```clarity
(contract-call? .pulseforge set-milestone-verification
  u1   ;; campaign-id
  u3   ;; milestone-id
  u95) ;; Verification data (e.g., audit score)
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

### Checking Milestone Status

```clarity
;; Check if milestone can be auto-verified
(contract-call? .pulseforge can-milestone-auto-verify u1 u1)

;; Check milestone dependency status
(contract-call? .pulseforge get-milestone-dependency-status u1 u2)
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
- Advanced milestone type validation
- Dependency checking for milestone prerequisites
- Automated verification logic testing
- Anti-spam measures for voting
- Proper escrow management for both STX and SIP-010 tokens
- Edge case handling for refunds
- Token transfer error handling

## 🔒 Security Features

- **Token Approval System**: Only pre-approved SIP-010 tokens can be used
- **Type Safety**: Clear separation between STX and SIP-010 token operations
- **Advanced Milestone Validation**: Comprehensive checks for milestone types and conditions
- **Dependency Verification**: Automatic validation of milestone prerequisites
- **Transfer Validation**: Comprehensive error handling for token transfers
- **Access Control**: Proper authorization checks for all sensitive operations
- **Anti-Spam Protection**: Voting and backing restrictions prevent abuse
- **Input Validation**: Thorough parameter checking to prevent invalid states

## 🗺️ Roadmap

### Phase 1: Multi-Token Support ✅
- STX campaign support
- SIP-010 token integration
- Token approval registry
- Enhanced security measures

### Phase 2: Advanced Features ✅
- **Advanced Milestone Types**: Time-locked, funding-threshold, conditional, and dependency-based milestones
- **Automated Verification**: Smart contract-based milestone verification
- **Conditional Logic**: Complex milestone dependencies and triggers
- **Enhanced Analytics**: Detailed milestone tracking and verification data

### Phase 3: Ecosystem Integration
- **NFT Rewards**: Issue campaign-specific NFTs to backers
- **Tiered Backing**: Different contribution levels with varying rewards
- **Campaign Categories**: Organize campaigns by industry/type
- **Advanced Analytics Dashboard**: Real-time campaign performance metrics

### Phase 4: Enterprise Features
- **Cross-chain Support**: Bridge to other blockchain networks
- **DeFi Integration**: Yield farming for escrowed funds
- **Governance Token**: Platform governance through native token
- **Mobile App**: Native mobile application for campaign management

### Phase 5: Advanced Automation
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
- Test all milestone types and edge cases

## 🔗 Links

---

**Built with ❤️ on Stacks**