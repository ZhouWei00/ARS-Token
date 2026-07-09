const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ARSITEK Token", function () {
  let ARSITEK;
  let arsitek;
  let owner;
  let addr1;
  let addr2;
  let marketingWallet;
  let treasuryWallet;

  beforeEach(async function () {
    [owner, addr1, addr2, marketingWallet, treasuryWallet] = await ethers.getSigners();
    
    ARSITEK = await ethers.getContractFactory("ARSITEK");
    arsitek = await ARSITEK.deploy(marketingWallet.address, treasuryWallet.address);
    await arsitek.deployed();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await arsitek.owner()).to.equal(owner.address);
    });

    it("Should assign the total supply of tokens to the owner", async function () {
      const ownerBalance = await arsitek.balanceOf(owner.address);
      expect(await arsitek.totalSupply()).to.equal(ownerBalance);
    });

    it("Should set correct token details", async function () {
      expect(await arsitek.name()).to.equal("ARSITEK");
      expect(await arsitek.symbol()).to.equal("ARS");
      expect(await arsitek.decimals()).to.equal(18);
    });
  });

  describe("Transactions", function () {
    it("Should transfer tokens between accounts", async function () {
      await arsitek.transfer(addr1.address, 100);
      expect(await arsitek.balanceOf(addr1.address)).to.equal(100);
    });

    it("Should fail if sender doesn't have enough tokens", async function () {
      await expect(arsitek.connect(addr1).transfer(addr2.address, 1))
        .to.be.revertedWith("ERC20: transfer amount exceeds balance");
    });
  });

  describe("Taxes", function () {
    it("Should set correct tax rates", async function () {
      expect(await arsitek.totalBuyTax()).to.equal(3);
      expect(await arsitek.totalSellTax()).to.equal(5);
    });
  });
});