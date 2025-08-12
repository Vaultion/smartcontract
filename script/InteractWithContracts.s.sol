// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {VaultionToken} from "../contracts/VaultionToken.sol";
import {MockERC20} from "../src/MockERC20.sol";
import {BoringVault} from "../src/BoringVault.sol";
import {RewardManager} from "../src/RewardManager.sol";
import {SimpleStrategy} from "../src/SimpleStrategy.sol";
import {VaultAllocator} from "../src/VaultAllocator.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract InteractWithContracts is Script {
    // Deployed contract addresses
    VaultionToken constant vltn = VaultionToken(0x4EE6eCAD1c2Dae9f525404De8555724e3c35d07B);
    MockERC20 constant usdc = MockERC20(0xBEc49fA140aCaA83533fB00A2BB19bDdd0290f25);
    MockERC20 constant usdt = MockERC20(0xD84379CEae14AA33C123Af12424A37803F885889);
    RewardManager constant rewardManager = RewardManager(0x46b142DD1E924FAb83eCc3c08e4D46E82f005e0E);
    BoringVault constant vaultUSDC = BoringVault(0xC9a43158891282A2B1475592D5719c001986Aaec);
    BoringVault constant vaultUSDT = BoringVault(0x1c85638e118b37167e9298c2268758e058DdfDA0);
    BoringVault constant vaultVLTN = BoringVault(0x367761085BF3C12e5DA2Df99AC6E1a824612b8fb);
    SimpleStrategy constant strategyUSDC = SimpleStrategy(0x4C2F7092C2aE51D986bEFEe378e50BD4dB99C901);
    SimpleStrategy constant strategyUSDT = SimpleStrategy(0x7A9Ec1d04904907De0ED7b6839CcdD59c3716AC9);
    VaultAllocator constant allocator = VaultAllocator(0x49fd2BE640DB2910c2fAb69bB8531Ab6E76127ff);

    function run() external {
        uint256 userPrivateKey = vm.envUint("PRIVATE_KEY");
        address user = vm.addr(userPrivateKey);

        vm.startBroadcast(userPrivateKey);

        console.log("=== CONTRACT INTERACTION SCRIPT ===");
        console.log("User address:", user);
        
        // Display current balances
        displayBalances(user);

        // Example interactions - uncomment the ones you want to execute
        
        // === INDEXER EVENT SIMULATION ===
        // Uncomment to simulate events for the indexer
        simulateIndexerEvents(user);
        
        // === INDIVIDUAL INTERACTIONS ===
        // 1. Mint some tokens to user (if user is deployer)
        // mintTokensToUser(user);
        
        // 2. Deposit into USDC vault
        // depositIntoUSDCVault(user, 1000 * 1e18); // 1000 USDC
        
        // 3. Deposit into USDT vault
        // depositIntoUSDTVault(user, 500 * 1e18); // 500 USDT
        
        // 4. Check vault shares and rewards
        // checkVaultInfo(user);
        
        // 5. Claim rewards
        // claimRewards(user);
        
        // 6. Withdraw from vaults
        // withdrawFromVaults(user);

        vm.stopBroadcast();
    }

    function displayBalances(address user) public view {
        console.log("\n=== CURRENT BALANCES ===");
        console.log("USDC balance:", usdc.balanceOf(user) / 1e18);
        console.log("USDT balance:", usdt.balanceOf(user) / 1e18);
        console.log("VLTN balance:", vltn.balanceOf(user) / 1e18);
        console.log("Vault USDC shares:", vaultUSDC.userShares(user) / 1e18);
        console.log("Vault USDT shares:", vaultUSDT.userShares(user) / 1e18);
        console.log("Vault VLTN shares:", vaultVLTN.userShares(user) / 1e18);
        console.log("========================");
    }

    function mintTokensToUser(address user) public {
        console.log("\n=== MINTING TOKENS ===");
        // Mint tokens to user for testing (only works if user has permission)
        usdc.mint(user, 10000 * 1e18); // 10,000 USDC
        usdt.mint(user, 10000 * 1e18); // 10,000 USDT
        console.log("Minted 10,000 USDC and 10,000 USDT to user");
    }

    function depositIntoUSDCVault(address user, uint256 amount) public {
        console.log("\n=== DEPOSITING INTO USDC VAULT ===");
        console.log("Depositing amount:", amount / 1e18, "USDC");
        
        // Check allowance
        uint256 allowance = usdc.allowance(user, address(vaultUSDC));
        if (allowance < amount) {
            console.log("Approving USDC for vault...");
            usdc.approve(address(vaultUSDC), type(uint256).max);
        }
        
        uint256 sharesBefore = vaultUSDC.userShares(user);
        vaultUSDC.deposit(amount, user);
        uint256 sharesAfter = vaultUSDC.userShares(user);
        
        console.log("Received shares:", (sharesAfter - sharesBefore) / 1e18);
        console.log("Deposit successful!");
    }

    function depositIntoUSDTVault(address user, uint256 amount) public {
        console.log("\n=== DEPOSITING INTO USDT VAULT ===");
        console.log("Depositing amount:", amount / 1e18, "USDT");
        
        // Check allowance
        uint256 allowance = usdt.allowance(user, address(vaultUSDT));
        if (allowance < amount) {
            console.log("Approving USDT for vault...");
            usdt.approve(address(vaultUSDT), type(uint256).max);
        }
        
        uint256 sharesBefore = vaultUSDT.userShares(user);
        vaultUSDT.deposit(amount, user);
        uint256 sharesAfter = vaultUSDT.userShares(user);
        
        console.log("Received shares:", (sharesAfter - sharesBefore) / 1e18);
        console.log("Deposit successful!");
    }

    function checkVaultInfo(address user) public view {
        console.log("\n=== VAULT INFORMATION ===");
        
        // USDC Vault info
        uint256 usdcShares = vaultUSDC.userShares(user);
        uint256 usdcAssets = vaultUSDC.previewRedeem(usdcShares);
        console.log("USDC Vault - Shares:", usdcShares / 1e18, "Assets:", usdcAssets / 1e18);
        
        // USDT Vault info
        uint256 usdtShares = vaultUSDT.userShares(user);
        uint256 usdtAssets = vaultUSDT.previewRedeem(usdtShares);
        console.log("USDT Vault - Shares:", usdtShares / 1e18, "Assets:", usdtAssets / 1e18);
        
        // Check pending rewards
        uint256 pendingUSDCRewards = rewardManager.pendingReward(address(vaultUSDC), user);
        uint256 pendingUSDTRewards = rewardManager.pendingReward(address(vaultUSDT), user);
        console.log("Pending USDC vault rewards:", pendingUSDCRewards / 1e18, "VLTN");
        console.log("Pending USDT vault rewards:", pendingUSDTRewards / 1e18, "VLTN");
    }

    function claimRewards(address user) public {
        console.log("\n=== CLAIMING REWARDS ===");
        
        uint256 vltnBefore = vltn.balanceOf(user);
        
        // Claim rewards from both vaults
        rewardManager.claimReward(address(vaultUSDC));
        rewardManager.claimReward(address(vaultUSDT));
        
        uint256 vltnAfter = vltn.balanceOf(user);
        uint256 claimed = vltnAfter - vltnBefore;
        
        console.log("Total VLTN rewards claimed:", claimed / 1e18);
    }

    function withdrawFromVaults(address user) public {
        console.log("\n=== WITHDRAWING FROM VAULTS ===");
        
        // Withdraw all shares from USDC vault
        uint256 usdcShares = vaultUSDC.userShares(user);
        if (usdcShares > 0) {
            console.log("Withdrawing", usdcShares / 1e18, "shares from USDC vault");
            uint256 usdcBefore = usdc.balanceOf(user);
            vaultUSDC.withdraw(usdcShares, user);
            uint256 usdcAfter = usdc.balanceOf(user);
            console.log("Received", (usdcAfter - usdcBefore) / 1e18, "USDC");
        }
        
        // Withdraw all shares from USDT vault
        uint256 usdtShares = vaultUSDT.userShares(user);
        if (usdtShares > 0) {
            console.log("Withdrawing", usdtShares / 1e18, "shares from USDT vault");
            uint256 usdtBefore = usdt.balanceOf(user);
            vaultUSDT.withdraw(usdtShares, user);
            uint256 usdtAfter = usdt.balanceOf(user);
            console.log("Received", (usdtAfter - usdtBefore) / 1e18, "USDT");
        }
    }

    // Helper function to simulate time passing for rewards
    function simulateTimePass(uint256 seconds_) public {
        console.log("\n=== SIMULATING TIME PASS ===");
        vm.warp(block.timestamp + seconds_);
        console.log("Advanced time by", seconds_, "seconds");
    }

    // Function to check all contract states
    function checkAllContractStates() public view {
        console.log("\n=== CONTRACT STATES ===");
        
        // Check vault total assets
        console.log("USDC Vault total assets:", vaultUSDC.totalAssets() / 1e18);
        console.log("USDT Vault total assets:", vaultUSDT.totalAssets() / 1e18);
        console.log("VLTN Vault total assets:", vaultVLTN.totalAssets() / 1e18);
        
        // Check strategy states
        console.log("USDC Strategy balance:", usdc.balanceOf(address(strategyUSDC)) / 1e18);
        console.log("USDT Strategy balance:", usdt.balanceOf(address(strategyUSDT)) / 1e18);
        
        // Check allocator balances
        console.log("Allocator USDC balance:", usdc.balanceOf(address(allocator)) / 1e18);
        console.log("Allocator USDT balance:", usdt.balanceOf(address(allocator)) / 1e18);
        
        // Check reward manager balance
        console.log("RewardManager VLTN balance:", vltn.balanceOf(address(rewardManager)) / 1e18);
    }

    // === INDEXER EVENT SIMULATION FUNCTIONS ===
    
    /**
     * @notice Comprehensive simulation of all events that the indexer listens to
     * This function will trigger all Deposit and Withdraw events across all vaults
     */
    function simulateIndexerEvents(address user) public {
        console.log("\n=== SIMULATING ALL INDEXER EVENTS ===");
        console.log("This will trigger Deposit and Withdraw events for USDC, USDT, and VLTN vaults");
        console.log("The indexer will capture these events and update VaultSnapshot records");
        
        // Ensure user has tokens
        ensureUserHasTokens(user);
        
        // Phase 1: Simulate multiple deposits across different vaults
        console.log("\n--- Phase 1: Multiple Deposits ---");
        simulateDeposits(user);
        
        // Phase 2: Simulate time passing and rewards accumulation
        console.log("\n--- Phase 2: Time Simulation ---");
        simulateTimePass(3600); // 1 hour
        
        // Phase 3: More deposits to test snapshot updates
        console.log("\n--- Phase 3: Additional Deposits ---");
        simulateMoreDeposits(user);
        
        // Phase 4: Simulate withdrawals
        console.log("\n--- Phase 4: Withdrawals ---");
        simulateWithdrawals(user);
        
        // Phase 5: Final state check
        console.log("\n--- Phase 5: Final State ---");
        checkAllContractStates();
        displayBalances(user);
        
        console.log("\n=== INDEXER EVENT SIMULATION COMPLETE ===");
        console.log("Check your indexer logs to see how it processed these events");
    }
    
    function ensureUserHasTokens(address user) public {
        console.log("Ensuring user has sufficient tokens for testing...");
        
        // Check if user needs more tokens
        if (usdc.balanceOf(user) < 5000 * 1e18) {
            usdc.mint(user, 10000 * 1e18);
            console.log("Minted 10,000 USDC");
        }
        
        if (usdt.balanceOf(user) < 5000 * 1e18) {
            usdt.mint(user, 10000 * 1e18);
            console.log("Minted 10,000 USDT");
        }
        
        if (vltn.balanceOf(user) < 1000 * 1e18) {
            vltn.mint(user, 5000 * 1e18);
            console.log("Minted 5,000 VLTN");
        }
    }
    
    function simulateDeposits(address user) public {
        // Deposit into USDC vault - triggers BoringVaultUSDC:Deposit event
        console.log("1. Depositing into USDC vault...");
        depositIntoUSDCVault(user, 1000 * 1e18);
        
        // Small delay simulation
        simulateTimePass(300); // 5 minutes
        
        // Deposit into USDT vault - triggers BoringVaultUSDT:Deposit event  
        console.log("2. Depositing into USDT vault...");
        depositIntoUSDTVault(user, 800 * 1e18);
        
        // Another delay
        simulateTimePass(300); // 5 minutes
        
        // Deposit into VLTN vault - triggers BoringVaultVLTN:Deposit event
        console.log("3. Depositing into VLTN vault...");
        depositIntoVLTNVault(user, 500 * 1e18);
    }
    
    function simulateMoreDeposits(address user) public {
        // More deposits to trigger additional events
        console.log("1. Second USDC deposit...");
        depositIntoUSDCVault(user, 500 * 1e18);
        
        simulateTimePass(600); // 10 minutes
        
        console.log("2. Second USDT deposit...");
        depositIntoUSDTVault(user, 300 * 1e18);
        
        simulateTimePass(300); // 5 minutes
        
        console.log("3. Second VLTN deposit...");
        depositIntoVLTNVault(user, 200 * 1e18);
    }
    
    function simulateWithdrawals(address user) public {
        // Partial withdrawals to trigger Withdraw events
        console.log("1. Partial withdrawal from USDC vault...");
        partialWithdrawFromUSDCVault(user, 25); // 25% withdrawal
        
        simulateTimePass(300); // 5 minutes
        
        console.log("2. Partial withdrawal from USDT vault...");
        partialWithdrawFromUSDTVault(user, 30); // 30% withdrawal
        
        simulateTimePass(300); // 5 minutes
        
        console.log("3. Partial withdrawal from VLTN vault...");
        partialWithdrawFromVLTNVault(user, 50); // 50% withdrawal
    }
    
    function depositIntoVLTNVault(address user, uint256 amount) public {
        console.log("Depositing", amount / 1e18, "VLTN into VLTN vault");
        
        // Check allowance
        uint256 allowance = vltn.allowance(user, address(vaultVLTN));
        if (allowance < amount) {
            vltn.approve(address(vaultVLTN), type(uint256).max);
        }
        
        uint256 sharesBefore = vaultVLTN.userShares(user);
        vaultVLTN.deposit(amount, user);
        uint256 sharesAfter = vaultVLTN.userShares(user);
        
        console.log("Received shares:", (sharesAfter - sharesBefore) / 1e18);
    }
    
    function partialWithdrawFromUSDCVault(address user, uint256 percentage) public {
        uint256 userShares = vaultUSDC.userShares(user);
        uint256 sharesToWithdraw = (userShares * percentage) / 100;
        
        if (sharesToWithdraw > 0) {
            console.log("Withdrawing", percentage, "% of USDC vault shares");
            uint256 usdcBefore = usdc.balanceOf(user);
            vaultUSDC.withdraw(sharesToWithdraw, user);
            uint256 usdcAfter = usdc.balanceOf(user);
            console.log("Received", (usdcAfter - usdcBefore) / 1e18, "USDC");
        }
    }
    
    function partialWithdrawFromUSDTVault(address user, uint256 percentage) public {
        uint256 userShares = vaultUSDT.userShares(user);
        uint256 sharesToWithdraw = (userShares * percentage) / 100;
        
        if (sharesToWithdraw > 0) {
            console.log("Withdrawing", percentage, "% of USDT vault shares");
            uint256 usdtBefore = usdt.balanceOf(user);
            vaultUSDT.withdraw(sharesToWithdraw, user);
            uint256 usdtAfter = usdt.balanceOf(user);
            console.log("Received", (usdtAfter - usdtBefore) / 1e18, "USDT");
        }
    }
    
    function partialWithdrawFromVLTNVault(address user, uint256 percentage) public {
        uint256 userShares = vaultVLTN.userShares(user);
        uint256 sharesToWithdraw = (userShares * percentage) / 100;
        
        if (sharesToWithdraw > 0) {
            console.log("Withdrawing", percentage, "% of VLTN vault shares");
            uint256 vltnBefore = vltn.balanceOf(user);
            vaultVLTN.withdraw(sharesToWithdraw, user);
            uint256 vltnAfter = vltn.balanceOf(user);
            console.log("Received", (vltnAfter - vltnBefore) / 1e18, "VLTN");
        }
    }
}