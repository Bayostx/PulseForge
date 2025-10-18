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
