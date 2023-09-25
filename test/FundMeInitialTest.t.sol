// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {

}
/* ===============
    FundMe fundMe;

    // setUp always runs first !

    function setUp() external {
        fundMe = new FundMe();
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerMessageSender() public {
        console.log(fundMe.i_owner());
        console.log(msg.sender);
        console.log(address(this));

        // if we use msg.sender, the address used will be that of the calling function. But the address that created the contract
        // was tthis contract itself that is why we should use address(this)
        assertEq(fundMe.i_owner(), address(this));
    }
}

================== */
