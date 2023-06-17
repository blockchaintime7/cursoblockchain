// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

import "./iRealCoin.sol";

interface ICaixa {
    function myBalance() external view returns (uint256);
}

contract Caixa {
    // Payable address can receive Ether
    address payable public owner;

    event Track(string indexed _function, address sender, uint value, bytes data);


    // Payable constructor can receive Ether
    constructor() payable {
        owner = payable(msg.sender);
    }

    // Function to deposit Ether into this contract.
    // Call this function along with some Ether.
    // The balance of this contract will be automatically updated.
    function deposit() public payable {
        emit Track("deposit()", msg.sender, msg.value, "");
    }

    // Call this function along with some Ether.
    // The function will throw an error since this function is not payable.
    function notPayable() public {}

    // Function to withdraw all Ether from this contract.
    function withdraw() public {
        require(msg.sender == owner, "only owner can withdraw");
        // get the amount of Ether stored in this contract
        uint amount = address(this).balance;

        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    // Function to transfer Ether from this contract to address from input
    function transfer(address payable _to, uint _amount) public {
        require(msg.sender == owner, "only owner can withdraw");
        // Note that "to" is declared as payable
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }

    receive() external payable {
        (bool success, ) = msg.sender.call{value: msg.value}("");
        require(success, "it was not sent to the owner");
        emit Track("receive()", msg.sender, msg.value, "");
    }

    function myBalance() external view returns (uint256) {
        return address(this).balance;
    }
}


contract Autorizador {
    ICaixa public caixa;
    IRealCoin public token;

    constructor() {
        caixa = ICaixa(0xD7170F4cE3be4707Ee34c15De8057775414db5Ee);
        token = IRealCoin(0x8eE5B68e89d86f5662d02200cD0FF7baa8065067);
    }

    function estaAutorizado(address _conta) external view returns (bool) {
        return caixa.myBalance()>0 && token.balanceOf(_conta)>0;
    }

    function estouAutorizado() external view returns (bool) {
        return token.balanceOf(address(this))>0;
    }
}