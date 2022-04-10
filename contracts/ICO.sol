// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./MyToken.sol";

contract ICO is Ownable {
    using SafeMath for uint256;
    MyToken token;

    uint256 public constant RATE = 3000; // Number of tokens per Ether
    uint256 public constant CAP = 5350; // Cap in Ether
    uint256 public constant START = 1519862400; // Mar 26, 2018 @ 12:00 EST
    uint256 public constant DAYS = 45; // 45 Day

    uint256 public constant initialTokens = 6000000 * 10**18; // Initial number of tokens available
    bool public initialized = false;
    uint256 public raisedAmount = 0;

    /**
     * BoughtTokens
     * @dev Log tokens bought onto the blockchain
     */
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
        return (initialized == true &&
            block.timestamp >= START && // Must be after the START date
            block.timestamp <= START.add(DAYS * 1 days) && // Must be before the end date
            goalReached() == false); // Goal must not already be reached
    }

    /**
     * goalReached
     * @dev Function to determin is goal has been reached
     **/
    function goalReached() public view returns (bool) {
        return (raisedAmount >= CAP * 1 ether);
    }

    /**
     * buyTokens
     * @dev function that sells available tokens
     **/
    function buyTokens() public payable whenSaleIsActive {
        uint256 ethAmount = msg.value; // Calculate tokens to sell
        uint256 tokens = ethAmount.mul(RATE);

        emit BoughtTokens(msg.sender, tokens); // log event onto the blockchain
        raisedAmount = raisedAmount.add(msg.value); // Increment raised amount
        token.transfer(msg.sender, tokens); // Send tokens to buyer
        address payable _owner = payable(owner());
        _owner.transfer(msg.value); // Send money to owner
    }

    /**
     * tokensAvailable
     * @dev returns the number of tokens allocated to this contract
     **/
    function tokensAvailable() public returns (uint256) {
        return token.balanceOf(address(this));
    }
}
