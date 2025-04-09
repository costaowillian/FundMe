// SPDX-License-Identifier: MIT

pragma solidity  >=0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import {PriceConverter} from "./PriceConverter.sol";

error FundMe_NotOwner();

contract FundMe is Ownable {
    using PriceConverter for uint256;

    uint public constant MINIMUN_USD = 5 * 10 ** 18;

    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    AggregatorV3Interface private s_priceFeed;

    constructor(address _priceFeed) Ownable(msg.sender) {
        s_priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUN_USD, "You need to spend more ETH!");

        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);

        (bool success,) = owner().call{value: address(this).balance}("");
        require(success);
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);
        (bool success,) = owner().call{value: address(this).balance}("");
        require(success);
    }

    function getAddressToAmountFunded(address fundingAddress) public view returns(uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getVersion() public view returns(uint256) {
        return s_priceFeed.version();
    }

    function getFunder(uint256 index) public view returns(address) {
        return s_funders[index];
    }

    function getOwner() public view returns(address) {
        return owner();
    }

    function getPriceFeed() public view returns(AggregatorV3Interface) {
        return s_priceFeed;
    }
}