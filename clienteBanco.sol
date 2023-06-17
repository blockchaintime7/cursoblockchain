//SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "./realCoin.sol";

contract ClienteBanco {
    string public cpf;
    RealCoin public token;
    address public chaveUm;
    address public chaveDois;
    uint8 public autorizacoes;

    event AutorizacaoDada(address chave, uint data);

    constructor(string memory _cpf) {
        cpf = _cpf;
        chaveUm = msg.sender;
        chaveDois = address(0x8e287B1F206eF762D460598bdE1A9C22db6b6382);
        token = RealCoin(0x8eE5B68e89d86f5662d02200cD0FF7baa8065067);
    }

    function saldoCliente() external view returns (bool) {
        return token.balanceOf(address(this))>0;
    }

    function autorizo() external returns (bool) {
        require(msg.sender == chaveUm || msg.sender == chaveDois, "somente o banco pode fazer essa operacao");
        autorizacoes++;
        emit AutorizacaoDada(msg.sender, block.timestamp);
        return true;
    }

    function saqueTotal(address _to) external returns (bool) {
        require(msg.sender == chaveUm || msg.sender == chaveDois, "somente o banco pode fazer essa operacao");
        if (token.balanceOf(address(this)) > 1000) {
            require(autorizacoes == 2, "nao possue autorizacoes necessarias");
        }
        bool success = token.transfer(_to, token.balanceOf(address(this)));
        require(success, "houve falha no saque");
        autorizacoes = 0;
        return success;
    }
}
