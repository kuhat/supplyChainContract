pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

contract utils {

}

contract supplyChain is utils{

    struct logisticNode {
        address nodeAddress;         // Adress of the node
        string nodeName;             // Name of the node
        string nodePassword;         // Password of the node
        uint[] nodeGoods;            // Goods a node possess
        uint[] merchantGoods;        // Goods a node release

        uint[] nodeMoneyDonations;     // Ids of money donations a node releases
        uint[] nodeGoodDonations;      // Ids of good donations a node releases
        uint[] nodeMoneyDonationsRcv;  // Money Donations a node receives
        uint[] nodeGoodDonationsRcv;   // Good Donations a node reveices
    }

    struct Good {
        uint goodID;                 // Good ID
        string goodName;             // Good Name
        uint goodPrice;              // Good price
        bool isBought;               // Whethmoneymoneyer the good is isBought
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
    function nodePublishGood(address _nodeAddress, uint _goodID, string _goodName, uint _goodPrice) public{
        if (!isNodeRegistered(_nodeAddress)){

            emit NodePublishGood(_nodeAddress, false, "Node not registered!!");

        } else {
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
                emit NodePublishGood(_nodeAddress, false, "Publish failed, ID already exist, please input another ID.");
                return;
            }
        }
    }


    // Node transfer goods
    event NodeTransferGood(address seller, bool isSuccess, string msg);
    function nodeTransferGood(address _from, address _to, uint _goodID) public {
        if(goodToOwner[_goodID] != _from){
            emit NodeTransferGood(_from, false, "Sorry, you are not the owner of this entity.");
            return;
        } else {
            if (isNodeRegistered(_to)){
                //goodToOwner[_goodID] = _to;                     // Add a mapping relation
                //allLogisticNodes[_to].nodeGoods.push(_goodID);  // Chango the ownership of the good
                goods[_goodID].transferProcess.push(_to);       // Add a transferProcess for the exchanged good

                emit NodeTransferGood(_from, true, "Transfer Success!");
                return;
            } else {
                emit NodeTransferGood(_from, false, "The receiver did not register!");
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


contract donate is supplyChain{

    struct moneyDonation {           // Donation based on money
        uint ID;
        uint amount;
        bool isTransferred;
        uint releaseTime;
        address[2] transferProcess;  // Donation provider and reciever
    }

    struct goodDonation {            // Donation based on good
        uint ID;
        Good good;                   // Binded good
        bool isTransferred;
        uint releaseTime;
        address[2] transferProcess;
    }

    mapping(uint => moneyDonation) moneyDonations;  // Map Ids with donations
    mapping(uint => address) moneyDonationToNode;   // Map Node with donations

    mapping(uint => goodDonation) goodDonations;
    mapping(uint => address) goodDonationToNode;

    uint moneyDonationNumber = 0;                   // Total donation number
    uint goodDonationNumber = 0;


    // Release money donation infomation on blockchain
    event PublishMoney(address _nodeAddress, bool isSuccess, string msg);
    function publishMoney(address _nodeAddress, uint _amount) public {
        if (!isNodeRegistered(_nodeAddress)){
            emit PublishMoney(_nodeAddress, false, "Node not registered!");
        } else {
            if (_amount <= 0){
                emit PublishMoney(_nodeAddress, false, "Please donate a valid amount!");
            } else {

                moneyDonations[moneyDonationNumber].ID = moneyDonationNumber;                 // Add the new donation to repository
                moneyDonations[moneyDonationNumber].amount = _amount;
                moneyDonations[moneyDonationNumber].isTransferred = false;
                moneyDonations[moneyDonationNumber].releaseTime = now;
                moneyDonations[moneyDonationNumber].transferProcess[0] = _nodeAddress;

                moneyDonationToNode[moneyDonationNumber] = _nodeAddress;                      // Add the donation ownership

                allLogisticNodes[_nodeAddress].nodeMoneyDonations.push(moneyDonationNumber);  // Add the Money donation Id to Node
                moneyDonationNumber ++;                                                       // Increase MoneyDonation ID
                emit PublishMoney(_nodeAddress, true, "Donation success!!");
            }
        }
    }


    // Transfer money Donation
    function transferMoneyDonation(address _from, address _to, uint _moneyDonationNumber) public {
        if(moneyDonationToNode[_moneyDonationNumber] != _from){
            emit NodeTransferGood(_from, false, "Sorry, money provider not coorrect, please double check!!");
            return;
        } else {
            if (isNodeRegistered(_to) && isNodeRegistered(_from)){

                moneyDonations[_moneyDonationNumber].isTransferred = true;
                moneyDonations[_moneyDonationNumber].transferProcess[1] = _to;           // Add the transferProcess of the money donation item
                moneyDonationToNode[_moneyDonationNumber] = _to;                         // Change the ownership of a money donation item
                allLogisticNodes[_to].nodeMoneyDonationsRcv.push(_moneyDonationNumber);  // Add the money donation _to node receices
                emit NodeTransferGood(_from, true, "Transfer Success!");
                return;
            } else {
                emit NodeTransferGood(_from, false, "The receiver did not register!");
                return;
            }
        }
    }


    // Release good donation information on blockchian
    event NodeDonateGood(address seller, bool isSuccess, string msg);
    function nodeDonateGood(address _seller, address _buyer, uint _goodID) public {
        if(goodToOwner[_goodID] != _seller){
            emit  NodeDonateGood(_seller, false, "Sorry, you are not the owner of this entity.");
            return;
        } else {
            if (isNodeRegistered(_buyer)){
                goodToOwner[_goodID] = _buyer;                              // Add a mapping relation
                allLogisticNodes[_buyer].nodeGoods.push(_goodID);           // Change the ownership of the good

                goodDonations[goodDonationNumber].ID = goodDonationNumber;  // Add a goodDonation obj
                goodDonations[goodDonationNumber].good = goods[_goodID];
                goodDonations[goodDonationNumber].isTransferred = true;
                goodDonations[goodDonationNumber].releaseTime = now;
                goodDonations[goodDonationNumber].transferProcess[0] = _seller;
                goodDonations[goodDonationNumber].transferProcess[1] = _buyer;

                goodDonationToNode[goodDonationNumber] = _seller;            // Add the donation ownership
                allLogisticNodes[_seller].nodeGoodDonations.push(goodDonationNumber);
                goodDonationNumber++;
                emit NodeDonateGood(_seller, true, "Donate Success!");
                return;
            } else {
                emit NodeDonateGood(_seller, false, "The receiver did not register!");
                return;
            }
        }
    }


    // Return available money donation ID
    function returnAvailableMoneyDonationId() internal returns(uint, uint[]){
        uint length = 0;
        uint[] IDs;
        for(uint i=0; i < moneyDonationNumber; i++){
            if(moneyDonations[i].isTransferred == false){
                length ++;
                IDs.push(i);
            }
        }
        return (length, IDs);
    }

    // Return available good donation ID
    function returnAvailableGoodDonationId() internal returns(uint, uint[]){
        uint length = 0;
        uint[] IDs;
        for(uint i=0; i < goodDonationNumber; i++){
            if(goodDonations[i].isTransferred == false){
                length ++;
                IDs.push(i);
            }
        }
        return (length, IDs);
    }


    // Get all the available money Donations
    function getAvailableMoneyDonations() public view returns(uint, uint[], uint[], address[]){

        uint length;
        uint[] memory IDs;
        (length, IDs) = returnAvailableMoneyDonationId();

        uint[] memory amounts = new uint[](length);
        uint[] memory releaseTimes = new uint[](length);
        address[] memory donatorAddresses = new address[](length);

        for(uint i = 0; i < length; i++){                         // Get informations of available money donations
            amounts[i] = moneyDonations[i].amount;
            releaseTimes[i] = moneyDonations[i].releaseTime;
            donatorAddresses[i] = moneyDonations[i].transferProcess[0];
        }
        return (length, amounts, releaseTimes, donatorAddresses);
    }


    // Get all the available Good Donations
    function getAvailableGoodDonations() public view returns(uint, Good[], uint[], address[]){

        uint length;
        uint[] memory IDs;
        (length, IDs) = returnAvailableGoodDonationId();

        Good[] memory goods = new Good[](length);
        uint[] memory releaseTimes = new uint[](length);
        address[] memory donatorAddresses = new address[](length);

        for(uint i = 0; i < length; i++){                         // Get informations of available money donations
            goods[i] = goodDonations[i].good;
            releaseTimes[i] = goodDonations[i].releaseTime;
            donatorAddresses[i] = goodDonations[i].transferProcess[0];
        }
        return (length, goods, releaseTimes, donatorAddresses);
    }


    // Get all the money donations
    function getMoneyDonations() public view returns(uint, uint[], uint[], address[]){
        uint[] memory donationsAmounts = new uint[](moneyDonationNumber);
        address[] memory addresses = new address[](moneyDonationNumber);
        bool[] memory donationStatus = new bool[](moneyDonationNumber);
        uint[] memory releaseTimes = new uint[](moneyDonationNumber);

        for(uint i = 0; i < moneyDonationNumber; i ++){           // Add donation information
            donationsAmounts[i] = moneyDonations[i].amount;
            addresses[i] = moneyDonations[i].transferProcess[0];
            releaseTimes[i] = moneyDonations[i].releaseTime;
            donationStatus[i] = moneyDonations[i].isTransferred;
        }
        return(moneyDonationNumber, donationsAmounts, releaseTimes, addresses);
    }


    // Get all the good donations
    function getGoodDonations() public view returns(uint, Good[], uint[], address[]){
        Good[] memory Goods = new Good[](goodDonationNumber);
        address[] memory addresses = new address[](goodDonationNumber);
        bool[] memory donationStatus = new bool[](goodDonationNumber);
        uint[] memory releaseTimes = new uint[](goodDonationNumber);

        for(uint i = 0; i < goodDonationNumber; i ++){           // Add Good donation information
            Goods[i] = goodDonations[i].good;
            addresses[i] = goodDonations[i].transferProcess[0];
            releaseTimes[i] = goodDonations[i].releaseTime;
            donationStatus[i] = goodDonations[i].isTransferred;
        }
        return(moneyDonationNumber, Goods, releaseTimes, addresses);
    }
}