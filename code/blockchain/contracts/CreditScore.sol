// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title CreditScore
 * @dev Manages credit records and scoring for users on the blockchain
 */
contract CreditScore {
    struct CreditRecord {
        uint256 timestamp;
        uint256 amount;
        bool repaid;
        uint256 repaymentTimestamp;
        address provider;
        string recordType; // "loan", "payment", "utility", etc.
        int8 scoreImpact; // -10 to 10 scale of impact on credit score
    }

    struct CreditProfile {
        uint256 score;
        bool exists;
        uint256 lastUpdated;
    }

    // Mapping from user address to their credit records
    mapping(address => CreditRecord[]) private creditHistory;

    // Mapping from user address to their credit profile
    mapping(address => CreditProfile) private creditProfiles;

    // Mapping for authorized credit providers
    mapping(address => bool) private authorizedProviders;

    // Contract owner
    address private owner;

    // Events
    event NewCreditRecord(
        address indexed user,
        address indexed provider,
        uint256 amount,
        string recordType
    );
    event RecordRepaid(address indexed user, uint256 recordIndex, uint256 timestamp);
    event ScoreUpdated(address indexed user, uint256 newScore);
    event ProviderAuthorized(address indexed provider);
    event ProviderRevoked(address indexed provider);

    /**
     * @dev Constructor sets the contract deployer as owner
     */
    constructor() {
        owner = msg.sender;
        authorizedProviders[msg.sender] = true;
    }

    /**
     * @dev Modifier to restrict functions to owner only
     */
    modifier onlyOwner() {
        require(msg.sender == owner, 'Only owner can call this function');
        _;
    }

    /**
     * @dev Modifier to restrict functions to authorized providers
     */
    modifier onlyAuthorizedProvider() {
        require(
            authorizedProviders[msg.sender],
            'Only authorized providers can call this function'
        );
        _;
    }

    /**
     * @dev Authorizes a new credit provider
     * @param provider Address of the provider to authorize
     */
    function authorizeProvider(address provider) external onlyOwner {
        authorizedProviders[provider] = true;
        emit ProviderAuthorized(provider);
    }

    /**
     * @dev Revokes authorization from a credit provider
     * @param provider Address of the provider to revoke
     */
    function revokeProvider(address provider) external onlyOwner {
        require(provider != owner, "Cannot revoke owner's authorization");
        authorizedProviders[provider] = false;
        emit ProviderRevoked(provider);
    }

    /**
     * @dev Adds a credit record for a user
     * @param user Address of the user
     * @param amount Amount involved in the credit event
     * @param recordType Type of credit record (loan, payment, etc.)
     * @param scoreImpact Impact on credit score (-10 to 10)
     */
    function addCreditRecord(
        address user,
        uint256 amount,
        string calldata recordType,
        int8 scoreImpact
    ) external onlyAuthorizedProvider {
        require(scoreImpact >= -10 && scoreImpact <= 10, 'Score impact must be between -10 and 10');

        creditHistory[user].push(
            CreditRecord(block.timestamp, amount, false, 0, msg.sender, recordType, scoreImpact)
        );

        // Initialize credit profile if it doesn't exist
        if (!creditProfiles[user].exists) {
            creditProfiles[user] = CreditProfile(500, true, block.timestamp); // Default score of 500
        }

        // Update credit score based on the impact
        updateCreditScore(user, scoreImpact);

        emit NewCreditRecord(user, msg.sender, amount, recordType);
    }

    /**
     * @dev Marks a credit record as repaid
     * @param user Address of the user
     * @param recordIndex Index of the record in the user's credit history
     */
    function markRepaid(address user, uint256 recordIndex) external onlyAuthorizedProvider {
        require(recordIndex < creditHistory[user].length, 'Record index out of bounds');
        require(!creditHistory[user][recordIndex].repaid, 'Record already marked as repaid');

        creditHistory[user][recordIndex].repaid = true;
        creditHistory[user][recordIndex].repaymentTimestamp = block.timestamp;

        // Positive impact on credit score when repaid
        updateCreditScore(user, 5);

        emit RecordRepaid(user, recordIndex, block.timestamp);
    }

    /**
     * @dev Updates a user's credit score
     * @param user Address of the user
     * @param impact Impact on the score
     */
    function updateCreditScore(address user, int8 impact) private {
        int256 newScore = int256(creditProfiles[user].score) + impact;

        // Ensure score stays within bounds (300-850)
        if (newScore < 300) newScore = 300;
        if (newScore > 850) newScore = 850;

        creditProfiles[user].score = uint256(newScore);
        creditProfiles[user].lastUpdated = block.timestamp;

        emit ScoreUpdated(user, uint256(newScore));
    }

    /**
     * @dev Gets a user's credit score
     * @param user Address of the user
     * @return score The user's credit score (300-850)
     * @return lastUpdated Timestamp of last score update
     */
    function getCreditScore(
        address user
    ) external view returns (uint256 score, uint256 lastUpdated) {
        if (!creditProfiles[user].exists) {
            return (0, 0);
        }
        return (creditProfiles[user].score, creditProfiles[user].lastUpdated);
    }

    /**
     * @dev Gets a user's credit history
     * @param user Address of the user
     * @return Array of user's credit records
     */
    function getCreditHistory(address user) external view returns (CreditRecord[] memory) {
        return creditHistory[user];
    }

    /**
     * @dev Checks if an address is an authorized provider
     * @param provider Address to check
     * @return True if the address is an authorized provider
     */
    function isAuthorizedProvider(address provider) external view returns (bool) {
        return authorizedProviders[provider];
    }
}
