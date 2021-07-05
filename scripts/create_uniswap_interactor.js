require('@nomiclabs/hardhat-ethers');

task(
  'create-uniswap-proxy',
  'creates an uniswap proxy to do gasless transactions with uniswap router'
).setAction(async (_, { ethers }) => {
  require('dotenv').config();

  const deployed_interaction_proxy_deployer = require(`../deployments/${hre.network.name}/InteractionProxyDeployer.json`);
  const interaction_proxy_deployer = deployed_interaction_proxy_deployer.address;

  const config = require('../config.json');

  const signer = await ethers.provider.getSigner(process.env.ADDRESS);

  const interactionProxyDeployer = await ethers.getContractAt(
    'InteractionProxyDeployer',
    interaction_proxy_deployer,
    signer
  );

  try {
    const deploy_output = await interactionProxyDeployer.deploy(0);

    console.log(deploy_output);

    await hre.run('verify:verify', {
        address: deploy_output._proxyAddress,
        constructorArguments: [
          config[hre.network.name]['Forwarder'], // forwarder
          process.env.ADDRESS, // proxy owner
          interaction_proxy_deployer, // proxy address
          config[hre.network.name]['Router'], // uniswap router
          config[hre.network.name]['Factory'], // uniswap factory
        ],
    })
  } catch (e) {
    console.log('Creating uniswap intraction proxy failed : ' + e.message);
  }
});
