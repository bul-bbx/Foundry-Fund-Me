//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {OurToken} from "../src/OurToken.sol";
import {console} from "forge-std/console.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");
    address carol = makeAddr("carol");

    uint256 public constant INITIAL_BALANCE = 100 ether; // 1 million tokens with 18 decimals

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, INITIAL_BALANCE);
    }

    function testBobBalance() public view {
        // Check Bob's balance
        assertEq(
            ourToken.balanceOf(bob),
            INITIAL_BALANCE,
            "Bob's balance mismatch"
        );
    }

    function testAllowancesWork() public {
        uint256 initialAllowance = 1000;
        //Bob approves Alice to spend on his behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), INITIAL_BALANCE - transferAmount);
    }

    function testBalanceAfterTransfer() public {
        uint256 transferAmount = 50 ether;

        // Bob transfers tokens to Carol
        vm.prank(bob);
        ourToken.transfer(carol, transferAmount);

        // Check balances after transfer
        assertEq(ourToken.balanceOf(bob), INITIAL_BALANCE - transferAmount);
        assertEq(ourToken.balanceOf(carol), transferAmount);
    }

    function testTransfer() public {
        uint256 transferAmount = 10 ether;

        // Bob transfers tokens to Alice
        vm.prank(bob);
        ourToken.transfer(alice, transferAmount);

        // Check balances after transfer
        assertEq(ourToken.balanceOf(bob), INITIAL_BALANCE - transferAmount);
        assertEq(ourToken.balanceOf(alice), transferAmount);
    }

    function testTransferFrom() public {
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 500;

        // Bob approves Alice to spend on his behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        // Alice transfers tokens from Bob to Carol
        vm.prank(alice);
        ourToken.transferFrom(bob, carol, transferAmount);

        // Check balances after transfer
        assertEq(ourToken.balanceOf(bob), INITIAL_BALANCE - transferAmount);
        assertEq(ourToken.balanceOf(carol), transferAmount);
    }
}
