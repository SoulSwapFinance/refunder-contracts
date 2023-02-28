// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "../src/forge/Script.sol";
import "../src/Refunder.sol";

contract RefunderScript is Script {

    IERC20 public BNB_BOND = IERC20(0xbDa9204e6D596feCf9bd48108723F9BDAa2019f6);
    IERC20 public DAI_BOND = IERC20(0xFD9BE6a83c7e9cFF48f6D9a3036bb6b20598ED61);
    IERC20 public ETH_BOND = IERC20(0x9fA5de19495331E13b443F787B90CdD22B32263d);
    IERC20 public FTM_BOND = IERC20(0xF4Bfdd73FE65D1B46b9968A24443A77ab89908dd);

    IERC20 public BNB = IERC20(0xD67de0e0a0Fd7b15dC8348Bb9BE742F3c5850454);
    IERC20 public DAI = IERC20(0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E);
    IERC20 public ETH = IERC20(0x74b23882a30290451A17c44f4F05243b6b58C76d);
    IERC20 public FTM = IERC20(0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83);

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PK");
        vm.startBroadcast(deployerPrivateKey);

        Refunder refunder = new Refunder(
            0xFd63Bf84471Bc55DD9A83fdFA293CCBD27e1F4C8,
            address(BNB_BOND), address(BNB),
            address(DAI_BOND), address(DAI),
            address(ETH_BOND), address(ETH),
            address(FTM_BOND), address(FTM)
        );

        // silences warning.
        refunder;

        vm.stopBroadcast();
    }
}
