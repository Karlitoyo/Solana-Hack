const BossVaultContract = artifacts.require("BossVault")

module.exports = function (deployer) {
    deployer.deploy(BossVaultContract)
}