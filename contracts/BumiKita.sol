// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BumiKita is ERC20, Ownable {
    mapping(address => bool) public authorizedSellers;

    uint256 private constant TOTAL_SUPPLY = 100_000_000 * 10**18;
    uint256 public maxWalletBalance = 5_000_000 * 10**18;
    uint256 public maxTransactionAmount = 1_000_000 * 10**18;

    constructor() ERC20("BumiKita", "BMK") Ownable(msg.sender) {
        _mint(msg.sender, TOTAL_SUPPLY);
        authorizedSellers[msg.sender] = true;
    }

    function setAuthorizedSeller(address account, bool allowed) external onlyOwner {
        authorizedSellers[account] = allowed;
    }

    function _update(address from, address to, uint256 value) internal override {
        if (from != address(0) && to != address(0)) {
            if (!authorizedSellers[from] && from != owner()) {
                require(to == owner(), "Hanya seller resmi boleh transfer keluar");
            }

            if (to != owner()) {
                require(balanceOf(to) + value <= maxWalletBalance, "Saldo melebihi batas");
            }

            require(value <= maxTransactionAmount, "Jumlah transfer melebihi batas");
        }

        super._update(from, to, value);
    }
}
