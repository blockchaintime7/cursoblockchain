// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IContratoDeAluguel {
    enum TipoPessoa{ INVALIDO, LOCADOR, LOCATARIO }

    struct Pessoa{
        string nome;
        TipoPessoa tipo;
        address endereco;
    }

    function retornarValorDoAluguel(uint8 parcelaDoBoleto) external view returns(uint256 valorDaParcela);

    function retornarNomeDoLocadorELocatario() external view returns(Pessoa memory, Pessoa memory);

    function reajustarParcelas(uint8 parcelaInicialParaReajuste, uint256 valorDoReajuste) external returns(bool);

    function efetuarPagamento(uint8 parcelaDoBoleto, uint256 valorDaParcela) external returns(bool) ;

    function sacarAluguel() external returns(bool);

    function valorDisponivelParaSaque() external view returns(uint256);

}