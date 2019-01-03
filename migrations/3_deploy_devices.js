var Devices = artifacts.require("Devices");

module.exports = function(deployer) {
  deployer.deploy(Devices);
};
