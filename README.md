# PulseForge
## Milestone-Powered Decentralized Crowdfunding

PulseForge is an innovative decentralized crowdfunding protocol built on the Stacks blockchain where fund release is conditional on milestone achievements. Unlike traditional crowdfunding platforms, PulseForge ensures accountability through a milestone-based voting system that protects both creators and backers.

## 🚀 Features

- **Milestone-Based Funding**: Campaign funds are released incrementally as creators complete predefined milestones
- **Democratic Voting System**: Backers vote to approve milestone completion before funds are released
- **Refundable Escrow**: STX tokens are held in escrow and can be refunded if campaigns fail to deliver
- **Transparent Progress Tracking**: Real-time visibility into campaign progress and milestone status
- **Creator Protection**: Anti-spam measures and proper validation ensure legitimate campaigns
- **Backer Protection**: Vote-based approval system prevents fund misuse

## 🏗️ Architecture

### Smart Contract Components

- **Campaign Management**: Create and manage crowdfunding campaigns with customizable parameters
- **Milestone System**: Define time-based or deliverable milestones with voting requirements
- **Voting Mechanism**: Democratic approval system for milestone completion
- **Escrow System**: Secure STX token holding and conditional release
- **Refund System**: Automatic refund capability for failed campaigns

### Core Functions

- `create-campaign`: Launch a new crowdfunding campaign
- `add-milestone`: Define milestones with specific voting requirements
- `back-campaign`: Contribute STX tokens to support a campaign
- `vote-milestone`: Vote on milestone completion as a campaign backer
- `release-milestone-funds`: Release funds upon successful milestone approval
- `request-refund`: Claim refunds for failed campaigns

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

### Creating a Campaign

```clarity
(contract-call? .pulseforge create-campaign 
  "My Innovation Project" 
  "Building the future of decentralized technology" 
  u1000000 ;; Target: 1000 STX
  u1440)   ;; Duration: ~10 days in blocks
```

### Adding Milestones

```clarity
(contract-call? .pulseforge add-milestone 
  u1 ;; campaign-id
  "Complete MVP development" 
  u720  ;; Target block (~5 days)
  u10)  ;; Required votes
```

### Backing a Campaign

```clarity
(contract-call? .pulseforge back-campaign u1 u100000) ;; 100 STX
```

## 🧪 Testing

The contract includes comprehensive error handling and validation:

- Parameter validation for all inputs
- Access control for campaign creators
- Anti-spam measures for voting
- Proper escrow management
- Edge case handling for refunds

## 🗺️ Roadmap

See our [Future Upgrades](#-future-upgrade-features) section for planned enhancements.

## 🤝 Contributing

We welcome contributions! Please read our contributing guidelines and submit pull requests for any improvements.

## 🔗 Links

- [Stacks Documentation](https://docs.stacks.co/)
- [Clarity Language Reference](https://docs.stacks.co/docs/clarity/)
- [PulseForge Frontend](https://github.com/your-username/pulseforge-frontend)

---

**Built with ❤️ on Stacks**