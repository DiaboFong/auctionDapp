Eutil = require('ethereumjs-util');
AuctionStore = artifacts.require("./AuctionStore.sol");
module.exports = function(callback) {
 current_time = Math.round(new Date() / 1000);
 amount = web3.toWei(1, 'ether');
 AuctionStore.deployed().then(function(i) {i.addProductToStore('Macbook Pro 2017 001', 'Cell Phones & Accessories', 'Qma4pDDNNB12U4hbkd27iXCE5AH4obqJtV2cKMSN1rznci', 'QmRmvR1uiSgYPJNR2hVhvT5ftFktJagH86gYF161VwbUgG', current_time, current_time + 200, 2*amount, 0).then(function(f) {console.log(f)})});
 AuctionStore.deployed().then(function(i) {i.addProductToStore('Macbook Pro 2017 002', 'Cell Phones & Accessories', 'Qma4pDDNNB12U4hbkd27iXCE5AH4obqJtV2cKMSN1rznci', 'QmRmvR1uiSgYPJNR2hVhvT5ftFktJagH86gYF161VwbUgG', current_time, current_time + 400, 3*amount, 1).then(function(f) {console.log(f)})});
 AuctionStore.deployed().then(function(i) {i.addProductToStore('Macbook Pro 2018 001', 'Cell Phones & Accessories', 'Qma4pDDNNB12U4hbkd27iXCE5AH4obqJtV2cKMSN1rznci', 'QmRmvR1uiSgYPJNR2hVhvT5ftFktJagH86gYF161VwbUgG', current_time, current_time + 14, amount, 0).then(function(f) {console.log(f)})});
 AuctionStore.deployed().then(function(i) {i.addProductToStore('Macbook Pro 2018 002', 'Cell Phones & Accessories', 'Qma4pDDNNB12U4hbkd27iXCE5AH4obqJtV2cKMSN1rznci', 'QmRmvR1uiSgYPJNR2hVhvT5ftFktJagH86gYF161VwbUgG', current_time, current_time + 86400, 4*amount, 1).then(function(f) {console.log(f)})});
 AuctionStore.deployed().then(function(i) {i.addProductToStore('Macbook Pro 2016 001', 'Cell Phones & Accessories', 'Qma4pDDNNB12U4hbkd27iXCE5AH4obqJtV2cKMSN1rznci', 'QmRmvR1uiSgYPJNR2hVhvT5ftFktJagH86gYF161VwbUgG', current_time, current_time + 86400, 5*amount, 1).then(function(f) {console.log(f)})});
 AuctionStore.deployed().then(function(i) {i.productIndex.call().then(function(f){console.log(f)})});
}
