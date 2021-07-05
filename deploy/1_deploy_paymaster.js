require('hardhat');

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  /* deploy the contract */

  const deploy_output = await deploy('WhitelistPaymaster', {
    from: deployer,
    args: [],
    log: true,
  });

  /* verify the contract */

  await hre.run('verify:verify', {
    address: deploy_output.address,
    constructorArguments: [],
  });
};

module.exports.tags = ['WhitelistPaymaster'];
