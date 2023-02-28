// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

contract MockRefunder is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
 
    address public DAO = 0x1C63C726926197BD3CB75d86bCFB1DaeBcD87250;
    bool public isActive;

    address public BNB_PAIR; // = 0xbDa9204e6D596feCf9bd48108723F9BDAa2019f6;
    address public DAI_PAIR; // = 0xFD9BE6a83c7e9cFF48f6D9a3036bb6b20598ED61;
    address public ETH_PAIR; // = 0x9fA5de19495331E13b443F787B90CdD22B32263d;
    address public FTM_PAIR; // = 0xF4Bfdd73FE65D1B46b9968A24443A77ab89908dd;

    address public BNB; // = 0xD67de0e0a0Fd7b15dC8348Bb9BE742F3c5850454;
    address public DAI; // = 0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E;
    address public ETH; // = 0x74b23882a30290451A17c44f4F05243b6b58C76d;
    address public FTM; // = 0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83;

    event Returned(address asset, address dao, uint amount);
    event Refunded(address asset, address sender, uint amount);

    struct Markets {
        string name;
        IERC20 pair;
        IERC20 asset;
    }

    // market info
    Markets[] public marketInfo; 

    constructor(
            address _BNB_PAIR, address _BNB,
            address _DAI_PAIR, address _DAI, 
            address _ETH_PAIR, address _ETH, 
            address _FTM_PAIR, address _FTM
    ) {

        // creates: new Markets (alphabetically).
        marketInfo.push(Markets({
            name: 'BNB-DAI',
            pair: IERC20(_BNB_PAIR),
            asset: IERC20(_BNB)
        }));

        marketInfo.push(Markets({
            name: 'DAI-FTM',
            pair: IERC20(_DAI_PAIR),
            asset: IERC20(_DAI)
        }));

        marketInfo.push(Markets({
            name: 'ETH-DAI',
            pair: IERC20(_ETH_PAIR),
            asset: IERC20(_ETH)
        }));

        marketInfo.push(Markets({
            name: 'FTM-DAI',
            pair: IERC20(_FTM_PAIR),
            asset: IERC20(_FTM)
        }));

    }

    function refund(uint id, uint amount) public nonReentrant {
        require(isActive, 'refunds have not yet begun');
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

    function returnFunds(uint id) public onlyOwner {
        Markets storage market = marketInfo[id];
        IERC20 Asset = market.asset;

        Asset.safeTransfer(DAO, Asset.balanceOf(address(this)));

        emit Returned(address(Asset), DAO, Asset.balanceOf(address(this)));
    }

    function setDAO(address _DAO) public onlyOwner {
        DAO = _DAO;
    }

    function toggleActive(bool enabled) public onlyOwner {
        isActive = enabled;
    }

    function transferOut(address assetAddress) public onlyOwner {
        IERC20 Asset = IERC20(assetAddress);
        Asset.safeTransfer(owner(), Asset.balanceOf(address(this)));
    }
 }