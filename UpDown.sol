// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0 ;

import "ERC20.sol";

contract UpDown is ERC20 {
   address payable public owner1;
   uint256 public minimumBet;
   uint256 public totalBetsOne;
   uint256 public totalBetsTwo;
   address payable[] public players;
   ERC20 myToken;
   bool private _initialized1 = false;

    function initialize1 (address erc20Address) public {
        require(!_initialized1);
        _initialized1 = true;
        myToken = ERC20(erc20Address);
        owner1 = msg.sender;
        minimumBet = 1;
    }
    struct Player {
      uint256 amountBet;
      uint16 optionSelected;
    }
    mapping(address => Player) public playerInfo;
  
    function kill() public {
      if(msg.sender == owner1) selfdestruct(owner1);
    }
    
    function checkPlayerExists(address payable player) public view returns(bool){
      for(uint256 i = 0; i < players.length; i++){
         if(players[i] == player) return true;
    }
      return false;
    }
    function bet(uint8 _optionSelected, uint256 _amount) public payable {
      require(!checkPlayerExists(msg.sender));
      require(_amount >= minimumBet);
      playerInfo[msg.sender].amountBet = _amount;
      playerInfo[msg.sender].optionSelected = _optionSelected;
      players.push(msg.sender);
      if ( _optionSelected == 1){
          totalBetsOne += _amount;
      }
      else{
          totalBetsTwo += _amount;
      }
    }
    uint8 bonus;
    function setBonus (uint8 _bonus) public {
        bonus = _bonus;
    }
    function distributePrizes(uint16 optionWinner) public {
      address payable[1000] memory winners;
      uint256 count = 0; // This is the count for the array of winners
      uint256 LoserBet = 0; //This will take the value of all losers bet
      uint256 WinnerBet = 0; //This will take the value of all winners bet
      address add;
      uint256 bets;
      address payable playerAddress;
      for(uint256 i = 0; i < players.length; i++){
         playerAddress = players[i];
         if(playerInfo[playerAddress].optionSelected == optionWinner){
            winners[count] = playerAddress;
            count++;
         }
      }
      if ( optionWinner == 1){
         LoserBet = totalBetsTwo;
         WinnerBet = totalBetsOne;
      }
      else{
          LoserBet = totalBetsOne;
          WinnerBet = totalBetsTwo;
      }
      for(uint256 j = 0; j < count; j++){
         if(winners[j] != address(0))
            add = winners[j];
            bets = playerInfo[add].amountBet;
            winners[j].transfer(bets*bonus/100 );
      }
      
      delete playerInfo[playerAddress]; // Delete all the players
      //players.length = 0; // Delete all the players array
      LoserBet = 0; //reinitialize the bets
      WinnerBet = 0;
      totalBetsOne = 0;
      totalBetsTwo = 0;
    }
    function AmountOne() public view returns(uint256, uint256){
       return (totalBetsOne, totalBetsOne/totalBetsTwo*100);
    }
    function AmountTwo() public view returns(uint256, uint256){
       return (totalBetsTwo, totalBetsTwo/totalBetsOne*100);
    }

    
}