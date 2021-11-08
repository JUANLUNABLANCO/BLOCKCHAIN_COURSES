// SPDX-License-Identifier: MIT                         // licnse
pragma solidity ^0.8.0;                                 // version solidity

import "./zombiehelper.sol";                            // importamos

contract ZombieBattle is ZombieHelper {
    uint randNonce = 0; 
    uint attackVictoryProbability = 70;

    function randMod(uint _modulus) internal returns(uint) {
        randNonce = randNonce.add(1);                                    // cada vez que se usa en la función es un número diferente
        return uint(keccak256(now, msg.sender, randNonce)) % _modulus;
    } // devuelve numeros aleatorios, pero puede ser muy vulnerable a ataques

    function attack(uint _zombieId, uint _targetId) external onlyOwnerOf(_zombieId) {
        Zombie storage myZombie = zombies[_zombieId];
        Zombie storage enemyZombie = zombies[_targetId];    // traemos los zombies de la blockchain, para interaccionar con ellos
        uint rand = randMod(100);                           // generamos un numero aleatorio entre 0 y 99
        if (rand <= attackVictoryProbability) {
            myZombie.winCount = myZombie.winCount.add(1);
            myZombie.level = myZombie.level.add(1);
            enemyZombie.lossCount = enemyZombie.lossCount.add(1);
            feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
        } else {
            myZombie.lossCount = myZombie.lossCount.add(1);
            enemyZombie.winCount = enemyZombie.winCount.add(1);
        }
        _triggerCooldown(myZombie);
    }  // atacará a otro zombie con un 70% de ventaja

}