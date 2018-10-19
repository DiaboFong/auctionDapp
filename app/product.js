var mongoose = require('mongoose');
mongoose.Promise = global.Promise;

var Schema = mongoose.Schema;

var ProductSchema = new Schema({
 blockchainId: Number,
 name: String,
 category: String,
 ipfsImageHash: String,
 ipfsDescHash: String,
 auctionStartTime: Number,
 auctionEndTime: Number,
 price: Number,
 condition: Number,
 productStatus: Number
});

var ProductModel = mongoose.model('ProductModel', ProductSchema);

module.exports = ProductModel;