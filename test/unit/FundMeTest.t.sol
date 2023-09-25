// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    // this is a foundry cheatcode to use a specific address for all the tests instead of trying out if msg.sender or address(this) sends the transaction
    address USER = makeAddr("saga");

    // an amoun to send
    uint256 constant SEND_VALUE = 1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    // setUp always runs first !

    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // this gives the saga user some funds for the tests
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerMessageSender() public {
        //console.log(fundMe.getOwner());
        //console.log(msg.sender);
        //console.log(address(this));

        // if we use msg.sender, the address used will be that of the calling function. But the address that created the contract
        // was tthis contract itself that is why we should use address(this)
        //assertEq(fundMe.i_owner(), address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testAggregatorVersion() public {
        uint256 version = fundMe.getVersion();
        console.log(version);
        assertEq(version, 4);
    }

    function testFundFailedWithoutEnoughEth() public {
        vm.expectRevert(); // the next line we expect to revert
        fundMe.fund{value: 1e3}(); // we send just 1000 wei so it will fail as it is under 5 $
    }

    function testFundUpdatesFundedDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        console.log("--------------------");
        console.log(amountFunded);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert(); // the user that just deposited is not the owner of the contract so we expect the next line to revert
        vm.prank(USER); // this is not the statement that will be tested... it has a vm in front. the next statement will be tested
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        //arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(
            endingOwnerBalance - startingOwnerBalance,
            startingFundMeBalance
        );
        assertEq(endingFundMeBalance, 0);
    }

    function testWithdrawFromMultipleFunders() public funded {
        //arrange
        uint160 numberOfFunders = 10; // the reason I used 160 is I want to create addresses from these indexes and thisis a limitation of solidity
        uint160 startingFunderIndex = 1; // we dont want to send to address(0) as it is oftenely used to burn so we start at 1 and the 0 index will be used by the modifier
        for (
            uint160 indexFunder = startingFunderIndex;
            indexFunder < numberOfFunders;
            indexFunder++
        ) {
            // hoax is another cheactcode that pranks an address and deals some value
            // address(int160) is a way for solidity to create an address
            hoax(address(indexFunder), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        //console.log(address(fundMe).balance / 1e18);

        //act
        //vm.prank(fundMe.getOwner());
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(
            endingOwnerBalance - startingOwnerBalance,
            startingFundMeBalance
        );
        assertEq(endingFundMeBalance, 0);
    }

    // instead of creating a prank and sending a value every time we can create a modifier!
    modifier funded() {
        vm.prank(USER); // this means the next transaction will be run by a specific address
        fundMe.fund{value: SEND_VALUE}(); // send 10 eth and see if the array and mapping are updated
        _;
    }
}
