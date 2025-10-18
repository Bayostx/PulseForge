#!/bin/bash

# PulseForge Frontend Setup Script
# This script sets up the frontend structure for your Clarinet project

echo "🚀 Setting up PulseForge Frontend..."

# Check if we're in the right directory
if [ ! -f "Clarinet.toml" ]; then
    echo "❌ Error: Clarinet.toml not found. Please run this script from your project root."
    exit 1
fi

# Create frontend directory structure
echo "📁 Creating frontend directory structure..."
mkdir -p frontend/src/components
mkdir -p frontend/src/services
mkdir -p frontend/public

# Create package.json
echo "📦 Creating package.json..."
cat > frontend/package.json << 'EOF'
{
  "name": "pulseforge-frontend",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "lucide-react": "^0.263.1",
    "@stacks/connect": "^7.8.2",
    "@stacks/transactions": "^6.13.0",
    "@stacks/network": "^6.13.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.0.0",
    "vite": "^4.3.9",
    "tailwindcss": "^3.3.2",
    "postcss": "^8.4.24",
    "autoprefixer": "^10.4.14"
  }
}
EOF

# Create vite.config.js
echo "⚙️  Creating vite.config.js..."
cat > frontend/vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    open: true
  }
})
EOF

# Create tailwind.config.js
echo "🎨 Creating tailwind.config.js..."
cat > frontend/tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

# Create postcss.config.js
echo "🎨 Creating postcss.config.js..."
cat > frontend/postcss.config.js << 'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

# Create index.html
echo "📄 Creating index.html..."
cat > frontend/src/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>PulseForge - Tier-Based Rewards</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

# Create main.jsx
echo "📄 Creating main.jsx..."
cat > frontend/src/main.jsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF

# Create App.jsx
echo "📄 Creating App.jsx..."
cat > frontend/src/App.jsx << 'EOF'
import React from 'react'
import CampaignRewardsTierUI from './components/CampaignRewardsTierUI'

function App() {
  return (
    <div className="App">
      <CampaignRewardsTierUI />
    </div>
  )
}

export default App
EOF

# Create index.css
echo "🎨 Creating index.css..."
cat > frontend/src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
EOF

# Create contractService.js
echo "🔗 Creating contractService.js..."
cat > frontend/src/services/contractService.js << 'EOF'
import { 
  openContractCall 
} from '@stacks/connect';
import { 
  uintCV, 
  principalCV,
  someCV,
  noneCV,
  stringAsciiCV 
} from '@stacks/transactions';
import { StacksTestnet } from '@stacks/network';

const network = new StacksTestnet();
const contractAddress = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
const rewardsContractName = 'pulseforge-rewards';

export const createCampaignTier = async (
  campaignId,
  name,
  minContribution,
  maxBackers,
  rewardType,
  rewardValue,
  nftContract
) => {
  const functionArgs = [
    uintCV(campaignId),
    stringAsciiCV(name),
    uintCV(minContribution),
    uintCV(maxBackers),
    uintCV(rewardType),
    uintCV(rewardValue),
    nftContract ? someCV(principalCV(nftContract)) : noneCV()
  ];

  const options = {
    network,
    anchorMode: 1,
    contractAddress,
    contractName: rewardsContractName,
    functionName: 'create-campaign-tier',
    functionArgs,
    onFinish: (data) => {
      console.log('Transaction submitted:', data.txId);
      return data;
    },
    onCancel: () => {
      console.log('Transaction cancelled');
    }
  };

  await openContractCall(options);
};

export const claimNFTReward = async (campaignId, nftContract, tokenId) => {
  const functionArgs = [
    uintCV(campaignId),
    principalCV(nftContract),
    uintCV(tokenId)
  ];

  const options = {
    network,
    anchorMode: 1,
    contractAddress,
    contractName: rewardsContractName,
    functionName: 'claim-nft-reward',
    functionArgs,
    onFinish: (data) => {
      console.log('Reward claimed:', data.txId);
      return data;
    }
  };

  await openContractCall(options);
};

export const claimTokenReward = async (campaignId) => {
  const functionArgs = [uintCV(campaignId)];

  const options = {
    network,
    anchorMode: 1,
    contractAddress,
    contractName: rewardsContractName,
    functionName: 'claim-token-reward',
    functionArgs,
    onFinish: (data) => {
      console.log('Token reward claimed:', data.txId);
      return data;
    }
  };

  await openContractCall(options);
};
EOF

# Create placeholder for CampaignRewardsTierUI.jsx
echo "📄 Creating CampaignRewardsTierUI.jsx placeholder..."
cat > frontend/src/components/CampaignRewardsTierUI.jsx << 'EOF'
import React from 'react';

export default function CampaignRewardsTierUI() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-purple-50 p-8">
      <div className="max-w-7xl mx-auto">
        <div className="bg-white rounded-2xl shadow-lg p-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">
            PulseForge Rewards System
          </h1>
          <p className="text-gray-600 mb-4">
            Please copy the complete UI component code from the artifact into this file.
          </p>
          <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
            <p className="text-sm text-yellow-800">
              <strong>Next Step:</strong> Replace this placeholder with the full 
              CampaignRewardsTierUI component code from the artifact.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
EOF

# Create .gitignore
echo "📝 Creating .gitignore..."
cat > frontend/.gitignore << 'EOF'
# Dependencies
node_modules
.pnp
.pnp.js

# Testing
coverage

# Production
dist
build

# Misc
.DS_Store
.env.local
.env.development.local
.env.test.local
.env.production.local

npm-debug.log*
yarn-debug.log*
yarn-error.log*
EOF

# Create README for frontend
echo "📖 Creating frontend README..."
cat > frontend/README.md << 'EOF'
# PulseForge Frontend

## Setup

```bash
npm install
```

## Development

```bash
npm run dev
```

Visit http://localhost:3000

## Build

```bash
npm run build
```

## Important

Replace the placeholder in `src/components/CampaignRewardsTierUI.jsx` 
with the complete component code from the artifact.
EOF

echo ""
echo "✅ Frontend structure created successfully!"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Install dependencies:"
echo "   cd frontend && npm install"
echo ""
echo "2. Copy the full UI component:"
echo "   Replace frontend/src/components/CampaignRewardsTierUI.jsx"
echo "   with the complete code from the artifact"
echo ""
echo "3. Start development server:"
echo "   npm run dev"
echo ""
echo "4. In another terminal, start Clarinet devnet:"
echo "   clarinet integrate"
echo ""
echo "🎉 Happy coding!"
