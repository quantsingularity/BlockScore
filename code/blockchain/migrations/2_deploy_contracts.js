const CreditScore = artifacts.require("CreditScore");
const LoanContract = artifacts.require("LoanContract");

module.exports = function (deployer) {
  deployer.deploy(CreditScore).then(() => deployer.deploy(LoanContract));
};
