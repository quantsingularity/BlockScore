#!/bin/bash
# ========================================================================
# BlockScore Smart Contract Deployment Automation Script
# 
# This script automates the deployment of smart contracts to different
# blockchain networks with proper configuration and verification.
# 
# Features:
# - Multi-network deployment support (development, test, mainnet)
# - Contract verification on block explorers
# - Gas optimization
# - Deployment tracking and history
# - Security checks before deployment
# ========================================================================

# Set strict error handling
set -e

# Define colors for terminal output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Define project directory
PROJECT_DIR="$(pwd)"
BLOCKCHAIN_DIR="${PROJECT_DIR}/code/blockchain"
CONFIG_DIR="${PROJECT_DIR}/.blockscore_config"
DEPLOYMENT_LOG="${PROJECT_DIR}/deployment.log"

# Print banner
echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}          BlockScore Smart Contract Deployment System           ${NC}"
echo -e "${BLUE}================================================================${NC}"

# Initialize log file
echo "BlockScore Deployment Log - $(date)" > "$DEPLOYMENT_LOG"

# Parse command line arguments
NETWORK="development"
VERIFY=false
GAS_OPTIMIZATION=true
SECURITY_CHECK=true

print_usage() {
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  -h, --help                 Show this help message"
  echo "  -n, --network <network>    Specify network (development, test, mainnet)"
  echo "  -v, --verify               Verify contracts on block explorer"
  echo "  --no-gas-optimization      Disable gas optimization"
  echo "  --no-security-check        Disable security checks"
  echo ""
  echo "Examples:"
  echo "  $0                         Deploy to development network"
  echo "  $0 -n test -v              Deploy to test network and verify contracts"
  echo "  $0 -n mainnet -v           Deploy to mainnet and verify contracts"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      print_usage
      exit 0
      ;;
    -n|--network)
      NETWORK="$2"
      shift 2
      ;;
    -v|--verify)
      VERIFY=true
      shift
      ;;
    --no-gas-optimization)
      GAS_OPTIMIZATION=false
      shift
      ;;
    --no-security-check)
      SECURITY_CHECK=false
      shift
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      print_usage
      exit 1
      ;;
  esac
done

# Validate network
if [[ ! "$NETWORK" =~ ^(development|test|mainnet)$ ]]; then
  echo -e "${RED}Invalid network: $NETWORK${NC}"
  echo -e "${YELLOW}Valid networks: development, test, mainnet${NC}"
  exit 1
fi

# Function to log messages
log_message() {
  local level=$1
  local message=$2
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  
  echo "[$timestamp] [$level] $message" >> "$DEPLOYMENT_LOG"
  
  case $level in
    INFO)
      echo -e "${BLUE}[$level] $message${NC}"
      ;;
    SUCCESS)
      echo -e "${GREEN}[$level] $message${NC}"
      ;;
    WARNING)
      echo -e "${YELLOW}[$level] $message${NC}"
      ;;
    ERROR)
      echo -e "${RED}[$level] $message${NC}"
      ;;
    *)
      echo "[$level] $message"
      ;;
  esac
}

# Function to check if blockchain directory exists
check_blockchain_directory() {
  if [ ! -d "$BLOCKCHAIN_DIR" ]; then
    log_message "ERROR" "Blockchain directory not found: $BLOCKCHAIN_DIR"
    exit 1
  fi
  
  if [ ! -f "${BLOCKCHAIN_DIR}/hardhat.config.js" ] && [ ! -f "${BLOCKCHAIN_DIR}/hardhat.config.ts" ]; then
    log_message "ERROR" "Hardhat configuration not found in blockchain directory"
    exit 1
  }
  
  log_message "INFO" "Blockchain directory validated"
}

# Function to load environment variables
load_environment_variables() {
  log_message "INFO" "Loading environment variables for network: $NETWORK"
  
  # Check if .env file exists
  if [ -f "${BLOCKCHAIN_DIR}/.env" ]; then
    source "${BLOCKCHAIN_DIR}/.env"
    log_message "INFO" "Loaded environment variables from .env file"
  else
    log_message "WARNING" ".env file not found in blockchain directory"
  fi
  
  # Check if network-specific .env file exists
  if [ -f "${BLOCKCHAIN_DIR}/.env.${NETWORK}" ]; then
    source "${BLOCKCHAIN_DIR}/.env.${NETWORK}"
    log_message "INFO" "Loaded environment variables from .env.${NETWORK} file"
  fi
  
  # Validate required environment variables
  if [ "$NETWORK" != "development" ]; then
    if [ -z "$PROVIDER_URL" ]; then
      log_message "ERROR" "PROVIDER_URL environment variable not set for network: $NETWORK"
      exit 1
    fi
    
    if [ -z "$PRIVATE_KEY" ]; then
      log_message "ERROR" "PRIVATE_KEY environment variable not set for network: $NETWORK"
      exit 1
    fi
  fi
  
  log_message "SUCCESS" "Environment variables loaded successfully"
}

# Function to run security checks
run_security_checks() {
  if [ "$SECURITY_CHECK" = false ]; then
    log_message "WARNING" "Security checks disabled"
    return 0
  }
  
  log_message "INFO" "Running security checks on smart contracts"
  
  cd "$BLOCKCHAIN_DIR"
  
  # Check if solhint is installed
  if ! npm list -g solhint > /dev/null 2>&1 && ! npm list solhint > /dev/null 2>&1; then
    log_message "INFO" "Installing solhint..."
    npm install --save-dev solhint
  fi
  
  # Run solhint
  log_message "INFO" "Running solhint..."
  npx solhint "contracts/**/*.sol" || {
    log_message "ERROR" "Solhint found issues in smart contracts"
    read -p "Continue with deployment despite security issues? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      log_message "INFO" "Deployment aborted by user"
      exit 1
    fi
  }
  
  # Check if slither is installed (if Python is available)
  if command -v python3 > /dev/null && ! pip list | grep slither-analyzer > /dev/null; then
    log_message "INFO" "Installing slither-analyzer..."
    pip install slither-analyzer
  fi
  
  # Run slither if available
  if command -v slither > /dev/null; then
    log_message "INFO" "Running slither..."
    slither . || {
      log_message "WARNING" "Slither found potential vulnerabilities"
      read -p "Continue with deployment despite potential vulnerabilities? (y/n) " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_message "INFO" "Deployment aborted by user"
        exit 1
      fi
    }
  else
    log_message "WARNING" "Slither not available, skipping advanced vulnerability checks"
  fi
  
  log_message "SUCCESS" "Security checks completed"
}

# Function to optimize gas usage
optimize_gas() {
  if [ "$GAS_OPTIMIZATION" = false ]; then
    log_message "WARNING" "Gas optimization disabled"
    return 0
  }
  
  log_message "INFO" "Optimizing gas usage for smart contracts"
  
  cd "$BLOCKCHAIN_DIR"
  
  # Check if hardhat.config.js or hardhat.config.ts exists
  if [ -f "hardhat.config.js" ]; then
    CONFIG_FILE="hardhat.config.js"
  elif [ -f "hardhat.config.ts" ]; then
    CONFIG_FILE="hardhat.config.ts"
  else
    log_message "ERROR" "Hardhat configuration file not found"
    exit 1
  fi
  
  # Check if optimization is already enabled
  if grep -q "optimizer: { enabled: true" "$CONFIG_FILE"; then
    log_message "INFO" "Gas optimization already enabled in $CONFIG_FILE"
  else
    # Backup the config file
    cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
    
    # Add optimization settings
    if grep -q "solidity:" "$CONFIG_FILE"; then
      # Update existing solidity settings
      sed -i 's/solidity: {/solidity: {\n    settings: {\n      optimizer: { enabled: true, runs: 200 },\n    },/g' "$CONFIG_FILE"
    else
      # Add new solidity settings
      sed -i '/module.exports = {/a \  solidity: {\n    settings: {\n      optimizer: { enabled: true, runs: 200 },\n    },\n  },' "$CONFIG_FILE"
    fi
    
    log_message "SUCCESS" "Gas optimization enabled in $CONFIG_FILE"
  fi
}

# Function to compile contracts
compile_contracts() {
  log_message "INFO" "Compiling smart contracts"
  
  cd "$BLOCKCHAIN_DIR"
  
  # Clean artifacts and cache
  if [ -d "artifacts" ]; then
    rm -rf artifacts
  fi
  
  if [ -d "cache" ]; then
    rm -rf cache
  fi
  
  # Compile contracts
  npx hardhat compile
  
  if [ $? -ne 0 ]; then
    log_message "ERROR" "Failed to compile smart contracts"
    exit 1
  fi
  
  log_message "SUCCESS" "Smart contracts compiled successfully"
}

# Function to deploy contracts
deploy_contracts() {
  log_message "INFO" "Deploying smart contracts to network: $NETWORK"
  
  cd "$BLOCKCHAIN_DIR"
  
  # Create deployment directory if it doesn't exist
  mkdir -p "deployments/$NETWORK"
  
  # Run deployment script
  if [ -f "scripts/deploy.js" ]; then
    DEPLOY_SCRIPT="scripts/deploy.js"
  elif [ -f "scripts/deploy.ts" ]; then
    DEPLOY_SCRIPT="scripts/deploy.ts"
  else
    log_message "ERROR" "Deployment script not found"
    exit 1
  fi
  
  log_message "INFO" "Running deployment script: $DEPLOY_SCRIPT"
  
  # Deploy contracts
  npx hardhat run "$DEPLOY_SCRIPT" --network "$NETWORK"
  
  if [ $? -ne 0 ]; then
    log_message "ERROR" "Failed to deploy smart contracts"
    exit 1
  fi
  
  log_message "SUCCESS" "Smart contracts deployed successfully to network: $NETWORK"
}

# Function to verify contracts on block explorer
verify_contracts() {
  if [ "$VERIFY" = false ]; then
    log_message "INFO" "Contract verification skipped"
    return 0
  fi
  
  if [ "$NETWORK" = "development" ]; then
    log_message "WARNING" "Contract verification not supported on development network"
    return 0
  fi
  
  log_message "INFO" "Verifying smart contracts on block explorer"
  
  cd "$BLOCKCHAIN_DIR"
  
  # Check if deployment addresses file exists
  DEPLOYMENT_FILE="deployments/$NETWORK/addresses.json"
  
  if [ ! -f "$DEPLOYMENT_FILE" ]; then
    log_message "ERROR" "Deployment addresses file not found: $DEPLOYMENT_FILE"
    log_message "WARNING" "Contract verification skipped"
    return 1
  fi
  
  # Read contract addresses from deployment file
  CONTRACTS=$(cat "$DEPLOYMENT_FILE" | jq -r 'keys[]')
  
  for CONTRACT in $CONTRACTS; do
    ADDRESS=$(cat "$DEPLOYMENT_FILE" | jq -r ".[\"$CONTRACT\"]")
    
    log_message "INFO" "Verifying contract: $CONTRACT at address: $ADDRESS"
    
    # Verify contract
    npx hardhat verify --network "$NETWORK" "$ADDRESS" || {
      log_message "WARNING" "Failed to verify contract: $CONTRACT"
      continue
    }
    
    log_message "SUCCESS" "Contract verified: $CONTRACT"
  done
  
  log_message "SUCCESS" "Contract verification completed"
}

# Function to create deployment record
create_deployment_record() {
  log_message "INFO" "Creating deployment record"
  
  # Create config directory if it doesn't exist
  mkdir -p "$CONFIG_DIR"
  
  # Create deployment record
  DEPLOYMENT_RECORD="${CONFIG_DIR}/deployment_${NETWORK}_$(date +%Y%m%d%H%M%S).json"
  
  # Copy deployment addresses
  if [ -f "${BLOCKCHAIN_DIR}/deployments/$NETWORK/addresses.json" ]; then
    cp "${BLOCKCHAIN_DIR}/deployments/$NETWORK/addresses.json" "$DEPLOYMENT_RECORD"
    log_message "SUCCESS" "Deployment record created: $DEPLOYMENT_RECORD"
  else
    log_message "WARNING" "Deployment addresses file not found, record not created"
  fi
}

# Main execution
main() {
  log_message "INFO" "Starting smart contract deployment process"
  
  # Check blockchain directory
  check_blockchain_directory
  
  # Load environment variables
  load_environment_variables
  
  # Run security checks
  run_security_checks
  
  # Optimize gas usage
  optimize_gas
  
  # Compile contracts
  compile_contracts
  
  # Deploy contracts
  deploy_contracts
  
  # Verify contracts
  verify_contracts
  
  # Create deployment record
  create_deployment_record
  
  log_message "SUCCESS" "Smart contract deployment process completed"
  
  echo -e "${GREEN}Deployment completed successfully!${NC}"
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${BLUE}Deployment Log: $DEPLOYMENT_LOG${NC}"
  echo -e "${BLUE}================================================================${NC}"
}

# Execute main function
main
