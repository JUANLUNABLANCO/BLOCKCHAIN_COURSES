// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract MyContract {
    uint data;

    function getData() external view returns(uint){
        return data;
    }
    function setData(uint _data) external {
        data = _data;
    }
    function setDataPrivate(uint _data) private {
        data = _data + 10;
    }
}