// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

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

    // token => investor => amount
    mapping(address => mapping(address => uint256)) public investments;
    // token => amount
    mapping(address => AssetInfo) public assetInfo;

    event FundAdded(address asset, uint256 amount, uint256 amountOffered);
    event FlowRateChanged(address asset, uint256 oldRate, uint256 newRate);
    event BeneficiaryChanged(address oldBeneficiary, address newBeneficiary);
    event FundsWithdrawn(address asset, uint256 amount);

    error BeforeFundingStartTime();
    error PastFundingDeadline();
    error InvalidFundingInput();
    error Unauthorized();

    modifier onlyBeneficiary() {
        if (msg.sender != beneficiary) revert Unauthorized();
        _;
    }

    constructor() Ownable(msg.sender) {}

    function initialize(
        address _projectToken,
        uint256 _fundingStartTime,
        uint256 _fundingDeadline,
        ICOVaultExchangeRateDataSource _dataSource
    ) external initializer {
        projectToken = _projectToken;
        fundingStartTime = _fundingStartTime;
        fundingDeadline = _fundingDeadline;
        dataSource = _dataSource;
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
}
