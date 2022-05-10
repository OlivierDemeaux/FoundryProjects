// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "forge-std/Vm.sol";
import "ds-test/test.sol";
import "../src/Button.sol";

contract ContractTest is DSTest {

    Vm vm = Vm(HEVM_ADDRESS);

    Button button;

    address alice = address(0x1337);
    address bob = address(0x133702);

    function setUp() public {
        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.deal(alice, 100 ether);
        vm.deal(bob, 100 ether);

        vm.label(address(this), "ButtonContract");

        button = new Button{value: 1 ether}();
    }

    function testLastBlockCalled() public {
        assertEq(button.lastBlockCalled(), 1);
        assertEq(button.lastCaller(), 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84);
    }

    function testPressButton() public {
        vm.startPrank(alice);
        button.pressButton{value: 1 ether}();
        assertEq(button.lastBlockCalled(), 1);
        assertEq(button.lastCaller(), alice);
        vm.stopPrank();

        vm.roll(2);

        vm.startPrank(bob);
        button.pressButton{value: 1 ether}();
        assertEq(button.lastBlockCalled(), 2);
        assertEq(button.lastCaller(), bob);
        vm.stopPrank();
    }

    function testPlayGame() public {
        assertTrue(!button.gameOver());
        assertEq(button.lastBlockCalled(), 1);
        assertEq(button.lastCaller(), 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84);


        vm.roll(5);
        vm.startPrank(alice);
        button.pressButton{value: 1 ether}();
        assertEq(button.lastBlockCalled(), 1);
        assertEq(button.lastCaller(), 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84);
        assertTrue(button.gameOver());
    }
}
