pragma solidity ^0.8.0;

contract CreditScore {
    struct CreditRecord {
        uint256 timestamp;
        uint256 amount;
        bool repaid;
    }
    
    mapping(address => CreditRecord[]) public creditHistory;
    
    event NewCreditRecord(address indexed user, uint256 amount);
    
    function addRecord(uint256 amount) external {
        creditHistory[msg.sender].push(CreditRecord(
            block.timestamp,
            amount,
            false
        ));
        emit NewCreditRecord(msg.sender, amount);
    }
    
    function getCreditHistory(address user) external view returns (CreditRecord[] memory) {
        return creditHistory[user];
    }
}