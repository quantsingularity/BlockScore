#!/bin/bash
# ========================================================================
# BlockScore Unified Environment Setup Script
#
# This script automates the complete setup of the BlockScore development
# environment, including all dependencies, configurations, and initial setup.
#
# Features:
# - Automatic OS detection and package installation
# - Python, Node.js, and MongoDB setup
# - Blockchain development environment configuration
# - Environment variable management
# - Project structure validation
# ========================================================================

# Set strict error handling
set -e

# Define colors for terminal output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print banner
echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}          BlockScore Development Environment Setup              ${NC}"
echo -e "${BLUE}================================================================${NC}"

# Define project directory
PROJECT_DIR="$(pwd)"
CONFIG_DIR="${PROJECT_DIR}/.blockscore_config"

# Create configuration directory if it doesn't exist
mkdir -p "${CONFIG_DIR}"

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to detect OS
detect_os() {
  echo -e "${BLUE}Detecting operating system...${NC}"

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    if command_exists apt-get; then
      PACKAGE_MANAGER="apt-get"
    elif command_exists yum; then
      PACKAGE_MANAGER="yum"
    elif command_exists dnf; then
      PACKAGE_MANAGER="dnf"
    else
      echo -e "${RED}Unsupported Linux distribution. Please install dependencies manually.${NC}"
      exit 1
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    if command_exists brew; then
      PACKAGE_MANAGER="brew"
    else
      echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      PACKAGE_MANAGER="brew"
    fi
  else
    echo -e "${RED}Unsupported operating system: $OSTYPE${NC}"
    exit 1
  fi

  echo -e "${GREEN}Detected OS: $OS using $PACKAGE_MANAGER${NC}"
}

# Function to install system dependencies
install_system_dependencies() {
  echo -e "${BLUE}Installing system dependencies...${NC}"

  if [[ "$PACKAGE_MANAGER" == "apt-get" ]]; then
    sudo apt-get update
    sudo apt-get install -y build-essential curl wget git python3 python3-pip python3-venv
  elif [[ "$PACKAGE_MANAGER" == "yum" || "$PACKAGE_MANAGER" == "dnf" ]]; then
    sudo $PACKAGE_MANAGER update -y
    sudo $PACKAGE_MANAGER install -y gcc gcc-c++ make curl wget git python3 python3-pip python3-devel
  elif [[ "$PACKAGE_MANAGER" == "brew" ]]; then
    brew update
    brew install git python@3 wget
  fi

  echo -e "${GREEN}System dependencies installed successfully.${NC}"
}

# Function to setup Python environment
setup_python_environment() {
  echo -e "${BLUE}Setting up Python environment...${NC}"

  # Check Python version
  if command_exists python3; then
    PYTHON_VERSION=$(python3 --version | cut -d ' ' -f 2)
    echo -e "${GREEN}Found Python $PYTHON_VERSION${NC}"

    # Create virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
      echo -e "${YELLOW}Creating Python virtual environment...${NC}"
      python3 -m venv venv
    fi

    # Activate virtual environment
    echo -e "${YELLOW}Activating Python virtual environment...${NC}"
    source venv/bin/activate

    # Install Python dependencies
    echo -e "${YELLOW}Installing Python dependencies...${NC}"
    pip install --upgrade pip

    # Install AI model dependencies
    if [ -f "code/ai_models/requirements.txt" ]; then
      pip install -r code/ai_models/requirements.txt
    else
      # Install common data science packages if requirements.txt doesn't exist
      pip install numpy pandas scikit-learn tensorflow torch matplotlib
    fi

    echo -e "${GREEN}Python environment setup complete.${NC}"
  else
    echo -e "${RED}Python 3 not found. Please install Python 3.8 or higher.${NC}"
    exit 1
  fi
}

# Function to setup Node.js environment
setup_node_environment() {
  echo -e "${BLUE}Setting up Node.js environment...${NC}"

  # Check if Node.js is installed
  if command_exists node; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}Found Node.js $NODE_VERSION${NC}"
  else
    echo -e "${YELLOW}Node.js not found. Installing Node.js...${NC}"

    if [[ "$OS" == "linux" ]]; then
      curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
      sudo $PACKAGE_MANAGER install -y nodejs
    elif [[ "$OS" == "macos" ]]; then
      brew install node@16
    fi

    NODE_VERSION=$(node --version)
    echo -e "${GREEN}Installed Node.js $NODE_VERSION${NC}"
  fi

  # Install global Node.js packages
  echo -e "${YELLOW}Installing global Node.js packages...${NC}"
  npm install -g npm@latest
  npm install -g hardhat truffle ganache-cli

  # Install backend dependencies
  if [ -d "code/backend" ]; then
    echo -e "${YELLOW}Installing backend dependencies...${NC}"
    cd code/backend
    npm install
    # Create .env file if it doesn't exist
    if [ ! -f ".env" ] && [ -f ".env.example" ]; then
      cp .env.example .env
      echo -e "${YELLOW}Created .env file from .env.example. Please update with your configuration.${NC}"
    fi
    cd "${PROJECT_DIR}"
  fi

  # Install frontend dependencies
  if [ -d "code/frontend" ]; then
    echo -e "${YELLOW}Installing frontend dependencies...${NC}"
    cd code/frontend
    npm install
    # Create .env file if it doesn't exist
    if [ ! -f ".env" ] && [ -f ".env.example" ]; then
      cp .env.example .env
      echo -e "${YELLOW}Created .env file from .env.example. Please update with your configuration.${NC}"
    fi
    cd "${PROJECT_DIR}"
  fi

  # Install blockchain dependencies
  if [ -d "code/blockchain" ]; then
    echo -e "${YELLOW}Installing blockchain dependencies...${NC}"
    cd code/blockchain
    npm install
    cd "${PROJECT_DIR}"
  fi

  # Install mobile frontend dependencies
  if [ -d "mobile-frontend" ]; then
    echo -e "${YELLOW}Installing mobile frontend dependencies...${NC}"
    cd mobile-frontend
    npm install
    cd "${PROJECT_DIR}"
  fi

  echo -e "${GREEN}Node.js environment setup complete.${NC}"
}

# Function to setup MongoDB
setup_mongodb() {
  echo -e "${BLUE}Setting up MongoDB...${NC}"

  if command_exists mongod; then
    MONGO_VERSION=$(mongod --version | grep "db version" | cut -d ' ' -f 3)
    echo -e "${GREEN}Found MongoDB $MONGO_VERSION${NC}"
  else
    echo -e "${YELLOW}MongoDB not found. Installing MongoDB...${NC}"

    if [[ "$OS" == "linux" ]]; then
      if [[ "$PACKAGE_MANAGER" == "apt-get" ]]; then
        wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
        echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
        sudo apt-get update
        sudo apt-get install -y mongodb-org
        sudo systemctl start mongod
        sudo systemctl enable mongod
      elif [[ "$PACKAGE_MANAGER" == "yum" || "$PACKAGE_MANAGER" == "dnf" ]]; then
        echo "[mongodb-org-5.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/5.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-5.0.asc" | sudo tee /etc/yum.repos.d/mongodb-org-5.0.repo
        sudo $PACKAGE_MANAGER install -y mongodb-org
        sudo systemctl start mongod
        sudo systemctl enable mongod
      fi
    elif [[ "$OS" == "macos" ]]; then
      brew tap mongodb/brew
      brew install mongodb-community
      brew services start mongodb-community
    fi

    echo -e "${GREEN}MongoDB installed and started.${NC}"
  fi
}

# Function to setup Ethereum development environment
setup_ethereum_environment() {
  echo -e "${BLUE}Setting up Ethereum development environment...${NC}"

  # Check if Ganache CLI is installed
  if command_exists ganache-cli; then
    echo -e "${GREEN}Found Ganache CLI$(ganache-cli --version)${NC}"
  else
    echo -e "${YELLOW}Installing Ganache CLI...${NC}"
    npm install -g ganache-cli
  fi

  # Check if Hardhat is installed
  if command_exists npx && npx hardhat --version >/dev/null 2>&1; then
    echo -e "${GREEN}Found Hardhat$(npx hardhat --version)${NC}"
  else
    echo -e "${YELLOW}Installing Hardhat...${NC}"
    npm install -g hardhat
  fi

  echo -e "${GREEN}Ethereum development environment setup complete.${NC}"
}

# Function to validate project structure
validate_project_structure() {
  echo -e "${BLUE}Validating project structure...${NC}"

  # Check if essential directories exist
  MISSING_DIRS=()

  for dir in "code" "code/backend" "code/frontend" "code/blockchain" "code/ai_models"; do
    if [ ! -d "$dir" ]; then
      MISSING_DIRS+=("$dir")
    fi
  done

  if [ ${#MISSING_DIRS[@]} -ne 0 ]; then
    echo -e "${YELLOW}Warning: The following directories are missing:${NC}"
    for dir in "${MISSING_DIRS[@]}"; do
      echo -e "${YELLOW}  - $dir${NC}"
    done

    read -p "Do you want to create these directories? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      for dir in "${MISSING_DIRS[@]}"; do
        mkdir -p "$dir"
        echo -e "${GREEN}Created directory: $dir${NC}"
      done
    fi
  else
    echo -e "${GREEN}Project structure validation passed.${NC}"
  fi
}

# Function to setup environment variables
setup_environment_variables() {
  echo -e "${BLUE}Setting up environment variables...${NC}"

  ENV_FILE="${CONFIG_DIR}/environment.sh"

  # Create environment variables file if it doesn't exist
  if [ ! -f "$ENV_FILE" ]; then
    echo "#!/bin/bash
# BlockScore Environment Variables

# Backend Configuration
export BLOCKSCORE_API_PORT=3000
export BLOCKSCORE_DB_URI=\"mongodb://localhost:27017/blockscore\"
export BLOCKSCORE_JWT_SECRET=\"change_this_to_a_secure_secret\"

# Frontend Configuration
export BLOCKSCORE_FRONTEND_PORT=8080
export BLOCKSCORE_API_URL=\"http://localhost:3000\"

# Blockchain Configuration
export BLOCKSCORE_NETWORK=\"development\"
export BLOCKSCORE_PROVIDER_URL=\"http://localhost:8545\"
export BLOCKSCORE_PRIVATE_KEY=\"\" # Add your private key for deployment

# AI Model Configuration
export BLOCKSCORE_MODEL_PATH=\"${PROJECT_DIR}/code/ai_models/trained_models\"
export BLOCKSCORE_DATA_PATH=\"${PROJECT_DIR}/resources/data\"
" > "$ENV_FILE"

    chmod +x "$ENV_FILE"
    echo -e "${GREEN}Created environment variables file: $ENV_FILE${NC}"
    echo -e "${YELLOW}Please update the environment variables with your configuration.${NC}"
  else
    echo -e "${GREEN}Environment variables file already exists: $ENV_FILE${NC}"
  fi

  # Source environment variables
  source "$ENV_FILE"

  # Create .env files for different components
  if [ -d "code/backend" ]; then
    echo "PORT=$BLOCKSCORE_API_PORT
MONGODB_URI=$BLOCKSCORE_DB_URI
JWT_SECRET=$BLOCKSCORE_JWT_SECRET
NODE_ENV=development
" > "code/backend/.env"
    echo -e "${GREEN}Created .env file for backend.${NC}"
  fi

  if [ -d "code/frontend" ]; then
    echo "REACT_APP_API_URL=$BLOCKSCORE_API_URL
PORT=$BLOCKSCORE_FRONTEND_PORT
" > "code/frontend/.env"
    echo -e "${GREEN}Created .env file for frontend.${NC}"
  fi

  if [ -d "code/blockchain" ]; then
    echo "NETWORK=$BLOCKSCORE_NETWORK
PROVIDER_URL=$BLOCKSCORE_PROVIDER_URL
PRIVATE_KEY=$BLOCKSCORE_PRIVATE_KEY
" > "code/blockchain/.env"
    echo -e "${GREEN}Created .env file for blockchain.${NC}"
  fi

  echo -e "${GREEN}Environment variables setup complete.${NC}"
}

# Function to create a setup completion marker
create_setup_marker() {
  echo -e "${BLUE}Creating setup completion marker...${NC}"

  SETUP_DATE=$(date "+%Y-%m-%d %H:%M:%S")
  echo "{
  \"setup_completed\": true,
  \"setup_date\": \"$SETUP_DATE\",
  \"os\": \"$OS\",
  \"python_version\": \"$PYTHON_VERSION\",
  \"node_version\": \"$NODE_VERSION\"
}" > "${CONFIG_DIR}/setup_complete.json"

  echo -e "${GREEN}Setup completion marker created.${NC}"
}

# Main execution
main() {
  # Check if setup has already been completed
  if [ -f "${CONFIG_DIR}/setup_complete.json" ]; then
    echo -e "${YELLOW}Environment setup has already been completed.${NC}"
    read -p "Do you want to run the setup again? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo -e "${GREEN}Setup skipped. Using existing environment.${NC}"
      return 0
    fi
  fi

  # Run setup steps
  detect_os
  install_system_dependencies
  validate_project_structure
  setup_python_environment
  setup_node_environment
  setup_mongodb
  setup_ethereum_environment
  setup_environment_variables
  create_setup_marker

  echo -e "${GREEN}BlockScore development environment setup completed successfully!${NC}"
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${YELLOW}Next steps:${NC}"
  echo -e "${YELLOW}1. Update environment variables in ${CONFIG_DIR}/environment.sh${NC}"
  echo -e "${YELLOW}2. Start the application using ./run_blockscore.sh${NC}"
  echo -e "${YELLOW}3. Visit http://localhost:8080 to access the application${NC}"
  echo -e "${BLUE}================================================================${NC}"
}

# Execute main function
main
