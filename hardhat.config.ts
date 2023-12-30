import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "dotenv/config";

const PRIVATE_KEY = process.env.PRIVATE_KEY as string;
const MUMBAI_ALCHEMY_PRIVATE_KEY = process.env.MUMBAI_ALCHEMY_PRIVATE_KEY as string;

console.log('Use private key', PRIVATE_KEY);

const config: HardhatUserConfig = {
  solidity: {
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
    compilers: [
      {
        version: "0.8.11",
      }
    ]
  },
  networks: {
    scroll_testnet: {
      url: "https://alpha-rpc.scroll.io/l2",
      accounts: [PRIVATE_KEY],
    },
    goerli_testnet: {
      url: "https://eth-goerli.g.alchemy.com/v2/DMAeSSr5y1yqBrvb0LABBGUWhfa1V8N4",
      accounts: [PRIVATE_KEY],
    },
    optimism_testnet: {
      url: 'https://goerli.optimism.io',
      accounts: [PRIVATE_KEY as string],
    },
    mumbai_testnet: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${MUMBAI_ALCHEMY_PRIVATE_KEY}`,
      accounts: [PRIVATE_KEY as string],
    },
    zora_testnet: {
      url: 'https://testnet.rpc.zora.co',
      accounts: [PRIVATE_KEY as string],
    },
    base_testnet: {
      url: 'https://base-goerli.blockpi.network/v1/rpc/public',
      accounts: [PRIVATE_KEY as string],
      minGasPrice: 300000,
    },
    mode_testnet: {
      url: 'https://eth-sepolia.g.alchemy.com/v2/mgyw4WrV8d33SC3HGVsA6SQg4tphPhby',
      accounts: [PRIVATE_KEY as string],
    }
  },
  etherscan: {
    apiKey: {
      scroll_testnet: PRIVATE_KEY,
    },
    customChains: [
      {
        network: "scroll_testnet",
        chainId: 534353,
        urls: {
          apiURL: "https://blockscout.scroll.io/api",
          browserURL: "https://blockscout.scroll.io/",
        }
      }
    ]
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
};

export default config;
