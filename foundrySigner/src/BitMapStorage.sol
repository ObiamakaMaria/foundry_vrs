// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BitMapStorage {
    uint256 private bitmap;
    
    function storeByte(uint8 slot, uint8 value) public {
        require(slot < 32, "Slot must be between 0 and 31");
        
        uint256 position = slot * 8;
        
        uint256 clearMask = ~(uint256(0xFF) << position);
        bitmap = bitmap & clearMask;
        
        bitmap = bitmap | (uint256(value) << position);
    }
    
    function getByte(uint8 slot) public view returns (uint8) {
        require(slot < 32, "Slot must be between 0 and 31");
        
        uint256 position = slot * 8;
        return uint8((bitmap >> position) & 0xFF);
    }

    function getAllBytes() public view returns (uint8[32] memory) {
        uint8[32] memory result;
        
        for (uint8 i = 0; i < 32; i++) {
            result[i] = getByte(i);
        }
        
        return result;
    }
    
    function getRawBitmap() public view returns (uint256) {
        return bitmap;
    }
}