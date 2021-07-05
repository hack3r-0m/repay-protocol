require('hardhat');

const config = require('../config.json');
const deployed_paymaster = require(`../deployments/${hre.network.name}/WhitelistPaymaster.json`);

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const trustedForwarder = config[hre.network.name]['Forwarder'];
  const paymaster = deployed_paymaster.address;

  /* deploy the contract */

  const deploy_output = await deploy('InteractionProxyDeployer', {
    from: deployer,
    args: [trustedForwarder, paymaster],
    log: true,
  });

  /* verify the contract */

  await hre.run('verify:verify', {
      address: deploy_output.address,
      constructorArguments: [trustedForwarder, paymaster],
  })

};

module.exports.tags = ['InteractionProxyDeployer'];
