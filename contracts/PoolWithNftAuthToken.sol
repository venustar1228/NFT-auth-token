pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import { NftAuthToken } from "./NftAuthToken.sol";

import { IMasset } from "./@mstable/protocol/contracts/interfaces/IMasset.sol";
import { IMStableHelper } from "./@mstable/protocol/contracts/interfaces/IMStableHelper.sol";
import { ISavingsContract } from "./@mstable/protocol/contracts/interfaces/ISavingsContract.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 }  from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";


/***
 * Allows participants to stake mUSD and have the
 * interest from SAVE be distributed to a specified beneficiary
 **/
contract PoolWithNftAuthToken {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    IERC20 public mUSD;
    ISavingsContract public save;
    IMStableHelper public helper;

    mapping(address => uint256) public pooledAmounts;  /// For individual
    uint256 totalPooledAmounts = 0;                    /// For total

    event AmountStaked(address indexed staker, uint256 amount);
    event AmountWithdrawn(address indexed staker, uint256 amount);
    event InterestCollected(uint256 amount);

    constructor(
        IERC20 _mUSD,
        ISavingsContract _save,
        IMStableHelper _helper,
        address _beneficiary
    )
        public
        //Ownable()
    {
        mUSD = _mUSD;
        save = _save;
        helper = _helper;

        /// Transfer ownership into beneficary
        //_transferOwnership(_beneficiary);

        mUSD.safeApprove(address(save), uint256(-1));
    }

    /***
     * @notice - Stake an amount of mUSD and deposit into SAVE
     **/
    function _stakeIntoPool(
        uint256 _amount
    )
        internal
        //external
    {
        // Either we are depositing mUSD or we can mint as follows
        // IMasset(_mUSD).mint(<bAsset>, <bAssetQuanity>);

        /// Transferring from sender
        mUSD.safeTransferFrom(msg.sender, address(this), _amount);

        /// Depositing into SAVE
        save.depositSavings(_amount);

        /// Tracking the pooled amounts
        pooledAmounts[msg.sender] += _amount;
        totalPooledAmounts += _amount;

        emit AmountStaked(msg.sender, _amount);
    }

    /***
     * @notice - Withdraw the staked mUSD
     **/
    function _withdrawFromPool(
        uint256 _amount
    )
        internal
        //external
    {
        /// Check balance
        uint256 poolBalance = pooledAmounts[msg.sender];
        require(_amount <= poolBalance, "Not enough balance");

        /// Reduce the storage
        pooledAmounts[msg.sender] -= _amount;
        totalPooledAmounts -= _amount;

        uint256 creditsToRedeem = helper.getSaveRedeemInput(save, _amount);
        save.redeem(creditsToRedeem);

        // Either we return the mUSD or we could redeem into something
        // bAsset = helper.getRedeemBasset();
        // IMasset(mUSD).redeem(<bAsset>, <bAssetQuanity>);

        mUSD.transfer(msg.sender, _amount);

        emit AmountWithdrawn(msg.sender, _amount);
    }

    /***
     * @notice - Distribute any of the accrued interest to the beneficiary
     **/
    function _collectInterest(address beneficiary) 
        internal
        //external 
    {
        /// Check balance of this address (contract address)
        uint256 currentBalance = helper.getSaveBalance(save, address(this));
        uint256 delta = currentBalance - totalPooledAmounts;

        uint256 creditsToRedeem = helper.getSaveRedeemInput(save, delta);
        save.redeem(creditsToRedeem);

        mUSD.transfer(beneficiary, delta);
        //mUSD.transfer(owner(), delta);

        emit InterestCollected(delta);
    }

}
