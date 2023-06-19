//SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

contract ContratoDeAluguel {
    uint8 constant NUMERO_MAXIMO_DE_PARCELAS = 36; 
    uint8 constant TAMANHO_MINIMO_DO_NOME = 3;
    enum TipoPessoa{ INVALIDO, LOCADOR, LOCATARIO }

    event Track(string indexed _function, address sender, uint value, bytes data); 

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

    modifier pagamentoValido(uint8 parcelaDoBoleto) {
        require(verificarValidadeDaParcela(parcelaDoBoleto), unicode"A parcela escolhida para o reajuste é inválida.");
        require(!contratoDeLocacao.boletos[parcelaDoBoleto].pago, unicode"Esta parcela do boleto já foi paga.");
        require(msg.sender == contratoDeLocacao.partes[TipoPessoa.LOCATARIO].endereco, unicode"Endereço não permitido para efetuar este pagamento.");
        
        require(msg.value == contratoDeLocacao.boletos[parcelaDoBoleto].valor, unicode"Valor informado é diferente do valor do boleto");
        require(msg.sender.balance >= msg.value, "Saldo insuficiente para o pagametno do boleto.");
        _;
    }

    modifier saqueLiberado(){
        require(
            msg.sender == contratoDeLocacao.partes[TipoPessoa.LOCADOR].endereco, 
            "Somente o locador pode efetuar o saque.");
        require(address(this).balance > 0, unicode"Não existe saldo para saque.");
        _;

    }

    ContratoLocacao private contratoDeLocacao;

    constructor (
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

    function reajustarParcelas(uint8 parcelaInicialParaReajuste, uint256 valorDoReajuste) external returns(bool){
        require(verificarValidadeDaParcela(parcelaInicialParaReajuste), unicode"A parcela escolhida para o reajuste é inválida.");
        for (uint8 i = parcelaInicialParaReajuste; i <= NUMERO_MAXIMO_DE_PARCELAS; i++){
            reajustarBoletosNaoPagos(parcelaInicialParaReajuste, valorDoReajuste);
        }

        return true;
    }

    function reajustarBoletosNaoPagos(uint8 parcela, uint256 valorDoReajuste) internal {
        if( !contratoDeLocacao.boletos[parcela].pago ){
            contratoDeLocacao.boletos[parcela].valor = contratoDeLocacao.boletos[parcela].valor + valorDoReajuste;
        }
    }

    function verificarValidadeDaParcela(uint8 parcelaDoBoleto) internal pure returns(bool){
        return parcelaDoBoleto > 0 && parcelaDoBoleto <=NUMERO_MAXIMO_DE_PARCELAS;
    } 

    function efetuarPagamento(
        uint8 parcelaDoBoleto
    ) external payable  pagamentoValido(parcelaDoBoleto) returns(bool) {
        marcarBoletoComoPago(parcelaDoBoleto);

        emit Track("efetuarPagamento()", msg.sender, msg.value, "Parcela paga com sucesso");
        return true;
    }

    function marcarBoletoComoPago(uint8 parcelaDoBoleto) internal {
        contratoDeLocacao.boletos[parcelaDoBoleto].pago=true;
    }


    function sacarAluguel() external saqueLiberado returns(bool){
        address enderecoDoLocador = contratoDeLocacao.partes[TipoPessoa.LOCADOR].endereco;
        (bool success, ) =  enderecoDoLocador.call{value: address(this).balance}("");
        require(success, unicode"Falha na efetivação do pagamento.");
        return true;
    }

    function valorDisponivelParaSaque() external view returns(uint256){
        return address(this).balance;
    }

}