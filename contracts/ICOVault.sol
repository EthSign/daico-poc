// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";

struct AssetInfo {
    uint256 peakBalance;
    uint256 spentBalance;
    uint256 flowRate;
    uint256 lastWithdrawal;
}

interface ICOVaultExchangeRateDataSource {
    function tokensPerFundingUnit() external view returns (uint256);

    function tokensPerFundingUnit(
        address asset
    ) external view returns (uint256);
}

contract ICOVault is Initializable, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public projectToken;
    ICOVaultExchangeRateDataSource public dataSource;
    uint256 public fundingStartTime;
    uint256 public fundingDeadline;
    address public beneficiary;
    bool public isRefundEnabled;

    // asset => investor => amount
    mapping(address => mapping(address => uint256)) public investments;
    // asset => amount
    mapping(address => AssetInfo) public assetInfo;

    event FundAdded(address asset, uint256 amount, uint256 amountOffered);
    event FlowRateChanged(address asset, uint256 oldRate, uint256 newRate);
    event BeneficiaryChanged(address oldBeneficiary, address newBeneficiary);
    event FundsWithdrawn(address asset, uint256 amount);
    event RefundEnabled();
    event FundsRefunded(address asset, address investor, uint256 amount);

    error BeforeFundingStartTime();
    error PastFundingDeadline();
    error InvalidFundingInput();
    error Unauthorized();

    modifier onlyBeneficiary() {
        if (msg.sender != beneficiary) revert Unauthorized();
        _;
    }

    modifier onlyRefundEnabled() {
        if (!isRefundEnabled) revert Unauthorized();
        _;
    }

    constructor() Ownable(msg.sender) {}

    function initialize(
        address _projectToken,
        uint256 _fundingStartTime,
        uint256 _fundingDeadline,
        ICOVaultExchangeRateDataSource _dataSource
    ) external initializer onlyOwner {
        projectToken = _projectToken;
        fundingStartTime = _fundingStartTime;
        fundingDeadline = _fundingDeadline;
        dataSource = _dataSource;
        IVotes(_projectToken).getVotes(address(0)); // To make sure the project token is ERC20Votes
    }

    function fund(address asset, uint256 amount) external payable nonReentrant {
        if (block.timestamp < fundingStartTime) revert BeforeFundingStartTime();
        if (block.timestamp > fundingDeadline) revert PastFundingDeadline();
        if (asset != address(0) && msg.value > 0) revert InvalidFundingInput();
        AssetInfo storage a = assetInfo[asset];
        if (a.lastWithdrawal == 0) {
            a.lastWithdrawal = fundingDeadline;
        }
        uint256 amountToSend;
        if (asset != address(0)) {
            IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);
            investments[asset][msg.sender] += amount;
            a.peakBalance += amount;
            amountToSend = dataSource.tokensPerFundingUnit(asset) * amount;
            emit FundAdded(asset, amount, amountToSend);
        } else if (msg.value > 0) {
            investments[address(0)][msg.sender] += msg.value;
            a.peakBalance += msg.value;
            amountToSend = dataSource.tokensPerFundingUnit() * amount;
            emit FundAdded(address(0), msg.value, amountToSend);
        }
        IERC20(projectToken).safeTransfer(msg.sender, amountToSend);
    }

    function setRate(address asset, uint256 flowRate) external onlyOwner {
        AssetInfo storage a = assetInfo[asset];
        emit FlowRateChanged(asset, a.flowRate, flowRate);
        a.flowRate = flowRate;
    }

    function setBeneficiary(address _beneficiary) external onlyOwner {
        emit BeneficiaryChanged(beneficiary, _beneficiary);
        beneficiary = _beneficiary;
    }

    function withdraw(address asset) external onlyBeneficiary {
        AssetInfo storage a = assetInfo[asset];
        uint256 amountWithdrawable = calculateAmountWithdrawable(asset);
        a.spentBalance += amountWithdrawable;
        if (asset == address(0)) {
            (bool sent, bytes memory data) = payable(beneficiary).call{
                value: amountWithdrawable
            }("");
            // solhint-disable-nextline custom-errors
            require(sent, string(data));
        } else {
            IERC20(asset).safeTransfer(beneficiary, amountWithdrawable);
        }
        emit FundsWithdrawn(asset, amountWithdrawable);
    }

    function enableRefund() external onlyOwner {
        isRefundEnabled = true;
        emit RefundEnabled();
    }

    function refund(address asset) external onlyRefundEnabled {
        uint256 amountRefundable = calculateAmountRefundable(asset, msg.sender);
        if (asset == address(0)) {
            (bool sent, bytes memory data) = payable(msg.sender).call{
                value: amountRefundable
            }("");
            // solhint-disable-nextline custom-errors
            require(sent, string(data));
        } else {
            IERC20(asset).safeTransfer(msg.sender, amountRefundable);
        }
        emit FundsRefunded(asset, msg.sender, amountRefundable);
    }

    function calculateAmountWithdrawable(
        address asset
    ) public view returns (uint256) {
        AssetInfo memory a = assetInfo[asset];
        uint256 amountWithdrawable = (block.timestamp - a.lastWithdrawal) *
            a.flowRate;
        uint256 maxAmountWithdrawable = a.peakBalance - a.spentBalance;
        return
            amountWithdrawable > maxAmountWithdrawable
                ? maxAmountWithdrawable
                : amountWithdrawable;
    }

    function calculateAmountRefundable(
        address asset,
        address investor
    ) public view returns (uint256) {
        AssetInfo memory a = assetInfo[asset];
        return
            ((a.peakBalance - a.spentBalance) * investments[asset][investor]) /
            a.peakBalance;
    }
}
