var AuctionStore = artifacts.require('./AuctionStore.sol')

module.exports = function (deployer) {
  deployer.deploy(AuctionStore)
}
