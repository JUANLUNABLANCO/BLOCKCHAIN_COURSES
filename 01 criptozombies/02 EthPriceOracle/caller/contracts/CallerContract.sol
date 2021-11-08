
// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./EthPriceOracleInterface.sol";
// import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
require "@openzeppelin/contracts/access/Ownable.sol";       
// WARNING no lo encuentra ni este ni el anterior???
// WARNING quizás deba modificarse la ruta de node_modules

contract CallerContract is Ownable {
    uint256 private ethPrice;
    EthPriceOracleInterface private oracleInstance;
    address private oracleAddress;

    mapping(uint256=>bool) myRequests;
    
    event newOracleAddressEvent(address oracleAddress);
    event ReceivedNewRequestIdEvent(uint256 id);
    event PriceUpdatedEvent(uint256 ethPrice, uint256 id);

    function setOracleInstanceAddress (address _oracleInstanceAddress) public  onlyOwner {
        oracleAddress = _oracleInstanceAddress;
        oracleInstance = EthPriceOracleInterface(oracleAddress);
        emit newOracleAddressEvent(oracleAddress);
    }
    function updateEthPrice() public {
      uint256 id = oracleInstance.getLatestEthPrice();
      myRequests[id] = true;                            // what a fuck???
      emit ReceivedNewRequestIdEvent(id);
    }
    function callback(uint256 _ethPrice, uint256 _id) public {
        require(myRequests[_id], "This request is not in my pending list.");
        ethPrice = _ethPrice;
        delete myRequests[_id];                     // se asegura que el que realiza la operació nes el mismo usuario
        emit PriceUpdatedEvent(_ethPrice, _id);        
    }
    modifier onlyOracle() {
        require(msg.sender == oracleAddress, "You are not authorized to call this function.");
        _;
    }

}
