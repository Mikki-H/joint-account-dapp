const JointAccountDApp = artifacts.require("JointAccountDApp");

module.exports = function(deployer) {
  deployer.deploy(JointAccountDApp);
};