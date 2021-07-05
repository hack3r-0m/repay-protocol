require('@nomiclabs/hardhat-ethers');

task(
  'whitelist-protocols',
  'Whitelist addresses of DeFi protocols as receivers from paymaster'
).setAction(async (_, { ethers }) => {
  require('dotenv').config();

  const deployed_paymaster = require(`../deployments/${hre.network.name}/WhitelistPaymaster.json`);
  const paymaster = deployed_paymaster.address;

  const config = require('../config.json');

  const signer = await ethers.provider.getSigner(process.env.ADDRESS);

  const _paymaster = await ethers.getContractAt('WhitelistPaymaster', paymaster, signer);

  try {
    /* do this before transfering ownership */

    await _paymaster.whitelistTarget(config[hre.network.name]['Router']);
    console.log('ROUTER WHITELISTED AS TARGET');
    await _paymaster.whitelistTarget(config[hre.network.name]['Factory']);
    console.log('FACTORY WHITELISTED AS TARGET');
  } catch (e) {
    console.log('Whitelisting targets faield : ' + e.message);
  }
});
