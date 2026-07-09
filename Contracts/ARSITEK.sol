// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract ARSITEK is ERC20, ERC20Burnable, Pausable, Ownable, ERC20Permit, ERC20Votes {
    // Tax configuration
    uint256 public buyMarketingTax = 1;
    uint256 public buyTreasuryTax = 1;
    uint256 public buyBurnTax = 1;
    uint256 public totalBuyTax = 3;
    
    uint256 public sellMarketingTax = 2;
    uint256 public sellTreasuryTax = 2;
    uint256 public sellBurnTax = 1;
    uint256 public totalSellTax = 5;
    
    address public marketingWallet;
    address public treasuryWallet;
    
    // Anti-whale settings
    uint256 public maxTransactionAmount;
    uint256 public maxWalletAmount;
    
    // Burn limit
    uint256 public constant MAX_BURN_AMOUNT = 200_000_000 * 10**18;
    uint256 public totalBurned;
    
    // DEX pairs
    mapping(address => bool) public isDexPair;
    
    // Whitelist
    mapping(address => bool) public isWhitelisted;
    
    // Events
    event MarketingWalletUpdated(address newWallet);
    event TreasuryWalletUpdated(address newWallet);
    event TaxesUpdated(uint256 buyTax, uint256 sellTax);
    event DexPairUpdated(address pair, bool value);
    event WhitelistUpdated(address account, bool value);

    constructor(
        address _marketingWallet,
        address _treasuryWallet
    ) ERC20("ARSITEK", "ARS") ERC20Permit("ARSITEK") {
        uint256 totalSupply = 1_000_000_000 * 10**18;
        
        marketingWallet = _marketingWallet;
        treasuryWallet = _treasuryWallet;
        
        maxTransactionAmount = totalSupply / 100;
        maxWalletAmount = totalSupply / 50;
        
        isWhitelisted[msg.sender] = true;
        isWhitelisted[_marketingWallet] = true;
        isWhitelisted[_treasuryWallet] = true;
        isWhitelisted[address(this)] = true;
        
        _mint(msg.sender, totalSupply);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        require(sender != address(0), "Transfer from zero");
        require(recipient != address(0), "Transfer to zero");
        require(amount > 0, "Amount must be > 0");
        
        if (!isWhitelisted[sender] && !isWhitelisted[recipient]) {
            require(!paused(), "Trading paused");
            require(amount <= maxTransactionAmount, "Exceeds max transaction");
            
            if (isDexPair[sender] && !isDexPair[recipient]) {
                require(balanceOf(recipient) + amount <= maxWalletAmount, "Exceeds max wallet");
            }
        }
        
        uint256 transferAmount = amount;
        
        if (!isWhitelisted[sender] && !isWhitelisted[recipient]) {
            if (isDexPair[sender]) {
                uint256 marketingTax = (amount * buyMarketingTax) / 100;
                uint256 treasuryTax = (amount * buyTreasuryTax) / 100;
                uint256 burnTax = (amount * buyBurnTax) / 100;
                
                super._transfer(sender, marketingWallet, marketingTax);
                super._transfer(sender, treasuryWallet, treasuryTax);
                
                if (totalBurned + burnTax <= MAX_BURN_AMOUNT) {
                    _burn(sender, burnTax);
                    totalBurned += burnTax;
                }
                
                transferAmount = amount - marketingTax - treasuryTax - burnTax;
            } else if (isDexPair[recipient]) {
                uint256 marketingTax = (amount * sellMarketingTax) / 100;
                uint256 treasuryTax = (amount * sellTreasuryTax) / 100;
                uint256 burnTax = (amount * sellBurnTax) / 100;
                
                super._transfer(sender, marketingWallet, marketingTax);
                super._transfer(sender, treasuryWallet, treasuryTax);
                
                if (totalBurned + burnTax <= MAX_BURN_AMOUNT) {
                    _burn(sender, burnTax);
                    totalBurned += burnTax;
                }
                
                transferAmount = amount - marketingTax - treasuryTax - burnTax;
            }
        }
        
        super._transfer(sender, recipient, transferAmount);
    }

    function setMarketingWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "Invalid wallet");
        marketingWallet = newWallet;
        isWhitelisted[newWallet] = true;
        emit MarketingWalletUpdated(newWallet);
    }

    function setTreasuryWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "Invalid wallet");
        treasury