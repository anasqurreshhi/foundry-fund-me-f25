// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMETest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe DeployfundMe = new DeployFundMe();
        fundMe = DeployfundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarisFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwneriSMsgSender() public view {
        console.log(fundMe.getOwner());
        console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedtestversionisAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughtETH() public {
        vm.expectRevert(); // the next line should fail
        fundMe.fund(); // value =0
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // the next tx will be sent by USER
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddresstoAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFundersToArrayofFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testonlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public {
        //    arrange

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFunderBalance = address(fundMe).balance;

        //     ACT

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //    ASSERT

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFunderBalance = address(fundMe).balance;
        assertEq(endingFunderBalance, 0);
        assertEq(
            startingOwnerBalance + startingFunderBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public {
        // arrange
        uint160 numberofFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberofFunders; i++) {
            // vm.prank() makes the msg.sender (who is calling) the address
            //  vm.deal  gives user balance

            hoax(address(i), SEND_VALUE); // shortcut for vm.prank + vm.deal ; vm.prank(address(i)) vm.deal(address(i), SEND_VALUE)
            fundMe.fund{value: SEND_VALUE}(); // address(i) = 160 bit uinque eth address(fake)
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFunderBalance = address(fundMe).balance;

        // ACT

        vm.startPrank(fundMe.getOwner()); // VM.PRANK(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert

        assert(address(fundMe).balance == 0);
        assert(
            startingFunderBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }

    // address addr = address(uint160(5));
    // 0000000000000000000000005

    function testWithdrawCheaperFromMultipleFunders() public {
        // arrange
        uint160 numberofFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberofFunders; i++) {
            // vm.prank() makes the msg.sender (who is calling) the address
            //  vm.deal  gives user balance

            hoax(address(i), SEND_VALUE); // shortcut for vm.prank + vm.deal ; vm.prank(address(i)) vm.deal(address(i), SEND_VALUE)
            fundMe.fund{value: SEND_VALUE}(); // address(i) = 160 bit uinque eth address(fake)
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFunderBalance = address(fundMe).balance;

        // ACT

        vm.startPrank(fundMe.getOwner()); // VM.PRANK(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert

        assert(address(fundMe).balance == 0);
        assert(
            startingFunderBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}

// address addr = address(uint160(5));
// 0000000000000000000000005
