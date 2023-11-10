// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import {ICOVaultExchangeRateDataSource} from "./interfaces/ICOVaultExchangeRateDataSource.sol";
import {DAICOCustom} from "./interfaces/DAICOCustom.sol";

struct AssetInfo {
    uint256 peakBalance;
    uint256 spentBalance;
    uint256 flowRate;
    uint256 lastCheckpoint;
    uint256 pendingBalanceAtLastCheckpoint;
}

contract ICOVault is
    DAICOCustom,
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20 for IERC20;

    address public projectToken;
    address public fundingAsset;
    ICOVaultExchangeRateDataSource public dataSource;
    uint256 public fundingStartTime;
    uint256 public fundingDeadline;
    address public beneficiary;
    bool public isRefundEnabled;

    AssetInfo public etherAssetInfo;
    AssetInfo public erc20AssetInfo;

    // asset => investor => amount
    mapping(address => mapping(address => uint256)) public investments;

    event FundAdded(
        address asset,
        address investor,
        uint256 amount,
        uint256 amountOffered
    );
    event FlowRateChanged(address asset, uint256 oldRate, uint256 newRate);
    event BeneficiaryChanged(address oldBeneficiary, address newBeneficiary);
    event FundsWithdrawn(address asset, uint256 amount);
    event RefundEnabled();
    event FundsRefunded(address asset, address investor, uint256 amount);

    error BeforeFundingStartTime();
    error PastFundingDeadline();
    error InvalidFundingInput();
    error Unauthorized();
    error Unimplemented();

    modifier onlyBeneficiary() {
        if (msg.sender != beneficiary) revert Unauthorized();
        _;
    }

    modifier onlyRefundEnabled() {
        if (!isRefundEnabled) revert Unauthorized();
        _;
    }

    constructor() {
        _disableInitializers();
    }

    function initialize(bytes calldata data) public initializer {
        (
            address _projectToken,
            address _fundingAsset,
            uint256 _fundingStartTime,
            uint256 _fundingDeadline,
            uint256 _etherInitialFlowRate,
            uint256 _erc20InitialFlowRate,
            address _initialBeneficiary,
            ICOVaultExchangeRateDataSource _dataSource
        ) = abi.decode(
                data,
                (
                    address,
                    address,
                    uint256,
                    uint256,
                    uint256,
                    uint256,
                    address,
                    ICOVaultExchangeRateDataSource
                )
            );
        projectToken = _projectToken;
        fundingAsset = _fundingAsset;
        fundingStartTime = _fundingStartTime;
        fundingDeadline = _fundingDeadline;
        dataSource = _dataSource;
        etherAssetInfo.flowRate = _etherInitialFlowRate;
        etherAssetInfo.lastCheckpoint = _fundingDeadline;
        erc20AssetInfo.flowRate = _erc20InitialFlowRate;
        erc20AssetInfo.lastCheckpoint = _fundingDeadline;
        beneficiary = _initialBeneficiary;
        IVotes(_projectToken).getVotes(address(0)); // To make sure the project token is ERC20Votes
        __ReentrancyGuard_init_unchained();
        __Ownable_init_unchained(msg.sender);
    }

    // solhint-disable-next-line ordering
    function fund(address asset, uint256 amount) external payable nonReentrant {
        if (block.timestamp < fundingStartTime) revert BeforeFundingStartTime();
        if (block.timestamp > fundingDeadline) revert PastFundingDeadline();
        if (
            (asset != address(0) && msg.value > 0) ||
            (asset != address(0) && asset != fundingAsset) ||
            (asset == address(0) && msg.value == 0)
        ) revert InvalidFundingInput();
        AssetInfo storage a = _getAssetInfo(asset);
        uint256 amountToSend;
        if (asset != address(0)) {
            IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);
            investments[asset][msg.sender] += amount;
            a.peakBalance += amount;
            amountToSend = dataSource.tokensPerFundingUnit(asset) * amount;
            emit FundAdded(asset, msg.sender, amount, amountToSend);
        } else if (msg.value > 0) {
            investments[address(0)][msg.sender] += msg.value;
            a.peakBalance += msg.value;
            amountToSend = dataSource.tokensPerFundingUnit(asset) * amount;
            emit FundAdded(asset, msg.sender, msg.value, amountToSend);
        }
        IERC20(projectToken).safeTransfer(msg.sender, amountToSend);
    }

    function setRate(address asset, uint256 flowRate) external onlyOwner {
        checkpoint(asset);
        AssetInfo storage a = _getAssetInfo(asset);
        emit FlowRateChanged(asset, a.flowRate, flowRate);
        a.flowRate = flowRate;
    }

    function setBeneficiary(address _beneficiary) external onlyOwner {
        emit BeneficiaryChanged(beneficiary, _beneficiary);
        beneficiary = _beneficiary;
    }

    function withdraw(address asset) external onlyBeneficiary {
        AssetInfo storage a = _getAssetInfo(asset);
        checkpoint(asset);
        uint256 amountWithdrawable = a.pendingBalanceAtLastCheckpoint;
        a.spentBalance += amountWithdrawable;
        a.pendingBalanceAtLastCheckpoint = 0;
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
        if (block.timestamp < fundingDeadline) revert Unauthorized();
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

    function version_ethsign() external pure returns (string memory) {
        return "0.0.1";
    }

    function transferOwnership(
        address newOwner
    ) public virtual override(DAICOCustom, OwnableUpgradeable) {
        OwnableUpgradeable.transferOwnership(newOwner);
    }

    function checkpoint(address asset) public {
        AssetInfo storage a = _getAssetInfo(asset);
        uint256 pendingBalanceSinceLastCheckpoint = (block.timestamp -
            a.lastCheckpoint) * a.flowRate;
        uint256 totalPendingBalance = a.pendingBalanceAtLastCheckpoint +
            pendingBalanceSinceLastCheckpoint;
        uint256 maxPendingBalance = a.peakBalance - a.spentBalance;
        a.lastCheckpoint = block.timestamp;
        a.pendingBalanceAtLastCheckpoint = totalPendingBalance >
            maxPendingBalance
            ? maxPendingBalance
            : totalPendingBalance;
    }

    function calculateAmountRefundable(
        address asset,
        address investor
    ) public view returns (uint256) {
        AssetInfo memory a = _getAssetInfo(asset);
        return
            ((a.peakBalance -
                a.spentBalance -
                a.pendingBalanceAtLastCheckpoint) *
                investments[asset][investor]) / a.peakBalance;
    }

    function _getAssetInfo(
        address asset
    ) internal view returns (AssetInfo storage) {
        AssetInfo storage a;
        if (asset == fundingAsset) {
            a = erc20AssetInfo;
        } else if (asset == address(0)) {
            a = etherAssetInfo;
        } else {
            revert Unimplemented();
        }
        return a;
    }
}
