// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/*
 * @title Aluguel
 * @author blockchaintime7
 * @notice Requisitos: contrato de aluguel permitirá o pagamento do aluguel em ether
 */
contract Aluguel {
    address payable public locatario;

    constructor() payable {
        locatario = payable(msg.sender);
    }

    event Transacao(string _function, address _de, uint _valor, bytes _data);

    /*
     * @dev Valida se e o locatario
     */
    modifier somenteLocatario() {
        require(msg.sender == locatario, "Somente locatario tem permissao");
        _;
    }

    /*
     * @dev Retorna o saldo do contrato
     */
    function saldo() public view returns (uint) {
        return address(this).balance;
    }

    /*
     * @dev Deposita em ETH o valor do aluguel
     */
    function deposito() public payable {
        emit Transacao("deposito", msg.sender, msg.value, "");
    }

    /*
     * @dev Saca o valor desejado
     */
    function saque() public somenteLocatario returns (bool) {
        uint saldoTotal = address(this).balance;

        (bool sucesso, ) = locatario.call{value: saldoTotal}("");
        require(sucesso, "Ocorreu um erro ao sacar");

        emit Transacao("saque", msg.sender, saldoTotal, "");

        return true;
    }

    /*
     * @dev Transfere o valor para um endereco
     * @param para o endereco favorecido
     * @param valor em ETH
     */
    function transferir(address _para, uint _valor) public somenteLocatario returns (bool) {
        require(_valor > 0, "Somente locatario tem permissao");

        (bool sucesso, ) = _para.call{value: _valor}("");
        require(sucesso, "Ocorreu um erro ao transferir");

        emit Transacao("transferir", msg.sender, _valor, "");

        return true;
    }
}
