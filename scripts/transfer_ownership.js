require('@nomiclabs/hardhat-ethers');

task(
  'transfer-ownership',
  "transfer's paymaster ownership from EOA to InteractionProxyDeployer"
).setAction(async (_, { ethers }) => {
  require('dotenv').config();

  const deployed_paymaster = require(`../deployments/${hre.network.name}/WhitelistPaymaster.json`);
  const paymaster = deployed_paymaster.address;

  const deployed_interaction_proxy_deployer = require(`../deployments/${hre.network.name}/InteractionProxyDeployer.json`);
  const interaction_proxy_deployer = deployed_interaction_proxy_deployer.address;

  const signer = await ethers.provider.getSigner(process.env.ADDRESS);

  const _paymaster = await ethers.getContractAt('WhitelistPaymaster', paymaster, signer);

  try {
    const out = await _paymaster.transferOwnership(interaction_proxy_deployer);
    console.log(out);
    console.log("UNISWAP PROXY CREATED SUCCESSFULLY")
  } catch (e) {
    console.log('try manual verification, verify faield : ' + e.message);
  }
});
