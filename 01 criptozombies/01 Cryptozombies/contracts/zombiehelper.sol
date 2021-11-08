// SPDX-License-Identifier: MIT                         // licnse
pragma solidity ^0.8.0;                                 // version solidity

import "./ZombieFeeding.sol";                           // importamos ZombieFeeding

contract ZombieHelper is ZombieFeeding {

    uint levelUpFee = 0.001 ether;                      // costo por subir de nivel. Escrito en blockchain

    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level);
        _;
    }   // modificador para asegurar que un zombie tienen un cierto nivel

    function withdraw() external onlyOwner {
        owner.transfer(this.balance);
    }   // tras el pago de un usuario tarnsfiere todo lo que ese address tenga a la cuenta del owner

    function setLevelUpFee(uint _fee) external onlyOwner {
        levelUpFee = _fee;
    }   // poder variar el ether debido a que si cambia el precio del ether y sube podamos bajarlo aquí

    function levelUp(uint _zombieId) external payable {
        require(msg.value == levelUpFee);               // comprobamos el pago
        zombies[_zombieId].level = zombies[_zombieId].level.add(1); // incrementamos su niel en 1 
    }   // funcion que cobra por subir de nivel

    function changeName(uint _zombieId, string _newName) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
        zombies[_zombieId].name = _newName;
    }   // cambiará el nombre de su propio zombie si llega al nivel 2

    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId)  onlyOwnerOf(_zombieId) {
        zombies[_zombieId].dna = _newDna;
    }   // cambiará el dna de su propio zombie si llega al nivel 20 

    function getZombiesByOwner(address _owner) external view returns(uint[]) {
        uint[] memory result = new uint[](ownerZombieCount[_owner]);     // array de longitud el número de zombies de ese propietario
        uint counter = 0;
        for (uint i=0; i < zombies.length; i++) {
            if (zombieToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    } // obtener externamente todos los zombies de ese propietario
}