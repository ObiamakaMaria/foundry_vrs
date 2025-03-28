// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TokenMint.sol";
import "oz/utils/cryptography/ECDSA.sol";

contract TokenMintTest is Test {
    TokenMint public tokenMint;
    
    address public signer;
    uint256 public signerPrivateKey;

    function setUp() public {
        // Generate a random address and private key
        (signer, signerPrivateKey) = makeAddrAndKey("testSigner");
        
        // Deploy the contract
        tokenMint = new TokenMint();
    }

    function testMintWithValidSignature() public {
        // Prepare mint details
        uint256 mintAmount = 100 ether;
        
        // Create message hash
        bytes32 messageHash = keccak256(abi.encodePacked(signer, mintAmount));
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );
        
        // Sign the hash
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        // Debug: Print out relevant information
        console.log("Signer Address:", signer);
        console.log("Mint Amount:", mintAmount);
        console.logBytes32(messageHash);
        console.logBytes32(ethSignedMessageHash);
        
        // Verify signature generation
        address recoveredSigner = ECDSA.recover(ethSignedMessageHash, signature);
        console.log("Recovered Signer:", recoveredSigner);
        console.log("Original Signer:", signer);
        assertEq(recoveredSigner, signer, "Signature recovery failed");
        
        // Attempt to mint
        vm.prank(signer);
        tokenMint.mintWithSignature(signer, mintAmount, signature);
        
        // Assert the balance
        assertEq(tokenMint.balanceOf(signer), mintAmount, "Mint should succeed for valid signature");
    }

    function testRevertMintWithInvalidSignature() public {
        // Generate another random address
        address invalidSigner = makeAddr("invalidSigner");
        
        // Prepare mint details
        uint256 mintAmount = 100 ether;
        
        // Create message hash
        bytes32 messageHash = keccak256(abi.encodePacked(invalidSigner, mintAmount));
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );
        
        // Sign the hash with the wrong private key
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        // Attempt to mint should revert
        vm.expectRevert("Unsucessful Minting");
        vm.prank(invalidSigner);
        tokenMint.mintWithSignature(invalidSigner, mintAmount, signature);
    }

    function testMintWithCorrectSignature() public {
        // Prepare mint details
        uint256 mintAmount = 100 ether;
        
        // Create message hash exactly as in the contract
        bytes32 h = keccak256(abi.encodePacked(signer, mintAmount));
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", h)
        );
        
        // Sign the hash
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        // Verify signature generation matches contract's verification
        address recoveredSigner = ECDSA.recover(ethSignedMessageHash, signature);
        assertEq(recoveredSigner, signer, "Signature does not match signer");
        
        // Attempt to mint
        vm.prank(signer);
        tokenMint.mintWithSignature(signer, mintAmount, signature);
        
        // Assert the balance
        assertEq(tokenMint.balanceOf(signer), mintAmount, "Mint should succeed for valid signature");
    }
}