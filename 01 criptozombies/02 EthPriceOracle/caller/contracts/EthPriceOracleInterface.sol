//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

abstract contract EthPriceOracleInterface {
  function getLatestEthPrice() virtual public returns (uint256);
}