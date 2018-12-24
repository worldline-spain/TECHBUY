var MovementHistory = artifacts.require("MovementHistory");

module.exports = function(deployer) {
  deployer.deploy(MovementHistory);
};
