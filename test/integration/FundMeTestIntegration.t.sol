// SPDX-License-Identifier: MIT

pragma solidity >=0.8.19;

import {Test, console} from "forge-std/Test.sol";

import {FundMe} from "../../src/FundMe.sol";

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundMeInteractions, WithdrawFundMeInteraction} from "../../script/Interactions.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    uint256 public constant SEND_VALUE = 0.1 ether;
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant GAS_PRICE = 1;
    uint256 public constant MINIMUM_ETHER_VALUE = 5e18;

    address public USER = makeAddr("user");

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();

        vm.deal(USER, STARTING_USER_BALANCE);
    }

    modifier funded() {
        vm.prank(USER);
        vm.deal(USER, SEND_VALUE);
        assert(address(fundMe).balance > 0);
        _;
    }

    function testUserCanFundInteractions() public {
        FundMeInteractions fundFundMe = new FundMeInteractions();

        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMeInteraction _withdrawFundMe = new WithdrawFundMeInteraction();
        _withdrawFundMe.whithdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
