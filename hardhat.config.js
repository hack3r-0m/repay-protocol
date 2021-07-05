/* Hardhat and module imports */

require('@nomiclabs/hardhat-ethers');
require('hardhat-deploy');
require('@nomiclabs/hardhat-etherscan');
require('dotenv').config();

/* Tasks imports */

require('./scripts/transfer_ownership');
require('./scripts/create_uniswap_interactor');
require('./scripts/whitelist_protocols');

/* Configurations */

module.exports = {
  defaultNetwork: 'rinkeby',
  networks: {
    rinkeby: {
      url: process.env.RPC_RINKEYBY,
      accounts: [process.env.PRIVATE_KEY],
      saveDeployments: true,
    },
    kovan: {
      url: process.env.RPC_KOVAN,
      accounts: [process.env.PRIVATE_KEY],
      saveDeployments: true,
    },
    polygon: {
      url: process.env.RPC_POLYGON,
      accounts: [process.env.PRIVATE_KEY],
      saveDeployments: true,
    },
  },
  solidity: {
    compilers: [
      {
        version: '0.7.6',
      },
    ],
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts',
  },
  namedAccounts: {
    deployer: {
      default: process.env.ADDRESS,
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};
