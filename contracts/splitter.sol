// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title Splitter to split sent ETH to addresses provided
 * @author Deniz Ariyan
 * @dev Requires OpenZeppelin's Ownable and Pausable contracts
 * @notice This is an experimental contract
 */
contract Splitter is Pausable, Ownable {
    uint256 public totalSent;
    uint256 public sentInThisTx;

    constructor() {
        _pause();
        totalSent = 0;
        sentInThisTx = 0;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function exitHandler() private {
        require(
            msg.value >= sentInThisTx,
            "Ether being tried to sent exceeds Ether provided!"
        );
        totalSent += sentInThisTx;
    }

    function send(address payable _addr, uint256 amount) private {
        _addr.transfer(amount);
        sentInThisTx += amount;
        exitHandler();
    }

    function initiateTransfer(
        address payable[] memory _addresses,
        uint256[] memory _amounts
    ) external payable whenNotPaused {
        sentInThisTx = 0;
        require(
            _addresses.length == _amounts.length,
            "Number of receivers and shares don't match!"
        );
        uint256 numOfReceivers = _addresses.length;
        for (uint256 i = 0; i < numOfReceivers; i++) {
            send(_addresses[i], _amounts[i]);
        }
    }
}
