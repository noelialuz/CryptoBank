//Licencia
//SPDX-License-Identifier: LGPL-3.0-only

//Version de solidity 
pragma solidity ^0.8.24;

//Contrato

// Functions
    // 1. Deposit ether
    // 2. Withdraw ether
    // 3. Maxbalance
    // 4. Maxbalance modifiable by owner 

// Rules
    // 1. Multiuser
    // 2. Only can deposit ether
    // 3. User only can withdraw his own previewsly deposited ether
    // 4. Max balance = 5 ether

contract CryptoBank {

   //-----------------------variables-----------------------
    
   uint256 public maxBalance;
   address public admin;
   mapping(address => uint256) public userBalances;
    //-----------------------constructor-----------------------

    constructor( uint256 maxBalance_, address _admin){
        maxBalance = maxBalance_;
        admin = _admin;
    }
    
    //-----------------------modifiers-----------------------
    modifier onlyAdmin(){
        require(msg.sender == admin, "Not allowed");
        _;
    }
    //-----------------------Events-----------------------

    event EtherDeposit(address user_ , uint256 etherAmount_ );
    event EtherWithdraw (address user_ , uint256 etherAmount_);
    //-----------------------Functions-----------------------

    
        //External functions
        function depositEther() external payable {
            require(userBalances[msg.sender] + msg.value <= maxBalance, "Max balance reached");
            userBalances[msg.sender] += msg.value;
            emit EtherDeposit(msg.sender, msg.value);
        }

        function withdrawEther(uint256 amount_) external  {

            // CEI Pattern: 1. Check(validate balance). 2. Effect(update balance). 3. Interaction(transfer the ether).
            // Validation
            require(amount_ <= userBalances[msg.sender], "Not enough ether");

            //Update balance
            userBalances[msg.sender] -= amount_;

            //Transfer ether
            (bool success_, ) = msg.sender.call{value: amount_}("");
            require(success_, "Transfer failed");

            emit EtherWithdraw(msg.sender, amount_);
        }
        
        // modify MaxBalance
        function modifyMaxBalance(uint256 newMaxBalance_) external onlyAdmin{
            maxBalance = newMaxBalance_;
        }
        

        //Internal functions
        
    
}