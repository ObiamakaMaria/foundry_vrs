// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/BitMapStorage.sol";

contract BitMapStorageTest is Test {
    BitMapStorage public bitmapStorage;

    function setUp() public {
        bitmapStorage = new BitMapStorage();
    }

    function testStoreSingleByte() public {
        bitmapStorage.storeByte(0, 42);
        assertEq(bitmapStorage.getByte(0), 42);
    }

    function testStoreMultipleBytes() public {
        bitmapStorage.storeByte(0, 255);
        bitmapStorage.storeByte(1, 128);
        bitmapStorage.storeByte(31, 67);


        assertEq(bitmapStorage.getByte(0), 255);
        assertEq(bitmapStorage.getByte(1), 128);
        assertEq(bitmapStorage.getByte(31), 67);
    }

    function testOverwriteByte() public {
        bitmapStorage.storeByte(5, 123);
        assertEq(bitmapStorage.getByte(5), 123);
        
        bitmapStorage.storeByte(5, 42);
        assertEq(bitmapStorage.getByte(5), 42);
    }

    function testGetAllBytes() public {
        bitmapStorage.storeByte(0, 11);
        bitmapStorage.storeByte(5, 22);
        bitmapStorage.storeByte(10, 33);
        bitmapStorage.storeByte(31, 44);
        
        uint8[32] memory allBytes = bitmapStorage.getAllBytes();
        
        assertEq(allBytes[0], 11);
        assertEq(allBytes[5], 22);
        assertEq(allBytes[10], 33);
        assertEq(allBytes[31], 44);
        
        assertEq(allBytes[1], 0);
        assertEq(allBytes[15], 0);
        assertEq(allBytes[30], 0);
    }

    function testGetRawBitmap() public {
        bitmapStorage.storeByte(0, 0xFF);
        bitmapStorage.storeByte(31, 0x01);
        
        uint256 expected = 0x01 << 248;
        expected |= 0xFF;
        
        assertEq(bitmapStorage.getRawBitmap(), expected);
    }
    
    function testSlotOutOfBounds() public {

        vm.expectRevert("Slot must be between 0 and 31");
        bitmapStorage.storeByte(32, 42);
        
        vm.expectRevert("Slot must be between 0 and 31");
        bitmapStorage.getByte(32);
    }

    function testFullBitmapUsage() public {
        for (uint8 i = 0; i < 32; i++) {
            bitmapStorage.storeByte(i, i * 8);
        }
        
        for (uint8 i = 0; i < 32; i++) {
            assertEq(bitmapStorage.getByte(i), i * 8);
        }

        uint8[32] memory allBytes = bitmapStorage.getAllBytes();
        for (uint8 i = 0; i < 32; i++) {
            assertEq(allBytes[i], i * 8);
        }
    }

    function testBoundaryValues() public {
        
        bitmapStorage.storeByte(0, 0);
        bitmapStorage.storeByte(15, 255);
        
        assertEq(bitmapStorage.getByte(0), 0);
        assertEq(bitmapStorage.getByte(15), 255);
    }
}