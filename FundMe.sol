// SPDX-License-Identifier:MIT

pragma solidity >= 0.6.0 <0.9.0;

// link for interface aggregator
// https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe{

    using SafeMathChainlink for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address public owner;
    address[] public funders;
     
    constructor() public{
        owner == msg.sender;
    }

    function fund() public payable{
    uint256 minimumUsd = 50 * 10 * 18;
    require(getConversionRate(msg.value) >= minimumUsd , " you need to spend more ETH!");
    addressToAmountFunded[msg.sender] += msg.value;
    // what the ETH -> USD conversion rate is?
    funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }
    function getPrice() public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
        // 1058.03430217
    }
    function getConversionRate(uint256 ethAmount) public view returns(uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountUsd = (ethAmount * ethPrice)/1000000000000000000;
        return ethAmountUsd ;
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    
    function withdraw() payable public{
        msg.sender.transfer(address(this).balance);
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
} 
