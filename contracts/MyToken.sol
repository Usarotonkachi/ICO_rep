// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimal
    ) ERC20(_name, _symbol, 7, 0) {}

    uint256 public cost = 1 ether;
    uint256 public maxSupply = 100000;
    uint256 public maxMintAmount = 12000;

    // public
    function mint(
        address _to,
        uint256 _mintAmount,
        uint16 _cost
    ) public payable onlyOwner {
        uint256 supply = totalSupply();
        require(_mintAmount > 0);
        require(_mintAmount <= maxMintAmount);
        require(supply + _mintAmount <= maxSupply);

        require(msg.value >= _cost * _mintAmount);

        for (uint256 i = 1; i <= _mintAmount; i++) {
            _mint(_to, supply + i);
        }
    }

    function presale() public {
        require(balanceOf(msg.sender) >= 100);
    }
}
