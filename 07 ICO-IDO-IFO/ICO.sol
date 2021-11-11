pragma solidity ^0.8.2  ;


//import "./selectedToken.sol"; /* you need to import the token you wanna do the sale with

contract selectedTokensale {
address admin ;
selectedToken public tokenContract ;
uint256 public tokenPrice;
uint256 public tokenSold; 


event sell(address _buyer,uint256 _amount); //  

function selectedtokensale (selectedToken _tokenContract,uint256 _tokenPrice) public {
    admin = msg.sender;
    tokenContract = _tokenContract;
    tokenPrice =_tokenPrice;
    }
    
    //safemath function
    function multiply(uint x,uint y) internal pure returns(uint z){
    require (y==0 || (z=x*y)/y==x);
    }

    function buyToken(uint256 _numberOfTokens)public payable{
   //require that  value is equal to tokens
   require(msg.value == multiply(_numberOfTokens , tokenPrice));
   //require that there are enough tokens in the contract
    require(tokenContract.balanceOf(address(this)) >= _numberOfTokens);
   // require that transfer is successfull
    require(tokenContract.transfer(msg.sender, _numberOfTokens));
   //keep track of sold tokens
   tokenSold += _numberOfTokens;
   //trigger sell Event
   emit sell(msg.sender, _numberOfTokens);
    }

    //end the sale of the token
   
    function endSale() public {
      //require that only the admin can do this
      require(msg.sender == admin);
      //require to transfer the remainig selectedTokens to admin
      require(tokenContract.transfer(admin, tokenContract.balanceOf(address(this))));
     
     //address payable addr = payable(address(admin));
     
     selfdestruct(payable(address(admin)));
  }

}
