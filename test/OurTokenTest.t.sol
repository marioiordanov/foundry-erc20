// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public token;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        token = deployer.run();

        vm.prank(msg.sender);

        token.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public {
        assertEq(token.balanceOf(bob), STARTING_BALANCE);
    }

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;

        // Bob approves Alice to spend tokens on his behalf

        vm.prank(bob);
        token.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        token.transferFrom(bob, alice, transferAmount);

        assertEq(token.balanceOf(alice), transferAmount);
        assertEq(token.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    // AI tests
    function testTransfer() public {
        uint256 transferAmount = 50 ether;

        // Bob transfers tokens to Alice
        vm.prank(bob);
        token.transfer(alice, transferAmount);

        assertEq(token.balanceOf(alice), transferAmount);
        assertEq(token.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testTransferInsufficientBalance() public {
        uint256 transferAmount = 200 ether;

        vm.prank(bob);

        // Attempting to transfer more tokens than the sender has
        (bool success, ) = address(token).call(
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                alice,
                transferAmount
            )
        );

        assertFalse(
            success,
            "Transfer should fail due to insufficient balance"
        );
    }

    function testTransferFromInsufficientAllowance() public {
        uint256 initialAllowance = 100 ether;

        // Alice attempts to transfer more tokens than Bob approved
        vm.prank(bob);
        token.approve(alice, initialAllowance);

        uint256 transferAmount = 200 ether;

        vm.prank(alice);
        // Alice tries to transfer more than the allowance given by Bob
        (bool success, ) = address(token).call(
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                bob,
                alice,
                transferAmount
            )
        );

        assertFalse(
            success,
            "TransferFrom should fail due to insufficient allowance"
        );
    }

    function testIncreaseAllowance() public {
        uint256 initialAllowance = 100 ether;
        uint256 increaseAllowanceBy = 50 ether;

        vm.startPrank(bob);
        // Bob approves more tokens for Alice
        token.approve(alice, initialAllowance);

        // Increase allowance for Alice
        token.approve(alice, increaseAllowanceBy + initialAllowance);

        uint256 expectedAllowance = initialAllowance + increaseAllowanceBy;

        assertEq(token.allowance(bob, alice), expectedAllowance);
    }

    function testDecreaseAllowance() public {
        uint256 initialAllowance = 100 ether;

        vm.startPrank(bob);
        // Bob approves tokens for Alice
        token.approve(alice, initialAllowance);

        // Decrease allowance for Alice
        token.approve(alice, 0);

        uint256 expectedAllowance = 0;

        assertEq(token.allowance(bob, alice), expectedAllowance);
    }
}
