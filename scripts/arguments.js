/* For uniswap proxy verification */

const config = require('../config.json');
require('dotenv').config();

const deployed_interaction_proxy_deployer = require(`../deployments/${hre.network.name}/InteractionProxyDeployer.json`);
const interaction_proxy_deployer = deployed_interaction_proxy_deployer.address;

module.exports = [
  config[hre.network.name]['Forwarder'], // forwarder
  process.env.ADDRESS, // proxy owner
  interaction_proxy_deployer, // proxy address
  config[hre.network.name]['Router'], // uniswap router
  config[hre.network.name]['Factory'], // uniswap factory
];
