import React, { useState } from 'react';
import { Award, Gift, Trophy, Star, Sparkles, Users, Clock, CheckCircle } from 'lucide-react';

export default function CampaignRewardsTierUI() {
  const [activeTab, setActiveTab] = useState('browse');
  const [selectedTier, setSelectedTier] = useState(null);
  const [backAmount, setBackAmount] = useState('');

  // Mock campaign data
  const campaign = {
    id: 1,
    title: "Revolutionary DeFi Gaming Platform",
    description: "Building the future of play-to-earn gaming on Stacks",
    raised: 450000,
    target: 1000000,
    backers: 127,
    endBlock: 52560,
    currentBlock: 45000
  };

  // Mock tier data
  const tiers = [
    {
      id: 1,
      name: "Bronze Supporter",
      minContribution: 10,
      maxBackers: 100,
      currentBackers: 67,
      rewardType: "multiplier",
      rewardValue: 110,
      description: "Get 10% bonus on your contribution + voting rights",
      icon: Award,
      color: "from-orange-400 to-orange-600",
      benefits: ["10% Bonus Multiplier", "Voting Rights", "Project Updates", "Community Badge"]
    },
    {
      id: 2,
      name: "Silver Supporter",
      minContribution: 50,
      maxBackers: 50,
      currentBackers: 32,
      rewardType: "nft",
      rewardValue: 1,
      description: "Exclusive Silver NFT badge + 25% bonus multiplier",
      icon: Star,
      color: "from-gray-300 to-gray-500",
      benefits: ["Limited Edition NFT", "25% Bonus Multiplier", "Early Access", "VIP Discord Channel", "All Bronze Benefits"]
    },
    {
      id: 3,
      name: "Gold Supporter",
      minContribution: 100,
      maxBackers: 25,
      currentBackers: 18,
      rewardType: "token",
      rewardValue: 5000,
      description: "Rare Gold NFT + 5000 bonus tokens + 50% multiplier",
      icon: Trophy,
      color: "from-yellow-400 to-yellow-600",
      benefits: ["Rare Gold NFT", "5,000 Bonus Tokens", "50% Bonus Multiplier", "Governance Rights", "Beta Testing Access", "All Silver Benefits"]
    },
    {
      id: 4,
      name: "Platinum Elite",
      minContribution: 500,
      maxBackers: 10,
      currentBackers: 5,
      rewardType: "nft",
      rewardValue: 1,
      description: "Ultra-rare 1-of-10 Platinum NFT + 20k tokens + 100% multiplier",
      icon: Sparkles,
      color: "from-purple-400 to-purple-600",
      benefits: ["Ultra-Rare Platinum NFT", "20,000 Bonus Tokens", "100% Bonus Multiplier", "Advisory Board Access", "Personal Thank You", "Revenue Share", "All Gold Benefits"]
    }
  ];

  // Mock user data
  const [userTier, setUserTier] = useState({
    tierId: 2,
    contribution: 75,
    rewardsClaimed: false,
    achievedBlock: 44500
  });

  const calculateTierForAmount = (amount) => {
    const numAmount = parseFloat(amount);
    if (isNaN(numAmount)) return null;
    
    for (let i = tiers.length - 1; i >= 0; i--) {
      if (numAmount >= tiers[i].minContribution) {
        return tiers[i];
      }
    }
    return null;
  };

  const predictedTier = calculateTierForAmount(backAmount);

  const TierCard = ({ tier, isUserTier = false }) => {
    const Icon = tier.icon;
    const slotsRemaining = tier.maxBackers - tier.currentBackers;
    const fillPercentage = (tier.currentBackers / tier.maxBackers) * 100;

    return (
      <div 
        className={`bg-white rounded-xl border-2 transition-all duration-300 hover:shadow-xl ${
          selectedTier?.id === tier.id ? 'border-blue-500 shadow-lg' : 'border-gray-200'
        } ${isUserTier ? 'ring-2 ring-green-500' : ''}`}
        onClick={() => setSelectedTier(tier)}
      >
        <div className={`bg-gradient-to-r ${tier.color} text-white p-6 rounded-t-xl`}>
          <div className="flex items-center justify-between mb-2">
            <div className="flex items-center gap-3">
              <Icon className="w-8 h-8" />
              <h3 className="text-2xl font-bold">{tier.name}</h3>
            </div>
            {isUserTier && (
              <span className="bg-green-500 text-white px-3 py-1 rounded-full text-sm font-semibold">
                YOUR TIER
              </span>
            )}
          </div>
          <p className="text-white/90 text-sm">{tier.description}</p>
        </div>

        <div className="p-6">
          <div className="space-y-4">
            {/* Contribution Info */}
            <div className="flex justify-between items-center">
              <span className="text-gray-600 font-medium">Min Contribution:</span>
              <span className="text-2xl font-bold text-gray-900">{tier.minContribution} STX</span>
            </div>

            {/* Slots Available */}
            <div>
              <div className="flex justify-between text-sm mb-2">
                <span className="text-gray-600">Slots Available</span>
                <span className="font-semibold">{slotsRemaining} / {tier.maxBackers}</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div 
                  className={`bg-gradient-to-r ${tier.color} h-2 rounded-full transition-all duration-500`}
                  style={{ width: `${fillPercentage}%` }}
                />
              </div>
            </div>

            {/* Benefits */}
            <div>
              <h4 className="font-semibold text-gray-900 mb-2">Benefits:</h4>
              <ul className="space-y-2">
                {tier.benefits.map((benefit, idx) => (
                  <li key={idx} className="flex items-center gap-2 text-sm text-gray-700">
                    <CheckCircle className="w-4 h-4 text-green-500 flex-shrink-0" />
                    {benefit}
                  </li>
                ))}
              </ul>
            </div>

            {/* Reward Badge */}
            <div className="bg-gray-50 rounded-lg p-3 border border-gray-200">
              <div className="text-xs text-gray-600 mb-1">Reward Type</div>
              <div className="font-semibold text-gray-900">
                {tier.rewardType === 'nft' && `🎨 Exclusive NFT`}
                {tier.rewardType === 'token' && `🪙 ${tier.rewardValue.toLocaleString()} Tokens`}
                {tier.rewardType === 'multiplier' && `⚡ ${tier.rewardValue}% Multiplier`}
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  };

  const BackingSimulator = () => (
    <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200">
      <h3 className="text-2xl font-bold mb-4 flex items-center gap-2">
        <Gift className="w-6 h-6 text-blue-600" />
        Back This Campaign
      </h3>

      <div className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Contribution Amount (STX)
          </label>
          <input
            type="number"
            value={backAmount}
            onChange={(e) => setBackAmount(e.target.value)}
            placeholder="Enter amount..."
            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>

        {predictedTier && (
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <div className="flex items-start gap-3">
              <predictedTier.icon className="w-6 h-6 text-blue-600 mt-1" />
              <div>
                <h4 className="font-bold text-blue-900 mb-1">
                  You'll get: {predictedTier.name}
                </h4>
                <p className="text-sm text-blue-700">{predictedTier.description}</p>
                <div className="mt-2 flex items-center gap-2 text-sm text-blue-600">
                  <Users className="w-4 h-4" />
                  {predictedTier.maxBackers - predictedTier.currentBackers} slots remaining
                </div>
              </div>
            </div>
          </div>
        )}

        <button 
          className="w-full bg-gradient-to-r from-blue-600 to-blue-700 text-white py-3 rounded-lg font-semibold hover:from-blue-700 hover:to-blue-800 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          disabled={!backAmount || parseFloat(backAmount) < 10}
        >
          {!backAmount || parseFloat(backAmount) < 10 
            ? 'Enter amount (min 10 STX)' 
            : `Back ${backAmount} STX & Get ${predictedTier?.name || 'Tier'}`}
        </button>
      </div>
    </div>
  );

  const ClaimRewardsPanel = () => {
    const userTierData = tiers.find(t => t.id === userTier.tierId);
    
    return (
      <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200">
        <h3 className="text-2xl font-bold mb-4 flex items-center gap-2">
          <Trophy className="w-6 h-6 text-yellow-600" />
          Your Rewards
        </h3>

        {userTierData && (
          <div className="space-y-4">
            <div className={`bg-gradient-to-r ${userTierData.color} text-white rounded-lg p-4`}>
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-sm opacity-90">Current Tier</div>
                  <div className="text-2xl font-bold">{userTierData.name}</div>
                </div>
                <userTierData.icon className="w-12 h-12" />
              </div>
              <div className="mt-2 text-sm opacity-90">
                Contribution: {userTier.contribution} STX
              </div>
            </div>

            <div className="space-y-2">
              <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
                <div className="flex items-center justify-between">
                  <div>
                    <div className="font-semibold text-gray-900">Reward Status</div>
                    <div className="text-sm text-gray-600 mt-1">
                      {userTier.rewardsClaimed 
                        ? 'Already claimed' 
                        : 'Ready to claim'}
                    </div>
                  </div>
                  {!userTier.rewardsClaimed && (
                    <CheckCircle className="w-6 h-6 text-green-500" />
                  )}
                </div>
              </div>

              <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
                <div className="font-semibold text-gray-900 mb-2">Your Benefits:</div>
                <ul className="space-y-1">
                  {userTierData.benefits.slice(0, 3).map((benefit, idx) => (
                    <li key={idx} className="flex items-center gap-2 text-sm text-gray-700">
                      <CheckCircle className="w-4 h-4 text-green-500" />
                      {benefit}
                    </li>
                  ))}
                </ul>
              </div>
            </div>

            <button 
              className="w-full bg-gradient-to-r from-green-600 to-green-700 text-white py-3 rounded-lg font-semibold hover:from-green-700 hover:to-green-800 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
              disabled={userTier.rewardsClaimed}
            >
              {userTier.rewardsClaimed ? 'Rewards Claimed ✓' : 'Claim Your Rewards 🎁'}
            </button>
          </div>
        )}
      </div>
    );
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50 p-8">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="bg-white rounded-2xl shadow-lg p-8 mb-8 border border-gray-100">
          <div className="flex items-start justify-between">
            <div>
              <h1 className="text-4xl font-bold text-gray-900 mb-2">{campaign.title}</h1>
              <p className="text-gray-600 mb-4">{campaign.description}</p>
              <div className="flex items-center gap-6 text-sm">
                <span className="flex items-center gap-1">
                  <Users className="w-4 h-4 text-blue-600" />
                  {campaign.backers} backers
                </span>
                <span className="flex items-center gap-1">
                  <Clock className="w-4 h-4 text-blue-600" />
                  {campaign.endBlock - campaign.currentBlock} blocks remaining
                </span>
              </div>
            </div>
            <div className="text-right">
              <div className="text-sm text-gray-600 mb-1">Raised</div>
              <div className="text-3xl font-bold text-gray-900">
                {(campaign.raised / 1000).toFixed(0)}k STX
              </div>
              <div className="text-sm text-gray-600">
                of {(campaign.target / 1000).toFixed(0)}k goal
              </div>
              <div className="w-48 bg-gray-200 rounded-full h-2 mt-2">
                <div 
                  className="bg-gradient-to-r from-blue-600 to-purple-600 h-2 rounded-full"
                  style={{ width: `${(campaign.raised / campaign.target) * 100}%` }}
                />
              </div>
            </div>
          </div>
        </div>

        {/* Tabs */}
        <div className="flex gap-4 mb-6">
          <button
            onClick={() => setActiveTab('browse')}
            className={`px-6 py-3 rounded-lg font-semibold transition-all ${
              activeTab === 'browse'
                ? 'bg-blue-600 text-white shadow-lg'
                : 'bg-white text-gray-600 hover:bg-gray-50'
            }`}
          >
            Browse Tiers
          </button>
          <button
            onClick={() => setActiveTab('back')}
            className={`px-6 py-3 rounded-lg font-semibold transition-all ${
              activeTab === 'back'
                ? 'bg-blue-600 text-white shadow-lg'
                : 'bg-white text-gray-600 hover:bg-gray-50'
            }`}
          >
            Back Campaign
          </button>
          <button
            onClick={() => setActiveTab('rewards')}
            className={`px-6 py-3 rounded-lg font-semibold transition-all ${
              activeTab === 'rewards'
                ? 'bg-blue-600 text-white shadow-lg'
                : 'bg-white text-gray-600 hover:bg-gray-50'
            }`}
          >
            My Rewards
          </button>
        </div>

        {/* Content */}
        {activeTab === 'browse' && (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {tiers.map(tier => (
              <TierCard 
                key={tier.id} 
                tier={tier} 
                isUserTier={tier.id === userTier.tierId}
              />
            ))}
          </div>
        )}

        {activeTab === 'back' && (
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <div className="lg:col-span-2">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {tiers.map(tier => (
                  <TierCard key={tier.id} tier={tier} />
                ))}
              </div>
            </div>
            <div>
              <BackingSimulator />
            </div>
          </div>
        )}

        {activeTab === 'rewards' && (
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <div className="lg:col-span-2">
              {tiers.find(t => t.id === userTier.tierId) && (
                <TierCard 
                  tier={tiers.find(t => t.id === userTier.tierId)} 
                  isUserTier={true}
                />
              )}
            </div>
            <div>
              <ClaimRewardsPanel />
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
