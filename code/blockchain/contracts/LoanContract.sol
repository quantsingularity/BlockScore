pragma solidity ^0.8.0;

contract LoanContract {
    struct Loan {
        address borrower;
        uint256 amount;
        uint256 interestRate;
        bool approved;
    }
    
    mapping(address => Loan) public loans;
    
    event LoanCreated(address indexed borrower, uint256 amount);
    event LoanApproved(address indexed borrower);

    function createLoan(uint256 amount, uint256 interestRate) external {
        loans[msg.sender] = Loan(msg.sender, amount, interestRate, false);
        emit LoanCreated(msg.sender, amount);
    }

    function approveLoan(address borrower) external {
        require(!loans[borrower].approved, "Loan already approved");
        loans[borrower].approved = true;
        emit LoanApproved(borrower);
    }
}