// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CreditScore.sol";

/**
 * @title LoanContract
 * @dev Manages loan creation, approval, and repayment with credit score integration
 */
contract LoanContract {
    struct Loan {
        address borrower;
        uint256 amount;
        uint256 interestRate;
        uint256 creationTimestamp;
        uint256 dueDate;
        bool approved;
        bool repaid;
        uint256 repaymentTimestamp;
    }

    // Credit Score contract reference
    CreditScore private creditScoreContract;

    // Mapping from loan ID to loan details
    mapping(uint256 => Loan) public loans;

    // Mapping from borrower to their loan IDs
    mapping(address => uint256[]) private borrowerLoans;

    // Loan counter for generating unique IDs
    uint256 private loanCounter;

    // Contract owner
    address private owner;

    // Events
    event LoanCreated(uint256 indexed loanId, address indexed borrower, uint256 amount);
    event LoanApproved(uint256 indexed loanId, address indexed borrower);
    event LoanRepaid(uint256 indexed loanId, address indexed borrower, uint256 timestamp);

    /**
     * @dev Constructor sets the contract deployer as owner and links to CreditScore contract
     * @param creditScoreAddress Address of the deployed CreditScore contract
     */
    constructor(address creditScoreAddress) {
        owner = msg.sender;
        creditScoreContract = CreditScore(creditScoreAddress);
        loanCounter = 0;
    }

    /**
     * @dev Modifier to restrict functions to owner only
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /**
     * @dev Creates a new loan request
     * @param amount Loan amount requested
     * @param interestRate Annual interest rate (in basis points, e.g., 500 = 5%)
     * @param durationDays Loan duration in days
     * @return loanId Unique identifier for the created loan
     */
    function createLoan(uint256 amount, uint256 interestRate, uint256 durationDays) external returns (uint256 loanId) {
        require(amount > 0, "Loan amount must be greater than zero");
        require(durationDays > 0, "Loan duration must be greater than zero");

        loanId = loanCounter++;

        loans[loanId] = Loan({
            borrower: msg.sender,
            amount: amount,
            interestRate: interestRate,
            creationTimestamp: block.timestamp,
            dueDate: block.timestamp + (durationDays * 1 days),
            approved: false,
            repaid: false,
            repaymentTimestamp: 0
        });

        borrowerLoans[msg.sender].push(loanId);

        emit LoanCreated(loanId, msg.sender, amount);
        return loanId;
    }

    /**
     * @dev Approves a loan request
     * @param loanId ID of the loan to approve
     */
    function approveLoan(uint256 loanId) external onlyOwner {
        require(loanId < loanCounter, "Invalid loan ID");
        require(!loans[loanId].approved, "Loan already approved");

        loans[loanId].approved = true;

        // Add credit record for the borrower
        creditScoreContract.addCreditRecord(
            loans[loanId].borrower,
            loans[loanId].amount,
            "loan",
            2 // Positive impact for getting approved for a loan
        );

        emit LoanApproved(loanId, loans[loanId].borrower);
    }

    /**
     * @dev Marks a loan as repaid
     * @param loanId ID of the loan to mark as repaid
     */
    function repayLoan(uint256 loanId) external {
        require(loanId < loanCounter, "Invalid loan ID");
        require(loans[loanId].borrower == msg.sender || msg.sender == owner, "Only borrower or owner can repay");
        require(loans[loanId].approved, "Loan not approved");
        require(!loans[loanId].repaid, "Loan already repaid");

        loans[loanId].repaid = true;
        loans[loanId].repaymentTimestamp = block.timestamp;

        // Calculate score impact based on repayment timing
        int8 scoreImpact;
        if (block.timestamp <= loans[loanId].dueDate) {
            // On-time repayment: positive impact
            scoreImpact = 5;
        } else {
            // Late repayment: negative impact
            scoreImpact = -3;
        }

        // Add repayment record
        creditScoreContract.addCreditRecord(
            loans[loanId].borrower,
            loans[loanId].amount,
            "repayment",
            scoreImpact
        );

        emit LoanRepaid(loanId, loans[loanId].borrower, block.timestamp);
    }

    /**
     * @dev Gets all loans for a borrower
     * @param borrower Address of the borrower
     * @return Array of loan IDs belonging to the borrower
     */
    function getBorrowerLoans(address borrower) external view returns (uint256[] memory) {
        return borrowerLoans[borrower];
    }

    /**
     * @dev Gets loan details by ID
     * @param loanId ID of the loan
     * @return Loan struct containing all loan details
     */
    function getLoanDetails(uint256 loanId) external view returns (Loan memory) {
        require(loanId < loanCounter, "Invalid loan ID");
        return loans[loanId];
    }

    /**
     * @dev Gets the credit score of a borrower
     * @param borrower Address of the borrower
     * @return score The borrower's credit score
     * @return lastUpdated Timestamp of last score update
     */
    function getBorrowerCreditScore(address borrower) external view returns (uint256 score, uint256 lastUpdated) {
        return creditScoreContract.getCreditScore(borrower);
    }
}
