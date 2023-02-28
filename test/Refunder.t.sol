// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "./setup/c.t.sol";

contract ManifesterTest is Test, c {
    address public REFUNDER_ADDRESS;
    address public DAO_ADDRESS = 0x1C63C726926197BD3CB75d86bCFB1DaeBcD87250;

    function deployContracts() public virtual {


        // deploys: Dai Token & Lending Pair
        c.dai = new MockToken(
            "Dai Stablecoin",
            "DAI",
            c.initialSupply                     // totalSupply
        );
        c.daiLend = new MockToken(
            "DAI-WFTM Pair",
            "DAI-WFTM",
            c.initialSupply                     // totalSupply
        );

        // deploys: Binance Token & Lending Pair
        c.bnb = new MockToken(
            "Binance Coin",
            "BNB",
            c.initialSupply                     // totalSupply
        );
        c.bnbLend = new MockToken(
            "BNB-DAI Pair",
            "BNB-DAI",
            c.initialSupply                     // totalSupply
        );

        // deploys: Eth Token & Lending Pair
        c.eth = new MockToken(
            "Wrapped Ethereum",
            "WETH",
            c.initialSupply                     // totalSupply
        );
        c.ethLend = new MockToken(
            "WETH-DAI Pair",
            "WETH-DAI",
            c.initialSupply                     // totalSupply
        );

        // deploys: Native Token & Lending Pair
        c.ftm = new MockToken(
            "Wrapped Fantom",
            "WFTM",
            c.initialSupply                     // totalSupply
        );
        c.ftmLend = new MockToken(
            "WFTM-DAI Pair",
            "WFTM-DAI",
            c.initialSupply                     // totalSupply
        );

        address BNB = address(bnb);
        address BNB_LEND = address(bnbLend);
        address DAI = address(dai);
        address DAI_LEND = address(daiLend);
        address ETH = address(eth);
        address ETH_LEND = address(ethLend);
        address FTM = address(ftm);
        address FTM_LEND = address(ftmLend);

        // deploys: Mock Factory
        c.refunder = new Refunder(
            DAO_ADDRESS,
            BNB_LEND, BNB,
            DAI_LEND, DAI, 
            ETH_LEND, ETH, 
            FTM_LEND, FTM
        );

        // sets: Refunder Address
       REFUNDER_ADDRESS = address(refunder);

    }

    function setUp() public virtual {
        deployContracts();

        bnb.transfer(REFUNDER_ADDRESS, c.ONE_THOUSAND);
        dai.transfer(REFUNDER_ADDRESS, c.ONE_THOUSAND);
        eth.transfer(REFUNDER_ADDRESS, c.ONE_THOUSAND);
        ftm.transfer(REFUNDER_ADDRESS, c.ONE_THOUSAND);

    }

    function readBalances() public view returns (
        uint bnbBalance,
        uint daiBalance,
        uint ethBalance,
        uint ftmBalance
    ) {

        bnbBalance = bnb.balanceOf(REFUNDER_ADDRESS);
        daiBalance = dai.balanceOf(REFUNDER_ADDRESS);
        ethBalance = eth.balanceOf(REFUNDER_ADDRESS);
        ftmBalance = ftm.balanceOf(REFUNDER_ADDRESS);
    }

    /*/ CONTRACT TESTS /*/
    // Transfer Assets
    function testTransfer() public virtual {
        setUp();

        uint expected = c.ONE_THOUSAND;
        // actuals
        (uint bnb_a, uint dai_a, uint eth_a, uint ftm_a) = readBalances();

        assertEq(bnb_a, expected, "ok");
        assertEq(dai_a, expected, "ok");
        assertEq(eth_a, expected, "ok");
        assertEq(ftm_a, expected, "ok");
    }
    // Deploy Refunder
    function testCreation() public {
        deployContracts();
        address deployedAddress = address(refunder);
        bool expected = true;
        bool actual = deployedAddress != address(0);
        // expect the address to not be the zero address //
        assertEq(actual, expected, "ok");
        console.log("[+] deployedAddress: %s", deployedAddress);
    }

    // Return Funds
    function testReturnFunds() public {
        setUp();
        uint expected_before = c.ONE_THOUSAND;
        uint expected_after = c.ZERO;

        (uint bnb_a0, uint dai_a0, uint eth_a0, uint ftm_a0) = readBalances();
        assertEq(bnb_a0, expected_before, "ok");
        assertEq(dai_a0, expected_before, "ok");
        assertEq(eth_a0, expected_before, "ok");
        assertEq(ftm_a0, expected_before, "ok");
        console.log('contract successfully loaded with 1,000 of each asset.');

        // executes: returnFunds(id) function.
        refunder.returnFunds(0);
        refunder.returnFunds(1);
        refunder.returnFunds(2);
        refunder.returnFunds(3);
        
        // actuals
        (uint bnb_a, uint dai_a, uint eth_a, uint ftm_a) = readBalances();

        assertEq(bnb_a, expected_after, "ok");
        assertEq(dai_a, expected_after, "ok");
        assertEq(eth_a, expected_after, "ok");
        assertEq(ftm_a, expected_after, "ok");
        console.log('contract successfully emptied of assets.');
    }

    // Transfers Out (stuck assets)
    function testTransferOut() public {
        setUp();
        uint preBalance = dai.balanceOf(REFUNDER_ADDRESS);
        assertEq(preBalance, c.ONE_THOUSAND, "ok");
        console.log('refunder is loaded with 1,000 DAI.');
        // executes: transferOut(address) function.
        refunder.transferOut(address(dai));
        uint postBalance = dai.balanceOf(REFUNDER_ADDRESS);
        assertEq(postBalance, c.ZERO, "ok");

        console.log('refunder now emptied.');
    }

    // 
    function testRefund() public {
        setUp();
        // checks: pre balances (bnb)
        uint r_assetBalance_0 = bnb.balanceOf(REFUNDER_ADDRESS);
        uint r_lendBalance_0 = bnbLend.balanceOf(REFUNDER_ADDRESS);
    
        uint s_assetBalance_0 = bnb.balanceOf(address(this));
        uint s_lendBalance_0 = bnbLend.balanceOf(address(this));

        uint d_assetBalance_0 = bnb.balanceOf(DAO_ADDRESS);
        uint d_lendBalance_0 = bnbLend.balanceOf(DAO_ADDRESS);

        // refunds bnbLend -> bnb
        bnbLend.approve(REFUNDER_ADDRESS, c.ONE_THOUSAND);
        refunder.refund(0, c.ONE_THOUSAND);

        // checks: post balances (bnb)
        uint r_assetBalance_1 = bnb.balanceOf(REFUNDER_ADDRESS);
        uint r_lendBalance_1 = bnbLend.balanceOf(REFUNDER_ADDRESS);

        uint s_assetBalance_1 = bnb.balanceOf(address(this));
        uint s_lendBalance_1 = bnbLend.balanceOf(address(this));

        uint d_assetBalance_1 = bnb.balanceOf(DAO_ADDRESS);
        uint d_lendBalance_1 = bnbLend.balanceOf(DAO_ADDRESS);

        console.log(' -- refunder results --'); 
        console.log('asset: %s --> %s', r_assetBalance_0 / 1E18, r_assetBalance_1 / 1E18);
        console.log('lend: %s --> %s', r_lendBalance_0 / 1E18, r_lendBalance_1 / 1E18);
        console.log(' -- sender results --'); 
        console.log('asset: %s --> %s', s_assetBalance_0 / 1E18, s_assetBalance_1 / 1E18);
        console.log('lend: %s --> %s', s_lendBalance_0 / 1E18, s_lendBalance_1 / 1E18);
        console.log(' -- dao results --'); 
        console.log('asset: %s --> %s', d_assetBalance_0 / 1E18, d_assetBalance_1 / 1E18);
        console.log('lend: %s --> %s', d_lendBalance_0 / 1E18, d_lendBalance_1 / 1E18);

    }

}
