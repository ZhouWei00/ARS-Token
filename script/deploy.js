const { ethers } = require("hardhat");

async function main() {
  console.log("🚀 Deploying ARSITEK Token...");
  
  // Replace with actual wallet addresses
  const marketingWallet = "0xYourMarketingWalletAddress";
  const treasuryWallet = "0xYourTreasuryWalletAddress";
  
  const ARSITEK = await ethers.getContractFactory("ARSITEK");
  const arsitek = await ARSITEK.deploy(marketingWallet, treasuryWallet);
  
  await arsitek.deployed();
  
  console.log("✅ ARSITEK Token deployed to:", arsitek.address);
  console.log("📝 Token Details:");
  console.log("   Name:", await arsitek.name());
  console.log("   Symbol:", await arsitek.symbol());
  console.log("   Total Supply:", (await arsitek.totalSupply()).toString());
  console.log("   Marketing Wallet:", await arsitek.marketingWallet());
  console.log("   Treasury Wallet:", await arsitek.treasuryWallet());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });