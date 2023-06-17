// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

import "./iRealCoin.sol";

interface IAluguel {
    function saldo() external view returns (uint256);
}

contract Autorizador {
    IAluguel public aluguel;
    IRealCoin public token;

    constructor() {
        aluguel = IAluguel(0xD7170F4cE3be4707Ee34c15De8057775414db5Ee);
        token = IRealCoin(0x8eE5B68e89d86f5662d02200cD0FF7baa8065067);
    }

    function estaAutorizado(address _conta) external view returns (bool) {
        return aluguel.saldo()>0 && token.balanceOf(_conta)>0;
    }

    function estouAutorizado() external view returns (bool) {
        return token.balanceOf(address(this))>0;
    }
}