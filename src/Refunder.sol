// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Distributor is Ownable {
    using SafeERC20 for IERC20;
    address public DAO = 0x1C63C726926197BD3CB75d86bCFB1DaeBcD87250;

    IERC20 public BNB_BOND = IERC20(0xbDa9204e6D596feCf9bd48108723F9BDAa2019f6);
    IERC20 public DAI_BOND = IERC20(0xFD9BE6a83c7e9cFF48f6D9a3036bb6b20598ED61);
    IERC20 public ETH_BOND = IERC20(0x9fA5de19495331E13b443F787B90CdD22B32263d);
    IERC20 public FTM_BOND = IERC20(0xF4Bfdd73FE65D1B46b9968A24443A77ab89908dd);

    IERC20 public BNB = IERC20(0xD67de0e0a0Fd7b15dC8348Bb9BE742F3c5850454);
    IERC20 public DAI = IERC20(0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E);
    IERC20 public ETH = IERC20(0x74b23882a30290451A17c44f4F05243b6b58C76d);
    IERC20 public FTM = IERC20(0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83);

    event Returned(address asset, address dao, uint amount);
    event Refunded(address asset, address sender, uint amount);

    struct Bonds {
        string name;
        IERC20 pair;
        IERC20 asset;
    }

    // bond info
    Bonds[] public bondInfo; 

    constructor() {
        // creates: new Bonds (alphabetically).
        bondInfo.push(Bonds({
            name: 'BNB-DAI',
            pair: BNB_BOND,
            asset: BNB
        }));

        bondInfo.push(Bonds({
            name: 'DAI-FTM',
            pair: DAI_BOND,
            asset: DAI
        }));

        bondInfo.push(Bonds({
            name: 'ETH-DAI',
            pair: ETH_BOND,
            asset: ETH
        }));

        bondInfo.push(Bonds({
            name: 'FTM-DAI',
            pair: FTM_BOND,
            asset: FTM
        }));

    }

    function refund(uint id, uint amount) public {
        Bonds storage bond = bondInfo[id];
        IERC20 Asset = bond.asset;
        IERC20 Pair = bond.pair;

        // [c] checks: availability & balances.
        uint oldBalance = Asset.balanceOf(address(this));
        require(_checkAvailability(address(Asset), amount), 'unavailable');
        require(Asset.balanceOf(msg.sender) >= amount, 'insufficient balance');

        // [i] sends: pair to DAO.
        Pair.safeTransferFrom(msg.sender, DAO, amount);
        // [i] sends: asset to sender.
        Asset.safeTransfer(msg.sender, amount);

        // [e] validates: only the exact amount is withdrawn.
        uint newBalance = Asset.balanceOf(address(this));
        require(newBalance == oldBalance + amount, 'new balance is invalid'); 

        emit Refunded(address(Asset), msg.sender, amount);
    }

    function _checkAvailability(address asset, uint amount) internal view returns (bool) {
        require(IERC20(asset).balanceOf(address(this)) >= amount, 'insufficient balance');

        return true;
    }

    function returnFunds(uint id) public onlyOwner {
        Bonds storage bond = bondInfo[id];
        IERC20 Asset = bond.asset;

        Asset.safeTransfer(DAO, Asset.balanceOf(address(this)));

        emit Returned(address(Asset), DAO, Asset.balanceOf(address(this)));
    }

    function setDAO(address _DAO) public onlyOwner {
        DAO = _DAO;
    }
 }