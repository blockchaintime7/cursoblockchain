//SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "./realDigital.sol";

contract ClienteBanco {
    
    address enderecoRealDigital;
    //O endereço do banco é a conta do Toledo
    address constant ENDERECO_DO_BANCO = 0x47bddffaB5057c2725dde8E22aBe63A9E4091E25;

    string public cpfCliente;
    address public chaveDoCliente;
    bool public autorizacaoCliente;

    RealDigital public realDigital;
    address public chaveDoBanco;
    bool public autorizacaoBanco;

    modifier validarBanco(){
        require(
            msg.sender == ENDERECO_DO_BANCO, 
            "Somente o locador pode efetuar o saque.");
        _;

    }
    
    event AutorizacaoDada(address chave, uint data);

    constructor(string memory cpfNovoCliente, address enderecoDoCliente, address _enderecoRealDigital) {
        require(msg.sender == ENDERECO_DO_BANCO, "Somente o banco pode criar a conta para o cliente.");
        chaveDoBanco = msg.sender;
        cpfCliente = cpfNovoCliente;
        chaveDoCliente = address(enderecoDoCliente);
        realDigital = RealDigital(_enderecoRealDigital);
    }

    function saldoCliente() external view returns (uint256) {
        return realDigital.balanceOf(address(this));
    }

    function trocaEnderecoDoReal(address _enderecoRealDigital) external validarBanco returns (bool) {
        realDigital = RealDigital(_enderecoRealDigital);
        return true;
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

    function saque(address _to, uint256 valor) external returns (bool) {
        require(msg.sender == chaveDoBanco || msg.sender == chaveDoCliente, unicode"Somente o banco e o cliente podem fazer essa operação.");
        if (valor <= realDigital.balanceOf(address(this)) && valor > 100000) {
            require(autorizacaoCliente && autorizacaoBanco, unicode"não possue as autorizações necessárias");
        }
        bool success = realDigital.transfer(_to, valor);
        require(success, "houve falha no saque");
        autorizacaoCliente=false; 
        autorizacaoBanco=false;
        return success;
    }
}
