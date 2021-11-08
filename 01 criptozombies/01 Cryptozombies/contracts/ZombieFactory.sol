// SPDX-License-Identifier: MIT                         // licnse
pragma solidity ^0.8.0;                                 // version solidity

import "./ownable.sol";                                 // para que solo el propietario pueda usar el contrato
import "./safemath.sol";                                // para prevenir overflows

contract ZombieFactory is Ownable {                     // clase hereda de ownable

    using SafeMath for uint256;                         // usar la librería para uint256
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    event NewZombie(uint zombieId, string name, uint dna);  // evento a emitir

    uint dnaDigits = 16;                                // definimos enteros
    uint dnaModulus = 10 ** dnaDigits;                  // 10000000000000000
    uint cooldownTime = 1 days;                         // days medida de tiempo

    struct Zombie {                                     // definición de estructuras, similar a json
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;                               // coste de gas menor al usar uint32 y agruparlos dentro
                                                        // del struct
        uint16 winCount;                                // abtallas ganadas
        uint16 lossCount;                               // abtallas perdidas
    }

    Zombie[] public zombies;                            // array de estructuras

    mapping(uint => address) public zombieToOwner;      // definición de un mapping similar a diccionarios deklaves valores
    mapping(address => uint) ownerZombieCount;

    function _createZombie(string memory _name, uint _dna) internal {   // funcion privada heredada 'internal'
        // Nota: Decidimos no prevenir el problema del año 2018... sin embargo no debemos
        // preocuparnos de readyTime. Igual nuestra DApp funcionará hasta el año 2038 ;)
       uint id = zombies.push(Zombie(_name, _dna, 1, uint32(block.timestamp + cooldownTime), 0, 0)) - 1  ; // level = 1, tiempo actual en 
                                                        // uint32 en vez de uint256 que devuelve now + cooldownTime = 1 days
        zombieToOwner[id] = msg.sender;                 // asignacion del mapping 
        ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);                 // asignacion del mappin incrementador
        emit NewZombie(id, _name, _dna);                // emision del evento
    }
    
    function _generateRandomDna(string memory _str) private view returns (uint) {  // funcion privada con returns y de tipo view
        uint rand = uint(keccak256(_str));              // encriptador de 256
        return rand % dnaModulus;                       
    }

    function createRandomZombie(string memory _name) public {  // funcion publica sin retornos
        require(ownerZombieCount[msg.sender] == 0);      // comprobar si se cumple la condicion del require, sino enviara un error
        uint randDna = _generateRandomDna(_name);
        randDna = randDna - randDna % 100;              // ???
        _createZombie(_name, randDna);
    }
}

// contract ZombieFeeding is ZombieFactory {
        
// }

