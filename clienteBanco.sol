//SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "./realDigital.sol";

contract ClienteBanco {
    //Como guardaria esta chave em outro local?
    address constant ENDERECO_REAL_COIN = 0x8eE5B68e89d86f5662d02200cD0FF7baa8065067;
    //O endereço do banco é a conta do Toledo
    address constant ENDERECO_DO_BANCO = 0x47bddffaB5057c2725dde8E22aBe63A9E4091E25;

    string public cpfCliente;
    address public chaveDoCliente;
    bool public autorizacaoCliente;

    RealDigital public realDigital;
    address public chaveDoBanco;
    bool public autorizacaoBanco;
    
    event AutorizacaoDada(address chave, uint data);

    constructor(string memory cpfNovoCliente, address enderecoDoCliente) {
        require(msg.sender == ENDERECO_DO_BANCO, "Somente o banco pode criar a conta para o cliente.");
        chaveDoBanco = msg.sender;
        cpfCliente = cpfNovoCliente;
        chaveDoCliente = address(enderecoDoCliente);
        realDigital = RealDigital(ENDERECO_REAL_COIN);
    }

    function saldoCliente() external view returns (uint256) {
        return realDigital.balanceOf(address(this));
    }

    function autorizo() external returns (bool) {
        require(msg.sender == chaveDoBanco || msg.sender == chaveDoCliente, unicode"Somente o banco e o cliente podem fazer essa operação.");
        if(msg.sender == chaveDoBanco){
            autorizacaoBanco = true;
        } else {
            autorizacaoCliente = true;
        }
        emit AutorizacaoDada(msg.sender, block.timestamp);
        return true;
    }

    function saqueTotal(address _to) external returns (bool) {
        require(msg.sender == chaveDoBanco || msg.sender == chaveDoCliente, unicode"Somente o banco e o cliente podem fazer essa operação.");
        if (realDigital.balanceOf(address(this)) > 1000) {
            require(autorizacaoCliente && autorizacaoBanco, unicode"não possue as autorizações necessárias");
        }
        bool success = realDigital.transfer(_to, realDigital.balanceOf(address(this)));
        require(success, "houve falha no saque");
        autorizacaoCliente=true; 
        autorizacaoBanco=true;
        return success;
    }
}
