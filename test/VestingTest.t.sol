// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from "@forge-std/Test.sol";
import {VestingContract} from "../src/VestingContract.sol";
import {MockERC20} from "./mock/MockERC20.sol";

contract VestingTest is Test {
    ////////////
    // Events //
    ////////////

    event DepositMade(address indexed user, uint256 indexed amount, uint256 indexed vestingStart);
    event TokensWithdrawn(address indexed user, uint256 indexed amount);

    ////////////
    // Errors //
    ////////////

    error VestingContract__NotAValidAddress();
    error VestingContract__NotAValidAmount();
    error VestingContract__NotAValidDuration();
    error VestingContract__NotAValidToken();
    error VestingContract__NotEnoughWETH();

    VestingContract vesting;
    MockERC20 weth;
    address deployer = makeAddr("deployer");

    address user = makeAddr("user");

    uint256 public constant INITIAL_WETH_BALANCE = 1000e18;
    uint256 public constant DURATION_FOR_DEPOSIT = 604_801; // one second over 7 days
    uint256 public constant DEPSOIT_AMOUNT = 10;

    function setUp() external {
        weth = new MockERC20("WETH", "wETH", deployer, INITIAL_WETH_BALANCE);
        vesting = new VestingContract(weth);
    }

    ///////////////////////////////////
    // depositAndVest Function Tests //
    ///////////////////////////////////

    function testDepositAndVest() public {
        weth.mint(user, DEPSOIT_AMOUNT);
        uint256 beforeDepositUser = weth.balanceOf(user);
        uint256 beforeDepositVesting = weth.balanceOf(address(vesting));
        vm.startPrank(user);
        weth.approve(address(vesting), DEPSOIT_AMOUNT);
        vesting.depositAndVest(user, DEPSOIT_AMOUNT, DURATION_FOR_DEPOSIT);
        uint256 afterDepositUser = weth.balanceOf(user);
        uint256 afterDepositVesting = weth.balanceOf(address(vesting));

        assertEq(beforeDepositUser, afterDepositVesting);
        assertEq(afterDepositUser, beforeDepositVesting);
    }

    function testCannotDepositZeroAddress() public {
        vm.startPrank(address(0));
        vm.expectRevert(VestingContract__NotAValidAddress.selector);
        vesting.depositAndVest(address(0), DEPSOIT_AMOUNT, DURATION_FOR_DEPOSIT);
    }

    function testCannotDepositZeroAmount() public {
        weth.mint(user, DEPSOIT_AMOUNT);
        vm.startPrank(user);
        weth.approve(address(vesting), DEPSOIT_AMOUNT);
        vm.expectRevert(VestingContract__NotAValidAmount.selector);
        vesting.depositAndVest(user, 0, DURATION_FOR_DEPOSIT);
    }

    function testCannotDepositWithLessThanMinimalDuration() public {
        weth.mint(user, DEPSOIT_AMOUNT);
        vm.startPrank(user);
        weth.approve(address(vesting), DEPSOIT_AMOUNT);
        vm.expectRevert(VestingContract__NotAValidDuration.selector);
        vesting.depositAndVest(user, DEPSOIT_AMOUNT, DURATION_FOR_DEPOSIT - 1);
    }

    function testCannotDepositWithLessFundsOwned() public {
        weth.mint(user, DEPSOIT_AMOUNT);
        vm.startPrank(user);
        weth.approve(address(vesting), DEPSOIT_AMOUNT);
        vm.expectRevert(VestingContract__NotEnoughWETH.selector);
        vesting.depositAndVest(user, DEPSOIT_AMOUNT + 1, DURATION_FOR_DEPOSIT);
    }

    function testDepositMadeEventEmittedCorrectly() public {
        weth.mint(user, DEPSOIT_AMOUNT);
        vm.startPrank(user);
        weth.approve(address(vesting), DEPSOIT_AMOUNT);
        vm.expectEmit(true, true, true, false, address(vesting));
        emit DepositMade(user, DEPSOIT_AMOUNT, block.timestamp);
        vesting.depositAndVest(user, DEPSOIT_AMOUNT, DURATION_FOR_DEPOSIT);
    }

    ////////////////////////////////////////////
    // withdrawAvailableTokens Function Tests //
    ////////////////////////////////////////////

    function testWithdarwAvailableTokens() public {}

    ///////////////////////////
    // Getter Function Tests //
    ///////////////////////////

    function testGetUserTotalDepositedAmount() public {
        weth.mint(user, DEPSOIT_AMOUNT);
        vm.startPrank(user);
        weth.approve(address(vesting), DEPSOIT_AMOUNT);
        vesting.depositAndVest(user, DEPSOIT_AMOUNT, DURATION_FOR_DEPOSIT);
        assert(vesting.getUserTotalAmountVested(user) == DEPSOIT_AMOUNT);
    }

    function testGetUserStartTime() public {
        weth.mint(user, DEPSOIT_AMOUNT);
        vm.startPrank(user);
        weth.approve(address(vesting), DEPSOIT_AMOUNT);
        uint256 actualStartTime = block.timestamp;
        vesting.depositAndVest(user, DEPSOIT_AMOUNT, DURATION_FOR_DEPOSIT);
        assert(vesting.getUserStartTime(user) == actualStartTime);
    }

    function testGetUserDuration() public {
        weth.mint(user, DEPSOIT_AMOUNT);
        vm.startPrank(user);
        weth.approve(address(vesting), DEPSOIT_AMOUNT);
        vesting.depositAndVest(user, DEPSOIT_AMOUNT, DURATION_FOR_DEPOSIT);

        assert(vesting.getUserDuration(user) == DURATION_FOR_DEPOSIT);
    }

    function testGetUserTokensToBeUnlockedPerEpoch() public {
        weth.mint(user, DEPSOIT_AMOUNT);
        vm.startPrank(user);
        weth.approve(address(vesting), DEPSOIT_AMOUNT);
        vesting.depositAndVest(user, DEPSOIT_AMOUNT, DURATION_FOR_DEPOSIT);
    }
}
