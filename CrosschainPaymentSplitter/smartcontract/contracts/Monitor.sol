// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import "@chainlink/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";

contract Monitor is ConfirmedOwner, Pausable, AutomationCompatibleInterface {

    address token_CCIP_BnM = 0xFd57b4ddBf88a4e07fF4e34C487b99af2Fe82a05;
    
    uint256 private constant MIN_GAS_FOR_TRANSFER = 55_000;

    event FundsAdded(uint256 amountAdded, uint256 newBalance, address sender);
    event FundsWithdrawn(uint256 amountWithdrawn, address payee);
    event TopUpSucceeded(address indexed recipient);
    event TopUpFailed(address indexed recipient);
    event KeeperRegistryAddressUpdated(address oldAddress, address newAddress);
    event MinWaitPeriodUpdated(uint256 oldMinWaitPeriod, uint256 newMinWaitPeriod);

    error InvalidWatchList();
    error OnlyKeeperRegistry();
    error DuplicateAddress(address duplicate);

    struct Target {
        bool isActive;
        uint96 minBalanceWei;
        uint96 topUpAmountWei;
        uint56 lastTopUpTimestamp;
    }

    address private s_keeperRegistryAddress;
    uint256 private s_minWaitPeriodSeconds;
    address[] private s_watchList;
    mapping(address => Target) internal s_targets;

    constructor(address keeperRegistryAddress, uint256 minWaitPeriodSeconds) ConfirmedOwner(msg.sender) {
        setKeeperRegistryAddress(keeperRegistryAddress);
        setMinWaitPeriodSeconds(minWaitPeriodSeconds);
    }

    function setWatchList(address[] calldata addresses, uint96[] calldata minBalancesWei, uint96[] calldata topUpAmountsWei) external onlyOwner {
        if (addresses.length != minBalancesWei.length || addresses.length != topUpAmountsWei.length) {
            revert InvalidWatchList();
        }
        address[] memory oldWatchList = s_watchList;
        for (uint256 idx = 0; idx < oldWatchList.length; idx++) {
            s_targets[oldWatchList[idx]].isActive = false;
        }
        for (uint256 idx = 0; idx < addresses.length; idx++) {
            if (s_targets[addresses[idx]].isActive) {
                revert DuplicateAddress(addresses[idx]);
            }
            if (addresses[idx] == address(0)) {
                revert InvalidWatchList();
            }
            if (topUpAmountsWei[idx] == 0) {
                revert InvalidWatchList();
            }
            s_targets[addresses[idx]] = Target({
                isActive: true,
                minBalanceWei: minBalancesWei[idx],
                topUpAmountWei: topUpAmountsWei[idx],
                lastTopUpTimestamp: 0
            });
        }
        s_watchList = addresses;
    }

    function getUnderfundedAddresses() public view returns (address[] memory) {
        address[] memory watchList = s_watchList;
        address[] memory needsFunding = new address[](watchList.length);
        uint256 count = 0;
        uint256 minWaitPeriod = s_minWaitPeriodSeconds;
        //uint256 balance = address(this).balance;
        uint256 balance = IERC20(token_CCIP_BnM).balanceOf(address(this));
        Target memory target;
        for (uint256 idx = 0; idx < watchList.length; idx++) {
            target = s_targets[watchList[idx]];
            //if (target.lastTopUpTimestamp + minWaitPeriod <= block.timestamp && balance >= target.topUpAmountWei && watchList[idx].balance < target.minBalanceWei) {
            if (target.lastTopUpTimestamp + minWaitPeriod <= block.timestamp && balance >= target.topUpAmountWei && IERC20(token_CCIP_BnM).balanceOf(watchList[idx]) < target.minBalanceWei) {    
                needsFunding[count] = watchList[idx];
                count++;
                balance -= target.topUpAmountWei;
            }
        }
        if (count != watchList.length) {
            assembly {
                mstore(needsFunding, count)
            }
        }
        return needsFunding;
    }
    
    function topUp(address[] memory needsFunding) public whenNotPaused {
        uint256 minWaitPeriodSeconds = s_minWaitPeriodSeconds;
        Target memory target;
        for (uint256 idx = 0; idx < needsFunding.length; idx++) {
            target = s_targets[needsFunding[idx]];
            //if (target.isActive && target.lastTopUpTimestamp + minWaitPeriodSeconds <= block.timestamp && needsFunding[idx].balance < target.minBalanceWei) {
            if (target.isActive && target.lastTopUpTimestamp + minWaitPeriodSeconds <= block.timestamp && IERC20(token_CCIP_BnM).balanceOf(needsFunding[idx]) < target.minBalanceWei) {    
                //bool success = payable(needsFunding[idx]).send(target.topUpAmountWei);
                bool success = IERC20(token_CCIP_BnM).transfer(needsFunding[idx], target.topUpAmountWei);

                if (success) {
                    s_targets[needsFunding[idx]].lastTopUpTimestamp = uint56(
                        block.timestamp
                    );
                    emit TopUpSucceeded(needsFunding[idx]);
                } else {
                    emit TopUpFailed(needsFunding[idx]);
                }
            }
            if (gasleft() < MIN_GAS_FOR_TRANSFER) {
                return;
            }
        }
    }

    /**
     * @notice Get list of addresses that are underfunded and return payload compatible with Chainlink Automation Network
     * @return upkeepNeeded signals if upkeep is needed, performData is an abi encoded list of addresses that need funds
     */
    function checkUpkeep(bytes calldata) external view override whenNotPaused returns (bool upkeepNeeded, bytes memory performData) {
        address[] memory needsFunding = getUnderfundedAddresses();
        upkeepNeeded = needsFunding.length > 0;
        performData = abi.encode(needsFunding);
        return (upkeepNeeded, performData);
    }

    /**
     * @notice Called by Chainlink Automation Node to send funds to underfunded addresses
     * @param performData The abi encoded list of addresses to fund
     */
    function performUpkeep(bytes calldata performData) external override onlyKeeperRegistry whenNotPaused {
        address[] memory needsFunding = abi.decode(performData, (address[]));
        topUp(needsFunding);
    }

    function withdraw(uint256 amount, address payable payee) external onlyOwner {
        require(payee != address(0));
        emit FundsWithdrawn(amount, payee);
        payee.transfer(amount);
    }

    /**
     * @notice Receive funds
     */
    receive() external payable {
        emit FundsAdded(msg.value, address(this).balance, msg.sender);
    }

    /**
     * @notice Sets the Chainlink Automation registry address
     */
    function setKeeperRegistryAddress(address keeperRegistryAddress) public onlyOwner {
        require(keeperRegistryAddress != address(0));
        emit KeeperRegistryAddressUpdated(
            s_keeperRegistryAddress,
            keeperRegistryAddress
        );
        s_keeperRegistryAddress = keeperRegistryAddress;
    }

    /**
     * @notice Sets the minimum wait period (in seconds) for addresses between funding
     */
    function setMinWaitPeriodSeconds(uint256 period) public onlyOwner {
        emit MinWaitPeriodUpdated(s_minWaitPeriodSeconds, period);
        s_minWaitPeriodSeconds = period;
    }

    /**
     * @notice Gets the Chainlink Automation registry address
     */
    function getKeeperRegistryAddress() external view returns (address keeperRegistryAddress) {
        return s_keeperRegistryAddress;
    }

    /**
     * @notice Gets the minimum wait period
     */
    function getMinWaitPeriodSeconds() external view returns (uint256) {
        return s_minWaitPeriodSeconds;
    }

    /**
     * @notice Gets the list of addresses being watched
     */
    function getWatchList() external view returns (address[] memory) {
        return s_watchList;
    }

    /**
     * @notice Gets configuration information for an address on the watchlist
     */
    function getAccountInfo(address targetAddress) external view returns (bool isActive, uint96 minBalanceWei, uint96 topUpAmountWei, uint56 lastTopUpTimestamp) {
        Target memory target = s_targets[targetAddress];
        return (target.isActive, target.minBalanceWei, target.topUpAmountWei, target.lastTopUpTimestamp);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    modifier onlyKeeperRegistry() {
        if (msg.sender != s_keeperRegistryAddress) {
            revert OnlyKeeperRegistry();
        }
        _;
    }

    function withdrawToken(address _beneficiary, address _token) public onlyOwner {
        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(_beneficiary, amount);
    }
}