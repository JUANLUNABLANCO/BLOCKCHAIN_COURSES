// pragma solidity 0.5.0;
// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

abstract contract CallerContractInterface {
	function callback(uint256 _ethPrice, uint256 id) public virtual;
}
