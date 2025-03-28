// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {TokenMint} from "../src/TokenMint.sol";
import "oz/utils/cryptography/ECDSA.sol";

contract TokenMintScript is Script {
    function run() public returns (TokenMint, address, bytes memory) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        address deployer = vm.addr(deployerPrivateKey);
        
        vm.startBroadcast(deployerPrivateKey);

        TokenMint tokenMint = new TokenMint();
        address recipient = 0x1234567890123456789012345678901234567890; 
        uint256 mintAmount = 100 ether;
        

        bytes32 hash = keccak256(abi.encodePacked(recipient, mintAmount));
        hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(deployerPrivateKey, hash);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        vm.stopBroadcast();
        
        return (tokenMint, recipient, signature);
    }
}