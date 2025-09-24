// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe Deploy = new DeployFundMe();
        fundMe = Deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundfundMe = new FundFundMe();
        fundfundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawfundme = new WithdrawFundMe();
        withdrawfundme.withdrawfundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
