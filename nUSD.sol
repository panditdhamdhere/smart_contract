// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract nUSD {
    string public name = "nUSD Stablecoin";
    string public symbol = "nUSD";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    AggregatorV3Interface internal priceFeed;

    constructor(address _priceFeedAddress) {
        priceFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    function deposit(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        uint256 nUSDAmount = _amount / 2;
        balanceOf[msg.sender] += nUSDAmount;
        totalSupply += nUSDAmount;
    }

    function redeem(uint256 _nUSDAmount) external {
        require(_nUSDAmount > 0, "Amount must be greater than 0");
        require(
            balanceOf[msg.sender] >= _nUSDAmount,
            "Insufficient nUSD balance"
        );
        (, int256 ethPrice, , , ) = priceFeed.latestRoundData();
        uint256 ethAmount = uint256(ethPrice) * _nUSDAmount * 2;
        require(address(this).balance >= ethAmount, "Insufficient ETH balance");
        balanceOf[msg.sender] -= _nUSDAmount;
        totalSupply -= _nUSDAmount;
        payable(msg.sender).transfer(ethAmount);
    }
}
