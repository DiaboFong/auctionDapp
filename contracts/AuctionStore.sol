pragma solidity ^0.4.24;
//定义合约AuctionStore
contract AuctionStore {
    //定义枚举ProductStatus
    enum ProductStatus {
        Open, //拍卖开始
        Sold, //已售出,交易成功
        Unsold //为售出，交易未成功
    }
    enum ProductCondition {
        New, //拍卖产品是否为新品
        Used //拍卖产品是否已经使用过
    }
    // 用于统计产品数量，作为ID
    uint public productIndex; 
    //产品Id与钱包地址的对应关系
    mapping(uint => address) productIdInStrore;
    // 通过地址查找到对应的产品集合
    mapping(address => mapping(uint => Product)) stores;

    

    struct Product {
        uint id;             //产品id
        string name;         //产品名称
        string category ;   //产品分类
        string imageLink ;   //图片Hash
        string descLink;    // 图片描述信息的Hash
        uint auctionStartTime; //开始竞标时间
        uint auctionEndTime;    //竞标结束时间
        uint startPrice;       //拍卖价格   
        address highestBidder ; //出价最高，赢家的钱包地址
        uint highestBid ; //赢家得标的价格
        uint secondHighestBid ; //竞标价格第二名
        uint totalBids ; //共计竞标的人数
        ProductStatus status; //状态
        ProductCondition condition ;  //产品新旧标识

    }
    
} 