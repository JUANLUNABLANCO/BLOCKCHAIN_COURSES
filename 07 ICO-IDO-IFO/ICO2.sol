// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2  ;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMathLitle {
    /**
     * mul 
     * @dev Safe math multiply function
     */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  /**
   * add
   * @dev Safe math addition function
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Ownable
 * @dev Ownable has an owner address to simplify "user permissions".
 */
contract OwnableLitle {
  address public owner;

  /**
   * Ownable
   * @dev Ownable constructor sets the `owner` of the contract to sender
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * ownerOnly
   * @dev Throws an error if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * transferOwnership
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }
}

/**
 * @title Token
 * @dev API interface for interacting with the WILD Token contract 
 */
interface Token {
  function transfer(address _to, uint256 _value) external returns (bool);
  function balanceOf(address _owner) external returns (uint256 balance);
}



/**
 * @title smartContractICO
 * @dev smartContractICO contract is Context, Ownable, IBEP20
 **/
contract smartContractICO is OwnableLitle {
  using SafeMathLitle for uint256;
  Token token;

  uint256 public constant RATE = 3000; // Number of tokens per Ether
  uint256 public constant CAP = 5350; // Cap in Ether 
  uint256 public constant START = 1636634127; // today date, calculate with nodejs npm run nowInSeconds.js --> console.log(new Date().getTime() / 1000);
  uint256 public constant DAYS = 45; // 45 Days for example, can be 30, 60
  
  uint256 public constant initialTokens = 6000000 * 10**18; // Initial number of tokens available for the ICO presale
  bool public initialized = false;
  uint256 public raisedAmount = 0;
  
  /**
   * smartContractICO
   * @dev smartContractICO constructor
   **/
  constructor(address _tokenAddr) {
      require(_tokenAddr != address(0));
      token = Token(_tokenAddr);
  }
  
  /**
   * BoughtTokens
   * @dev Log tokens bought onto the blockchain
   **/
  event BoughtTokens(address indexed to, uint256 value);

  /**
   * whenSaleIsActive
   * @dev ensures that the contract is still active
   **/
  modifier whenSaleIsActive() {
    // Check if sale is active
    assert(isActive());
    _;
  }
  
  /**
   * initialize
   * @dev Initialize the contract
   **/
  function initialize() public onlyOwner {
      require(initialized == false); // Can only be initialized once
      require(tokensAvailable() == initialTokens); // Must have enough tokens allocated
      initialized = true;
  }

  /**
   * isActive
   * @dev Determins if the contract is still active
   **/
  function isActive() public view returns (bool) {
    return (
        initialized == true &&
        block.timestamp >= START && // Must be after the START date
        block.timestamp <= START.add(DAYS * 1 days) && // Must be before the end date
        goalReached() == false // Goal must not already be reached
    );
  }

  /**
   * goalReached
   * @dev Function to determin is goal has been reached
   **/
  function goalReached() public view returns (bool) {
    return (raisedAmount >= CAP * 1 ether);
  }

  /**
   * @dev Fallback function if ether is sent to address insted of buyTokens function
   **/
  function Fallback() public payable {
    buyTokens();
  }

  /**
   * buyTokens
   * @dev function that sells available tokens
   **/
  function buyTokens() public payable whenSaleIsActive {
    uint256 weiAmount = msg.value; // Calculate tokens to sell
    uint256 tokens = weiAmount.mul(RATE);
    
    emit BoughtTokens(msg.sender, tokens); // log event onto the blockchain
    raisedAmount = raisedAmount.add(msg.value); // Increment raised amount
    token.transfer(msg.sender, tokens); // Send tokens to buyer
    
    payable(address(owner)).transfer(msg.value);// Send money to owner
  }

  /**
   * tokensAvailable
   * @dev returns the number of tokens allocated to this contract
   **/
  function tokensAvailable() public returns (uint256) {
    return token.balanceOf(address(this));
  }

  /**
   * destroy
   * @notice Terminate contract and refund to owner
   **/
  function destroy() onlyOwner public {
    // Transfer tokens back to owner
    uint256 balance = token.balanceOf(address(this));
    assert(balance > 0);
    token.transfer(owner, balance);
    // There should be no ether in the contract but just in case
    selfdestruct(payable(address(owner)));
  }
}