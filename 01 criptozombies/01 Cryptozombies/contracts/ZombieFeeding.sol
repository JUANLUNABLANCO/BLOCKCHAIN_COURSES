// SPDX-License-Identifier: MIT                         // licnse
pragma solidity ^0.8.0;                                 // version solidity

import "./ZombieFactory.sol";

contract KittyInterface {
    function getKitty(uint256 _id) external view returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes
    );
}

contract ZombieFeeding is ZombieFactory {
    
    // address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;  // el address de kittyContract in blockchain
    // KittyInterface kittyContract = KittyInterface(ckAddress);        // pasarle a la interface el address para poder
                                                                        // usar ese kittyContract.getKitty(...)
    KittyInterface kittyContract;

    modifier onlyOwnerOf(uint _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        _;
    } // modificador para saber si el que ataca ataca con su propio zombie, es dueño de este.

    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }   // funcion accesible desde fuera, pero con el modificador onlyOwner solo podrá ejecutarlo el propietario

    function _triggerCooldown(Zombie memory _zombie) internal {
        _zombie.readyTime = uint32(block.timestamp + cooldownTime);
    }   // recibe un puntero al Zombie en vez de un id  recuerda internal es más que public, puede heredarse                                              

    function _isReady(Zombie memory _zombie) internal view returns(bool) {
        return (_zombie.readyTime <= block.timestamp); 
    }   // solo puede ser usada dentro de otras funciones gracias a view

    function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) internal onlyOwnerOf(_zombieId){  // funcion internal recibe tres parametros
        Zombie memory myZombie = zombies[_zombieId];       // puntero storage al array de estructuras zombies "Id" ???
        require(_isReady(myZombie));                        // solo si es ready 
        _targetDna = _targetDna % dnaModulus;               // para que solo tenga 16 dígitos máximo
        uint newDna = (myZombie.dna + _targetDna) / 2;      // promedio entre los dos dna, el myZombie y el target     
        if (keccak256(_species) == keccak256("kitty")) {    // si la especie es 'kitty' cambiará los 2 últimos dígitos a 99
            newDna = newDna - newDna % 100 + 99;
        }
        _createZombie("NoName", newDna);                    // creamos es nuevo zombie con propietario
        _triggerCooldown(myZombie);                         // lanzamos el trigger de enfriamiento
    }

    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;                                      // declaramos la variable a usar en el multiple returns
        (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId); // escogemos sol oel 10 que es gene
        feedAndMultiply(_zombieId, kittyDna, "kitty");     // llamamos a feedAndMultiply para crear el zombie a partir de un criptoKitty
    }
}