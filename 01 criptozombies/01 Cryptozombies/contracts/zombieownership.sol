// SPDX-License-Identifier: MIT                         // licnse
pragma solidity ^0.8.0;                                 // version solidity

import "./zombieattack.sol";                            // importamos
import "./erc721.sol";
import "./safemath.sol";

/// @title  utiliza el ERC721 para las tipicas transacciones de este protocolo. Un contrato que gestiona la transferencia de la propiedad de un zombi.
/// @author JuanLuna
/// @dev    la funcion _transfer realiza la conversion necesaria
contract ZombieOwnership is ZombieBattle, ERC721 {

    using SafeMath for uint256;
    mapping(uint => address) zombieApprovals;    // los zombies que pueden ser tomados zombieId => address_to

    function balanceOf(address _owner) public view returns (uint256 _balance) {
        return ownerZombieCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        return zombieToOwner[_tokenId];
    }

    function _transfer(address _from, address _to, uint256 _tokenId) private {
        ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
        ownerZombieCount[_from] = ownerZombieCount[_from].sub(1);
        zombieToOwner[_tokenId] = _to;
        Transfer(_from, _to, _tokenId);
    }   // aumenta el numero de zombies del _to, disminuye en un oal del _from, cambia de propietario
        // ese zombie y emite el evento transfer 

    function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        _transfer(msg.sender, _to, _tokenId);
    } // llamamos a nuestra funcion transfer particular no si antes asegurarnos que es el propietario de ese zombie
      // para transferirlo


    function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        zombieApprovals[_tokenId] = _to;                    // aquí se le entrega al approval el id del token para un destinatario
                                                            // para que lo reclame
        Approval(msg.sender, _to, _tokenId);                // para ello recibirá un evento, especie de mensaje 
                                                            // "Ha sido aprovado"
    }

    function takeOwnership(uint256 _tokenId) public {
        require( zombieApprovals[_tokenId] == msg.sender);  // si es que el zombie ha sido aprobado para este usuario
        address owner = ownerOf(_tokenId);                  // buscamos el antiguo propietario antes de transferirlo owner
        _transfer(owner, msg.sender, _tokenId);             // esta funcion la va a usar el propietario _to, 
                                                            // owner (antiguo propietario), msg.sender (el nuevo), ...
                                                            // es nuestra función que hace los cambios necesarios
    }
}