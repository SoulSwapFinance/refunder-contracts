// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Refunder is Ownable {
    using SafeERC20 for IERC20;
    address public DAO = 0x1C63C726926197BD3CB75d86bCFB1DaeBcD87250;

    IERC20 public BNB_PAIR = IERC20(0xbDa9204e6D596feCf9bd48108723F9BDAa2019f6);
    IERC20 public DAI_PAIR = IERC20(0xFD9BE6a83c7e9cFF48f6D9a3036bb6b20598ED61);
    IERC20 public ETH_PAIR = IERC20(0x9fA5de19495331E13b443F787B90CdD22B32263d);
    IERC20 public FTM_PAIR = IERC20(0xF4Bfdd73FE65D1B46b9968A24443A77ab89908dd);

    IERC20 public BNB = IERC20(0xD67de0e0a0Fd7b15dC8348Bb9BE742F3c5850454);
    IERC20 public DAI = IERC20(0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E);
    IERC20 public ETH = IERC20(0x74b23882a30290451A17c44f4F05243b6b58C76d);
    IERC20 public FTM = IERC20(0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83);

    event Returned(address asset, address dao, uint amount);
    event Refunded(address asset, address sender, uint amount);

    struct Markets {
        string name;
        IERC20 pair;
        IERC20 asset;
    }

    // market info
    Markets[] public marketInfo; 

    constructor() {

        // creates: new Markets (alphabetically).
        marketInfo.push(Markets({
            name: 'BNB-DAI',
            pair: BNB_PAIR,
            asset: BNB
        }));

        marketInfo.push(Markets({
            name: 'DAI-FTM',
            pair: DAI_PAIR,
            asset: DAI
        }));

        marketInfo.push(Markets({
            name: 'ETH-DAI',
            pair: ETH_PAIR,
            asset: ETH
        }));

        marketInfo.push(Markets({
            name: 'FTM-DAI',
            pair: FTM_PAIR,
            asset: FTM
        }));

    }

    function refund(uint id, uint amount) public {
        Markets storage market = marketInfo[id];
        IERC20 Asset = market.asset;
        IERC20 Pair = market.pair;

        // [c] checks: availability & balances.
        require(_checkAvailability(address(Asset), amount), 'unavailable');
        require(Asset.balanceOf(msg.sender) >= amount, 'insufficient balance');

        // [i] sends: pair to DAO.
        Pair.safeTransferFrom(msg.sender, DAO, amount);
        // [i] sends: asset to sender.
        Asset.safeTransfer(msg.sender, amount);

        emit Refunded(address(Asset), msg.sender, amount);
    }

    function _checkAvailability(address asset, uint amount) internal view returns (bool) {
        require(IERC20(asset).balanceOf(address(this)) >= amount, 'insufficient balance');

        return true;
    }
    
    function showRefundable(uint id, address account) external view returns (uint refundable) {
        Markets storage market = marketInfo[id];
        IERC20 Pair = market.pair;

        refundable = Pair.balanceOf(account);
    }

    function showAvailable(uint id) external view returns (uint available) {
        Markets storage market = marketInfo[id];
        IERC20 Asset = market.asset;

        available = Asset.balanceOf(address(this));
    }

    function returnFunds(uint id) public onlyOwner {
        Markets storage market = marketInfo[id];
        IERC20 Asset = market.asset;

        Asset.safeTransfer(DAO, Asset.balanceOf(address(this)));

        emit Returned(address(Asset), DAO, Asset.balanceOf(address(this)));
    }

    function setDAO(address _DAO) public onlyOwner {
        DAO = _DAO;
    }

    function transferOut(address assetAddress) public onlyOwner {
        IERC20 Asset = IERC20(assetAddress);
        Asset.safeTransfer(owner(), Asset.balanceOf(address(this)));
    }
 }