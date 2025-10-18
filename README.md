# PulseForge
## Milestone-Powered Decentralized Crowdfunding with Multi-Token Support & Tier-Based Rewards

PulseForge is an innovative decentralized crowdfunding protocol built on the Stacks blockchain where fund release is conditional on milestone achievements. Unlike traditional crowdfunding platforms, PulseForge ensures accountability through a milestone-based voting system that protects both creators and backers. **Now supports both STX and SIP-010 fungible tokens for maximum flexibility, plus advanced milestone types with automated verification and tier-based backer rewards with NFT incentives.**

## 🚀 Features

- **Milestone-Based Funding**: Campaign funds are released incrementally as creators complete predefined milestones
- **Multi-Token Support**: Support for both STX and approved SIP-010 fungible tokens
- **Advanced Milestone Types**: Multiple milestone verification methods including automated verification
- **Conditional Logic**: Smart milestones with dependencies and automated triggers
- **🎁 Tier-Based Rewards**: NFT and token rewards for backers based on contribution levels
- **🏆 Backer Incentives**: Multiple reward types including NFTs, tokens, and bonus multipliers
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

## 🎁 Reward Tier System

### Reward Types

#### 1. NFT Rewards (`reward-type-nft`)
- **Digital collectibles**: Campaign-specific NFTs for backers
- **Proof of support**: On-chain verification of participation
- **Exclusive access**: Can be used for special perks or governance

#### 2. Token Rewards (`reward-type-token`)
- **Bonus tokens**: Additional token allocation from reward pool
- **Proportional distribution**: Based on contribution tier
- **Flexible rewards**: Campaign creators set reward amounts

#### 3. Bonus Multipliers (`reward-type-multiplier`)
- **Enhanced returns**: Percentage-based bonus on contributions
- **Early bird benefits**: Reward early supporters
- **Scaling incentives**: Higher tiers get better multipliers

### Tier Structure

Campaigns can define multiple tiers with:
- **Minimum contribution**: Entry threshold for tier
- **Maximum backers**: Limited slots for exclusivity
- **Reward type**: NFT, token, or multiplier
- **Reward value**: Specific reward amount or percentage

## 🏗️ Architecture

### Smart Contract Components

#### Core Contracts
- **Campaign Management**: Create and manage crowdfunding campaigns with customizable parameters for STX or SIP-010 tokens
- **Token Registry**: Approved token system for SIP-010 fungible tokens
- **Advanced Milestone System**: Multiple milestone types with automated verification capabilities
- **Conditional Logic Engine**: Dependency checking and automated milestone verification
- **Voting Mechanism**: Democratic approval system for manual milestone completion
- **Escrow System**: Secure token holding and conditional release for both STX and SIP-010 tokens
- **Refund System**: Automatic refund capability for failed campaigns

#### Rewards System (New)
- **Tier Management**: Create and manage reward tiers with flexible parameters
- **Reward Pool**: Token and NFT reward distribution system
- **Achievement Tracking**: On-chain verification of tier achievements
- **Claim Mechanism**: Secure reward claiming for backers
- **Bonus Calculations**: Automatic multiplier application

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

#### Reward System (New)
- `create-campaign-tier`: Create reward tiers for campaigns
- `initialize-reward-pool`: Set up reward pool for token distribution
- `assign-backer-tier`: Automatically assign tier based on contribution
- `claim-nft-reward`: Claim NFT rewards for tier achievement
- `claim-token-reward`: Claim token rewards from pool
- `update-tier-status`: Activate/deactivate reward tiers

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

### Creating an STX Campaign with Rewards

```clarity
;; Create campaign
(contract-call? .pulseforge create-stx-campaign 
  "My Innovation Project" 
  "Building the future of decentralized technology" 
  u1000000 ;; Target: 1000 STX
  u1440)   ;; Duration: ~10 days in blocks

;; Initialize reward pool
(contract-call? .pulseforge initialize-reward-pool
  u1           ;; campaign-id
  u100000000   ;; Total reward tokens
  none         ;; No token contract (STX native)
  (some 'SP...nft-contract)) ;; NFT contract for rewards

;; Create Bronze Tier
(contract-call? .pulseforge create-campaign-tier
  u1                              ;; campaign-id
  "Bronze Supporter"              ;; tier name
  u10000                          ;; Min 10 STX
  u100                            ;; Max 100 backers
  u3                              ;; reward-type-multiplier
  u110                            ;; 110% multiplier (10% bonus)
  none)                           ;; No NFT for this tier

;; Create Silver Tier with NFT
(contract-call? .pulseforge create-campaign-tier
  u1                              ;; campaign-id
  "Silver Supporter"              ;; tier name
  u50000                          ;; Min 50 STX
  u50                             ;; Max 50 backers
  u1                              ;; reward-type-nft
  u1                              ;; NFT reward
  (some 'SP...nft-contract))      ;; NFT contract

;; Create Gold Tier
(contract-call? .pulseforge create-campaign-tier
  u1                              ;; campaign-id
  "Gold Supporter"                ;; tier name
  u100000                         ;; Min 100 STX
  u20                             ;; Max 20 backers
  u2                              ;; reward-type-token
  u5000000                        ;; 5000 reward tokens
  none)                           ;; No NFT
```

### Backing Campaign and Claiming Rewards

```clarity
;; Back campaign (automatically assigned to appropriate tier)
(contract-call? .pulseforge back-stx-campaign u1 u50000) ;; 50 STX -> Silver tier

;; Check your tier assignment
(contract-call? .pulseforge get-backer-tier-info u1 tx-sender)

;; Claim NFT reward (after campaign milestone)
(contract-call? .pulseforge claim-nft-reward 
  u1                           ;; campaign-id
  'SP...nft-contract           ;; NFT contract
  u42)                         ;; Token ID

;; Claim token reward
(contract-call? .pulseforge claim-token-reward u1)

;; Check bonus multiplier
(contract-call? .pulseforge get-backer-bonus-multiplier u1 tx-sender)
```

### Creating a SIP-010 Token Campaign with Rewards

```clarity
;; First, approve the token (owner only)
(contract-call? .pulseforge approve-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.some-token)

;; Create the campaign
(contract-call? .pulseforge create-token-campaign 
  "DeFi Innovation Hub" 
  "Revolutionary DeFi platform development" 
  u500000000 ;; Target amount in token units
  u2160      ;; Duration: ~15 days in blocks
  'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.some-token)

;; Set up reward tiers with token rewards
(contract-call? .pulseforge create-campaign-tier
  u2                              ;; campaign-id
  "Platinum Backer"               ;; tier name
  u10000000                       ;; Min contribution
  u10                             ;; Max 10 backers
  u2                              ;; reward-type-token
  u1000000                        ;; Bonus tokens
  none)
```

### Querying Reward Information

```clarity
;; Get tier details
(contract-call? .pulseforge get-campaign-tier u1 u2)

;; Check remaining slots in tier
(contract-call? .pulseforge get-tier-slots-remaining u1 u1)

;; Check if backer claimed rewards
(contract-call? .pulseforge has-claimed-rewards u1 tx-sender)

;; Get reward pool status
(contract-call? .pulseforge get-campaign-reward-pool u1)

;; View tier achievement
(contract-call? .pulseforge get-tier-achievement u1 u2 tx-sender)
```

## 🪙 Supported Tokens

### STX (Native)
- **Always supported**: STX is the native token of the Stacks blockchain
- **No approval needed**: STX campaigns can be created immediately

### SIP-010 Fungible Tokens
- **Approval required**: SIP-010 tokens must be approved by the contract owner before use
- **Security focused**: Only vetted tokens are approved to ensure campaign safety
- **Check approval status**: Use `is-token-approved` to verify token status

### SIP-009 NFTs (Rewards)
- **Reward mechanism**: NFTs can be distributed as backer rewards
- **Tier-based**: Different NFTs for different contribution tiers
- **Proof of support**: On-chain verification of campaign participation

### Token Approval Process
1. Contract owner reviews token contract for security and legitimacy
2. Owner calls `approve-token` with the token contract principal
3. Token becomes available for campaign creation
4. Creators can now use the approved token for campaigns

## 🧪 Testing

The contracts include comprehensive error handling and validation:

- Parameter validation for all inputs
- Access control for campaign creators and contract owner
- Token type validation and approval checks
- Advanced milestone type validation
- Dependency checking for milestone prerequisites
- Automated verification logic testing
- **Reward tier validation and slot management**
- **NFT transfer verification**
- **Token reward pool management**
- **Bonus multiplier calculations**
- Anti-spam measures for voting
- Proper escrow management for both STX and SIP-010 tokens
- Edge case handling for refunds
- Token transfer error handling

## 🔒 Security Features

- **Token Approval System**: Only pre-approved SIP-010 tokens can be used
- **Type Safety**: Clear separation between STX and SIP-010 token operations
- **Advanced Milestone Validation**: Comprehensive checks for milestone types and conditions
- **Dependency Verification**: Automatic validation of milestone prerequisites
- **Reward Claim Protection**: Prevents double-claiming of rewards
- **Tier Slot Management**: Ensures exclusivity and prevents overbooking
- **NFT Transfer Validation**: Secure NFT reward distribution
- **Pool Balance Checks**: Prevents over-distribution of token rewards
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

### Phase 3: Tier-Based Rewards ✅
- **NFT Rewards**: Campaign-specific NFT distribution to backers
- **Token Rewards**: Bonus token allocation from reward pools
- **Bonus Multipliers**: Percentage-based contribution bonuses
- **Tier Management**: Flexible tier creation with slot limits
- **Achievement Tracking**: On-chain verification of tier milestones
- **Claim System**: Secure reward distribution mechanism

### Phase 4: Ecosystem Integration
- **Campaign Categories**: Organize campaigns by industry/type
- **Advanced Analytics Dashboard**: Real-time campaign performance metrics
- **Social Features**: Backer profiles and campaign updates
- **Reputation System**: Track creator and backer history

### Phase 5: Enterprise Features
- **Cross-chain Support**: Bridge to other blockchain networks
- **DeFi Integration**: Yield farming for escrowed funds
- **Governance Token**: Platform governance through native token
- **Mobile App**: Native mobile application for campaign management
- **KYC/AML Integration**: Enhanced compliance features

### Phase 6: Advanced Automation
- **Batch Operations**: Handle multiple campaigns efficiently
- **API Gateway**: RESTful API for third-party integrations
- **White-label Solutions**: Customizable crowdfunding solutions
- **Advanced Reporting**: Comprehensive analytics and insights

## 💡 Use Cases

### For Creators
- **Tech Startups**: Raise funds with milestone-based delivery guarantees
- **Artists & Musicians**: Offer exclusive NFTs to supporters
- **Game Developers**: Reward early backers with in-game NFTs
- **Content Creators**: Multi-tier support with exclusive perks
- **Open Source Projects**: Community-funded development with transparency

### For Backers
- **Investment Opportunities**: Support projects with accountability
- **Exclusive Rewards**: Earn NFTs and tokens for contributions
- **Community Governance**: Vote on milestone completion
- **Flexible Tiers**: Choose reward level based on budget
- **Refund Protection**: Get funds back if campaigns fail

## 📊 Reward Tier Examples

### Typical Campaign Structure

**Bronze Tier** (Entry Level)
- Min Contribution: 10 STX
- Max Backers: 100
- Reward: 10% bonus multiplier
- Benefits: Voting rights, project updates

**Silver Tier** (Mid Level)
- Min Contribution: 50 STX
- Max Backers: 50
- Reward: Exclusive NFT + 25% bonus multiplier
- Benefits: Early access, special recognition

**Gold Tier** (Premium)
- Min Contribution: 100 STX
- Max Backers: 25
- Reward: Limited edition NFT + 1000 bonus tokens + 50% multiplier
- Benefits: VIP access, governance rights, exclusive perks

**Platinum Tier** (Elite)
- Min Contribution: 500 STX
- Max Backers: 10
- Reward: Ultra-rare NFT + 10000 bonus tokens + 100% multiplier
- Benefits: All previous benefits + direct creator access

## 🤝 Contributing

We welcome contributions! Please read our contributing guidelines and submit pull requests for any improvements.

### Development Guidelines
- Follow Clarity best practices
- Include comprehensive tests for new features
- Update documentation for any changes
- Ensure `clarinet check` passes without warnings
- Test all milestone types and edge cases
- Validate reward distribution logic
- Test NFT transfer mechanisms
- Verify bonus multiplier calculations
