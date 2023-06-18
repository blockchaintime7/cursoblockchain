//SPDX-License-Identifier: CC-BY-4.0

pragma solidity 0.8.20;

contract ContratoDeAluguel {
    uint8 constant NUMERO_MAXIMO_DE_PARCELAS = 36; 
    uint8 constant TAMANHO_MINIMO_DO_NOME = 3;

    enum TipoPessoa{ INVALIDO, LOCADOR, LOCATARIO }

    struct Pessoa{
        string nome;
        TipoPessoa tipo;
        address endereco;
    }

    struct Boleto{
        uint8 numeroDoBoleto;
        uint256 valor;
        bool pago;
    }

    struct ContratoLocacao{
        mapping(TipoPessoa => Pessoa) partes;
        mapping(uint8 => Boleto) boletos;
    }

    modifier stringValido(string memory nome, string memory valor){
        bytes memory nomeBytes = bytes(nome);
        bytes memory campoBytes = bytes("Campo ");
        bytes memory naoValidoBytes = bytes(unicode" não é um valor válido");
        bytes memory concatenated = abi.encodePacked(campoBytes, nomeBytes, naoValidoBytes);
       
        require(bytes(valor).length >= TAMANHO_MINIMO_DO_NOME, string(concatenated));
        _;
    }

    modifier tipoPessoaValido(TipoPessoa tipoPessoa){
        require(
            tipoPessoa == TipoPessoa.LOCADOR || 
            tipoPessoa == TipoPessoa.LOCATARIO, unicode"Tipo de pessoa informada e inválido." );
        _;
    }

    modifier pagamentoValido(uint8 parcelaDoBoleto, uint256 valor) {
        require(verificarValidadeDaParcela(parcelaDoBoleto), unicode"A parcela escolhida para o reajuste é inválida.");
        require(!contratoDeLocacao.boletos[parcelaDoBoleto].pago, unicode"Esta parcela do boleto já foi paga.");
        require(msg.sender == contratoDeLocacao.partes[TipoPessoa.LOCATARIO].endereco, unicode"Endereço não permitido para efetuar este pagamento.");
        require(msg.value >= valor, "Saldo insuficiente para o pagametno do boleto.");
        _;
    }

    ContratoLocacao private contratoDeLocacao;
    

    constructor(
        string memory nomeDoLocador, address enderecoDoLocador, 
        string memory nomeDoLocatario, address enderecoDoLocatario, uint256 valorDasParcelas
    ) payable {
        contratoDeLocacao.partes[TipoPessoa.LOCADOR] = Pessoa(nomeDoLocador,TipoPessoa.LOCADOR, payable(enderecoDoLocador));
        contratoDeLocacao.partes[TipoPessoa.LOCATARIO] = Pessoa(nomeDoLocatario, TipoPessoa.LOCATARIO, enderecoDoLocatario);
        for (uint8 i=1; i<=NUMERO_MAXIMO_DE_PARCELAS; i++){
            contratoDeLocacao.boletos[i] = Boleto(i,valorDasParcelas,false);
        }

    }

    function retornarValorDoAluguel(uint8 parcelaDoBoleto) external view returns(uint256 valorDaParcela) {
        require(verificarValidadeDaParcela(parcelaDoBoleto), unicode"A parcela escolhida é inválida.");
        return contratoDeLocacao.boletos[parcelaDoBoleto].valor;
    }

    function retornarNomeDoLocadorELocatario() external view returns(Pessoa memory, Pessoa memory){
        return (contratoDeLocacao.partes[TipoPessoa.LOCADOR], contratoDeLocacao.partes[TipoPessoa.LOCATARIO]);
    }


    function reajustarParcelas(uint8 parcelaInicialParaReajuste, uint256 valorDoReajuste) external{
        require(verificarValidadeDaParcela(parcelaInicialParaReajuste), unicode"A parcela escolhida para o reajuste é inválida.");
        for (uint8 i = parcelaInicialParaReajuste; i <= NUMERO_MAXIMO_DE_PARCELAS; i++){
            contratoDeLocacao.boletos[i].valor = contratoDeLocacao.boletos[i].valor + valorDoReajuste;
        }
    }

    function verificarValidadeDaParcela(uint8 parcelaDoBoleto) internal pure returns(bool){
        return parcelaDoBoleto > 0 && parcelaDoBoleto <=NUMERO_MAXIMO_DE_PARCELAS;
    } 

    function efetuarPagamento(
        uint8 parcelaDoBoleto, uint256 valor
    ) external pagamentoValido(parcelaDoBoleto, valor) payable returns(bool) {
        enviarPagamentoParaLocador(valor);
        marcarBoletoComoPago(parcelaDoBoleto);
        return true;
    }

    function enviarPagamentoParaLocador(uint256 valor)internal {
        address enderecoDoLocador = contratoDeLocacao.partes[TipoPessoa.LOCADOR].endereco;
        (bool success, ) =  enderecoDoLocador.call{value: valor}("");
        require(success, unicode"Falha na efetivação do pagamento.");
    }

    function marcarBoletoComoPago(uint8 parcelaDoBoleto) internal {
        contratoDeLocacao.boletos[parcelaDoBoleto].pago=true;
    }

}