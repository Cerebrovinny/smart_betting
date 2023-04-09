const DecentralizedBettingPlatform = artifacts.require("DecentralizedBettingPlatform");

module.exports = function (deployer) {
  deployer.deploy(DecentralizedBettingPlatform);
};