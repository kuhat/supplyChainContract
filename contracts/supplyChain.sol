pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

contract supplyChain{

    struct logisticNode {
        address nodeAddress;        // Adress of the node
        string nodeName;            // Name of the node
        string nodePassword;        // Password of the node
        uint[] nodeGoods;           // Goods a node possess
        uint[] merchantGoods;       // Goods a node release
    }

    struct Good {
        uint goodID;                 // Good ID
        string goodName;             // Good Name
        uint goodPrice;              // Good price
        bool isBought;               // Whether the good is isBought
        uint releaseTime;            // Good release time
        address[] transferProcess;   // Addresses the good is passed by
    }

    mapping(address => logisticNode) allLogisticNodes;    // All the nodes
    mapping(uint => Good) goods;                          // All the goods
    mapping(uint => address) goodToOwner;                 // Map the goods to the current owner according to id

    address[] nodeAddresses;    // Addresses of all the nodes
    uint[] goodsID;             // All the goods id


    // Judge if the node has been registered
    function isNodeRegistered(address _nodeAddress) internal view returns (bool) {
        bool isRegistered = false;
        for(uint i = 0; i < nodeAddresses.length; i++) {
            if(nodeAddresses[i] == _nodeAddress) {
                return isRegistered = true;
            }
        }
        return isRegistered;
    }


    // Judge if the good has existed
    function isGoodExist(uint _goodID) internal view returns (bool){
        bool isExist = false;
        for(uint i = 0; i < goodsID.length; i++){
            if(goodsID[i] == _goodID){
                return isExist = true;
            }
        }
        return isExist;
    }


    // Node register
    event RegisterNode(address _nodeAddress, bool isSuccess, string message);
    // @Param: _nodeAddress, _nodeName and __nodePassword
    function registerNode(address _nodeAddress, string _nodeName, string _nodePassword) public {
        if(!isNodeRegistered(_nodeAddress)) {                            // If the passed-in user dose not exist,
            allLogisticNodes[_nodeAddress].nodeAddress = _nodeAddress;   //add the user into the system
            allLogisticNodes[_nodeAddress].nodeName = _nodeName;
            allLogisticNodes[_nodeAddress].nodePassword = _nodePassword;
            nodeAddresses.push(_nodeAddress);

            emit RegisterNode(_nodeAddress, true, "Register Success!");
            return;
        } else {
            emit RegisterNode(_nodeAddress, true, "This address has been registered, register failed!");
            return;
        }
    }


    // Node publish goods
    event NodePublishGood(address _nodeAddress, bool isSuccess, string message);
    // @Param: _nodeAddress, goodID, goodname, good price, releaseTime
    function nodePublishGood(address _nodeAddress, uint _goodID, string _goodName, uint _goodPrice, uint _releaseTime) public{
        if (!isGoodExist(_goodID)){

            goods[_goodID].goodID = _goodID;                                // Publish goods into
            goods[_goodID].goodName = _goodName;
            goods[_goodID].releaseTime = now;
            goods[_goodID].goodPrice = _goodPrice;
            goods[_goodID].isBought = false;
            goods[_goodID].transferProcess.push(_nodeAddress);
            goodsID.push(_goodID);                                          // Add the new good to goods repository

            allLogisticNodes[_nodeAddress].merchantGoods.push(_goodID);     // Update the ownership
            allLogisticNodes[_nodeAddress].nodeGoods.push(_goodID);
            goodToOwner[_goodID] = _nodeAddress;

            emit NodePublishGood(_nodeAddress, true, "Publish Success!");
            return;
        }else {
            emit NodePublishGood(_nodeAddress, false, "Publish Failed!");
            return;
        }
    }


    // Node transfer goods
    event NodeTransferGood(address seller, bool isSuccess, string msg);
    function nodeTransferGood(address _seller, address _buyer, uint _goodID) public {
        if(goodToOwner[_goodID] != _seller){
            emit NodeTransferGood(_seller, false, "Sorry, you are not the owner of this entity.");
            return;
        } else {
            if (isNodeRegistered(_buyer)){
                goodToOwner[_goodID] = _buyer;                     // Add a mapping relation
                allLogisticNodes[_buyer].nodeGoods.push(_goodID);  // Chango the ownership of the good
                goods[_goodID].transferProcess.push(_buyer);       // Add a transferProcess for the exchanged good

                emit NodeTransferGood(_seller, true, "Transfer Success!");
                return;
            } else {
                emit NodeTransferGood(_seller, false, "The receiver did not register!");
                return;
            }
        }
    }


    // Get a node's possessed goods
    // @Returns uint: numbers of the goods a node posseses. uint[]: Ids of goods. string[],
    //  names of the possessed goods. uint[]: goods prices. address[]: addresses of the owners
    // @Param _nodeAddress: address of the passed node
    function getPossessedGoods(address _nodeAddress) constant public returns(uint, uint[] , string[], uint[] ,address[]){
        uint length = allLogisticNodes[_nodeAddress].merchantGoods.length;
        string[] memory goodsNames = new string[](length);
        uint[] memory goodsPrices = new uint[](length);
        address[] memory owners = new address[](length);

        for(uint i = 0; i < length; i++){
            goodsNames[i] = goods[allLogisticNodes[_nodeAddress].nodeGoods[i]].goodName;
            owners[i] = goodToOwner[allLogisticNodes[_nodeAddress].nodeGoods[i]];
            goodsPrices[i] = goods[allLogisticNodes[_nodeAddress].nodeGoods[i]].goodPrice;
        }

        return (length, allLogisticNodes[_nodeAddress].nodeGoods ,goodsNames, goodsPrices , owners);
    }


    // Get a node's releaseGoods
    // @Returns uint[]: Ids of goods. string[], names of the possessed goods
    // @Param _nodeAddress: address of the passed node
    function getReleaseGoods(address _nodeAddress) constant public returns(uint[], string[]){
        uint length = allLogisticNodes[_nodeAddress].nodeGoods.length;
        string[] memory goodsNames = new string[](length);

        for(uint i=0;i < length;i++){
            goodsNames[i] = goods[allLogisticNodes[_nodeAddress].nodeGoods[i]].goodName;    // Get each good's name via mapping
        }
        return (allLogisticNodes[_nodeAddress].merchantGoods, goodsNames);
    }


    // Explore the transfer process of a particular good
    function getGoodTransferProcess(uint _goodID) constant public returns (uint, address[]) {
        return (goods[_goodID].transferProcess.length, goods[_goodID].transferProcess);
    }


    // Get all the goods
    function getAllGoods() constant public returns(uint, string[], uint[], address[]){
        uint length = goodsID.length;
        string[] memory goodsNames = new string[](length);
        uint[] memory goodsPrices = new uint[](length);
        address[] memory goodsOwners = new address[](length);

        for(uint i=0; i< length; i++){
            goodsNames[i] = goods[goodsID[i]].goodName;
            goodsPrices[i] = goods[goodsID[i]].goodPrice;
            goodsOwners[i] = goodToOwner[goodsID[i]];
        }
        return (length,goodsNames,goodsPrices,goodsOwners);
    }


    // Get the price of a particular good
    function getPrice(uint _goodID) constant public returns(uint){
        return goods[_goodID].goodPrice;
    }


    // Get nodeName
    function getUserName(address _nodeAddress) constant public returns(string){
        return allLogisticNodes[_nodeAddress].nodeName;
    }


    // Get balance
    function getBalance(address _nodeAddress) constant public returns (uint) {
        return _nodeAddress.balance;
    }
}