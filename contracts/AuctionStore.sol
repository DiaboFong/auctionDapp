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
    mapping(uint => address) productIdInStore;
    // 通过地址查找到对应的产品集合
    mapping(address => mapping(uint => Product)) stores;
    
    //增加投标人信息
    struct Bid {
        address bidder;
        uint productId;
        uint value;
        bool revealed; //是否已经揭标
    }

    
    //定义产品结构体
    struct Product {
        uint id;                 //产品id
        string name;             //产品名称
        string category ;       //产品分类
        string imageLink ;       //图片Hash
        string descLink;        // 图片描述信息的Hash
        uint auctionStartTime; //开始竞标时间
        uint auctionEndTime;    //竞标结束时间
        uint startPrice;       //拍卖价格   
        address highestBidder ; //出价最高，赢家的钱包地址
        uint highestBid ;       //赢家得标的价格
        uint secondHighestBid ; //竞标价格第二名
        uint totalBids ;        //共计竞标的人数
        ProductStatus status;    //状态
        ProductCondition condition ;  //产品新旧标识
        mapping(address => mapping(bytes32 => Bid)) bids;// 存储所有投标人信息

    }
    constructor ()public{
        productIndex = 0;
    }
    //添加产品到区块链中
    function addProductToStore(string _name, string _category, string _imageLink, string _descLink, uint _auctionStartTime, uint _auctionEndTime ,uint _startPrice, uint  _productCondition) public  {
        //开始时间需要小于结束时间
        require(_auctionStartTime < _auctionEndTime,"开始时间不能晚于结束时间");
        //产品ID自增
        productIndex += 1;
        //product对象稍后直接销毁即可
        Product memory product = Product(productIndex,_name,_category,_imageLink,_descLink,_auctionStartTime,_auctionEndTime,_startPrice,0,0,0,0,ProductStatus.Open,ProductCondition(_productCondition));
        stores[msg.sender][productIndex] = product;
        productIdInStore[productIndex] = msg.sender;   
    }
    //通过产品ID读取产品信息
    function getProduct(uint _productId)  public view returns (uint,string, string,string,string,uint ,uint,uint, ProductStatus, ProductCondition)  {
        Product memory product = stores[productIdInStore[_productId]][_productId];
        return (product.id, product.name,product.category,product.imageLink,product.descLink,product.auctionStartTime,product.auctionEndTime,product.startPrice,product.status,product.condition);
    }
    //投标,传入参数为产品Id以及Hash值(实际竞标价与秘钥词语的组合Hash),需要添加Payable
    function bid(uint _productId, bytes32 _bid) payable public returns (bool) {
        Product storage product = stores[productIdInStore[_productId]][_productId];
        require(now >= product.auctionStartTime, "开始时间不能晚于当前时间");
        require(now <= product.auctionEndTime,"结束时间不能早于当前时间");
        require(msg.value > product.startPrice,"用于迷惑竞争对手的价格，不能低于开标价格");
        require(product.bids[msg.sender][_bid].bidder == 0); //在提交竞标之前，必须保证bid的值为空
        //将投标人信息进行保存
        product.bids[msg.sender][_bid] = Bid(msg.sender, _productId, msg.value,false);
        //产品投标人数递增
        product.totalBids += 1;
        //返回投标成功
        return true;
    }

    //公告，揭标方法
    function revealBid(uint _productId, string _amount, string _secret) public {
        //通过产品ID获取产品信息
        Product storage product = stores[productIdInStore[_productId]][_productId];
        //确保当前时间大于投标结束时间
        require(now > product.auctionEndTime,"当前时间不能早于竞标结束时间");
        // 对竞标价格与关键字密钥进行加密
        bytes32 sealedBid = keccak256(_amount, _secret);
        //获取投标人信息
        Bid memory bidInfo = product.bids[msg.sender][sealedBid];
        //判断是否存在钱包地址，钱包地址0x4333  uint160的钱包类型
        require(bidInfo.bidder > 0,"钱包地址不存在"); 
        //判断是否已经公告揭标过
        require(bidInfo.revealed == false,"已经揭标");
        // 定义系统的退款
        uint refund;
        uint amount = stringToUint(_amount);
        // bidInfo.value 其实就是 mask bid，用于迷惑竞争对手的价格
        if (bidInfo.value < amount) { //如果bidInfo.value的值< 实际竞标价，则返回全部退款，属于无效投标
            refund = bidInfo.value;
        }else { //如果属于有效投标，参照如下分类
            if (address(product.highestBidder) == 0) { //第一个参与公告的人，此时该值为0
                //将出标人的地址赋值给最高出标人地址
                product.highestBidder = msg.sender;
                // 将出标人的价格作为最高价格
                product.highestBid = amount;
                // 将产品的起始拍卖价格作为第二高价格
                product.secondHighestBid = product.startPrice;
                // 将多余的钱作为退款，如bidInfo.value = 20,amount = 12,则退款8
                refund = bidInfo.value - amount;
            }else { //此时参与者不是第一个参与公告的人
                // amount = 15 , bidInfo.value = 25,amount > 12 
                if (amount > product.highestBid) {
                    // 将原来的最高价地址 赋值给 第二高价的地址
                    product.secondHighestBid = product.highestBid;
                    // 将原来最高的出价退还给原先退给原先的最高价地址
                    product.highestBidder.transfer(product.highestBid);
                    // 将当前出价者的地址作为最高价地址
                    product.highestBidder = msg.sender;
                    // 将当前出价作为最高价，为15
                    product.highestBid = amount;
                    // 此时退款为 20 - 15 = 5
                    refund = bidInfo.value - amount;
                }else if (amount > product.secondHighestBid) {
                    //
                    product.secondHighestBid = amount;
                    //退还所有竞标款
                    refund = amount;
                }else { //如果出价比第二高价还低的话，直接退还竞标款
                    refund = amount;
                }
            }
            if (refund > 0){ //取回退款
                msg.sender.transfer(refund);
                product.bids[msg.sender][sealedBid].revealed = true;
            }
        }



    }

    //帮助方法
    //1. 获取竞标赢家信息
    function highestBidderInfo (uint _productId)public view returns (address, uint ,uint) {
        Product memory product = stores[productIdInStore[_productId]][_productId];
        return (product.highestBidder,product.highestBid,product.secondHighestBid);
    }    
    //2. 获取参与竞标的人数
    function  totalBids(uint _productId) view public returns (uint) {
        Product memory product = stores[productIdInStore[_productId]][_productId];
        return  product.totalBids;
    }
    //3. 将字符串string到uint类型
    function stringToUint(string s) pure private returns (uint) {
        bytes memory b = bytes(s);
        uint result = 0 ;
        for (uint i = 0; i < b.length; i++ ){
            if (b[i] >=48 && b[i] <=57){
                result = result * 10  + (uint(b[i]) - 48);
            }
        }
        return result;
    }
} 