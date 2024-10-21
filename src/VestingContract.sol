// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract VestingContract is Ownable, ReentrancyGuard {
    struct VestingRecipt {
        // The total amount deposited by the user.
        uint256 totalAmountVested;
        // The start time of the vesting.
        uint256 startTime;
        // The duration of the vesting.
        uint256 duration;
        // The amount of tokens that can be withdrawn per vesting period.
        uint256 tokensToBeUnlockedPerEpoch;
    }

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

    ///////////////
    // Variables //
    ///////////////

    //* State Variables *//

    // This mapping tracks the users and their vesting data (deposited amount and vesting time).
    mapping(address user => VestingRecipt vestingData) usersVestingData;

    //* Immutable Variables *//

    // The only allowed token for this contract is weth.
    IERC20 public immutable weth;

    //* Constant Variables *//

    uint256 public constant MIN_DUATION_FOR_VESTING = 604_800;
    uint256 public constant SECOND_IN_DAY = 86_400;

    ///////////////
    // Modifiers //
    ///////////////

    modifier checkAddressZero(address _user) {
        if (_user == address(0)) {
            revert VestingContract__NotAValidAddress();
        }
        _;
    }

    modifier checkAmountZero(uint256 _amount) {
        if (_amount == 0) {
            revert VestingContract__NotAValidAmount();
        }
        _;
    }

    constructor(IERC20 _weth) Ownable(msg.sender) {
        weth = _weth;
    }

    //////////////////////
    // Public Funcitons //
    //////////////////////

    //**
    /// @notice Lets the user deposit the desired amount and select a vesting duration
    /// @dev *Finish*
    /// @param _user Address of deopositor
    /// @param _amount Amount to be vested
    /// @param _duration Length of time for the vesting
    /// */
    function depositAndVest(address _user, uint256 _amount, uint256 _duration)
        external
        checkAddressZero(_user)
        checkAmountZero(_amount)
    {
        // Allows the payer to deposit weth tokens into the contract.
        // Stores the total amount deposited and records the current block timestamp as the vesting start time.
        // Specifies the number of vesting days (`n`), which divides the total tokens evenly across the period.

        if (_duration <= MIN_DUATION_FOR_VESTING) revert VestingContract__NotAValidDuration();
        if (weth.balanceOf(_user) < _amount) revert VestingContract__NotEnoughWETH();

        uint256 vestingStart = block.timestamp;
        uint256 amountPerEpoch = _calculateAvailableTokensPerEpoch(_amount, _duration);

        usersVestingData[_user] = VestingRecipt(_amount, vestingStart, _duration, amountPerEpoch);

        emit DepositMade(_user, _amount, vestingStart);
        weth.transferFrom(msg.sender, address(this), _amount);
    }

    //**
    /// @notice Lets user withdraw available tokens that have been vested
    /// @param _user Address of user that previously deposited weth
    /// */
    function withdrawAvailableTokens(address _user) external {
        // Allows the receiver to withdraw tokens according to the vesting schedule.
        // Calculates the number of tokens that can be withdrawn based on the number of days since the vesting started.
        // Prevents withdrawals if more tokens are requested than have been unlocked by the vesting schedule.
    }

    //////////////////////
    // Getter Funcitons //
    //////////////////////

    function getUserTotalAmountVested(address _user) external view returns (uint256) {
        return usersVestingData[_user].totalAmountVested;
    }

    function getUserStartTime(address _user) external view returns (uint256) {
        return usersVestingData[_user].startTime;
    }

    function getUserDuration(address _user) external view returns (uint256) {
        return usersVestingData[_user].duration;
    }

    function getUserTokensToBeUnlockedPerEpoch(address _user) external view returns (uint256) {
        return usersVestingData[_user].tokensToBeUnlockedPerEpoch;
    }

    ////////////////////////
    // Internal Funcitons //
    ////////////////////////

    //**
    /// @notice Calculates the amount of tokens that can be withdrawn per vesting
    /// @dev *Finish*
    /// */
    function _calculateAvailableTokensPerEpoch(uint256 _amountToDeposit, uint256 _duration)
        internal
        pure
        returns (uint256)
    {
        uint256 amountPerEpoch = _amountToDeposit / (_duration / SECOND_IN_DAY);
        return amountPerEpoch;
    }

    //**
    /// @notice Checks if the vesting time has passed
    /// */
    function _checkVestedTimePassed() internal {}

    //**
    /// @notice Calculates the amount of tokens that can be withdrawn per vesting
    /// */
    function _calculateWithdrawAmount() internal {}
}
