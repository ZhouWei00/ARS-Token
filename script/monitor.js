const { ethers } = require("hardhat");

async function monitor() {
  const [owner] = await ethers.getSigners();
  const arsitek = await ethers.getContractAt("ARSITEK", "CONTRACT_ADDRESS");
  
  console.log("📊 ARSITEK Token Monitoring");
  console.log("Owner:", owner.address);
  console.log("Total Supply:", (await arsitek.totalSupply()).toString());
  console.log("Total Burned:", (await arsitek.totalBurned()).toString());
  console.log("Marketing Wallet:", await arsitek.marketingWallet());
  console.log("Treasury Wallet:", await arsitek.treasuryWallet());
}

monitor().catch(console.error);