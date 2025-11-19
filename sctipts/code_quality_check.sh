#!/bin/bash
# ========================================================================
# BlockScore Code Quality Check Script
#
# This script performs comprehensive code quality checks across all
# components of the BlockScore project, including linting, formatting,
# security analysis, and best practice enforcement.
#
# Features:
# - Multi-language support (JavaScript, TypeScript, Python, Solidity)
# - Automatic fixing of common issues
# - Detailed reporting
# - Configurable severity levels
# - Pre-commit hook integration
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
REPORT_DIR="${PROJECT_DIR}/code_quality_reports"
REPORT_FILE="${REPORT_DIR}/code_quality_report_$(date +%Y%m%d%H%M%S).md"

# Print banner
echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}          BlockScore Code Quality Check System                  ${NC}"
echo -e "${BLUE}================================================================${NC}"

# Parse command line arguments
FIX_ISSUES=false
CHECK_ALL=true
CHECK_JS=false
CHECK_TS=false
CHECK_PY=false
CHECK_SOL=false
VERBOSE=false

print_usage() {
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  -h, --help                 Show this help message"
  echo "  -f, --fix                  Automatically fix issues when possible"
  echo "  -v, --verbose              Show detailed output"
  echo "  --js                       Check only JavaScript files"
  echo "  --ts                       Check only TypeScript files"
  echo "  --py                       Check only Python files"
  echo "  --sol                      Check only Solidity files"
  echo ""
  echo "Examples:"
  echo "  $0                         Check all file types"
  echo "  $0 -f                      Check all file types and fix issues"
  echo "  $0 --js --ts -f            Check JavaScript and TypeScript files and fix issues"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      print_usage
      exit 0
      ;;
    -f|--fix)
      FIX_ISSUES=true
      shift
      ;;
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    --js)
      CHECK_JS=true
      CHECK_ALL=false
      shift
      ;;
    --ts)
      CHECK_TS=true
      CHECK_ALL=false
      shift
      ;;
    --py)
      CHECK_PY=true
      CHECK_ALL=false
      shift
      ;;
    --sol)
      CHECK_SOL=true
      CHECK_ALL=false
      shift
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      print_usage
      exit 1
      ;;
  esac
done

# If no specific file types are selected, check all
if [ "$CHECK_ALL" = true ]; then
  CHECK_JS=true
  CHECK_TS=true
  CHECK_PY=true
  CHECK_SOL=true
fi

# Create report directory
mkdir -p "$REPORT_DIR"

# Initialize report file
echo "# BlockScore Code Quality Report" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "Generated on: $(date)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## Summary" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Function to log messages
log_message() {
  local level=$1
  local message=$2

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

  # Add to report if not verbose output
  if [[ "$level" != "INFO" || "$VERBOSE" = true ]]; then
    echo "- **$level**: $message" >> "$REPORT_FILE"
  fi
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to install Node.js dependencies
install_node_dependencies() {
  log_message "INFO" "Checking Node.js dependencies"

  cd "$PROJECT_DIR"

  # Create package.json if it doesn't exist
  if [ ! -f "package.json" ]; then
    echo '{
  "name": "blockscore-code-quality",
  "version": "1.0.0",
  "private": true,
  "description": "Code quality tools for BlockScore",
  "scripts": {
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "prettier": "prettier --check .",
    "prettier:fix": "prettier --write ."
  }
}' > "package.json"
  fi

  # Install ESLint if needed
  if ! npm list eslint >/dev/null 2>&1; then
    log_message "INFO" "Installing ESLint"
    npm install --save-dev eslint eslint-config-standard eslint-plugin-import eslint-plugin-node eslint-plugin-promise
  fi

  # Install Prettier if needed
  if ! npm list prettier >/dev/null 2>&1; then
    log_message "INFO" "Installing Prettier"
    npm install --save-dev prettier
  fi

  # Install TypeScript ESLint plugins if needed
  if [ "$CHECK_TS" = true ] && ! npm list @typescript-eslint/eslint-plugin >/dev/null 2>&1; then
    log_message "INFO" "Installing TypeScript ESLint plugins"
    npm install --save-dev typescript @typescript-eslint/parser @typescript-eslint/eslint-plugin
  fi

  # Install Solhint if needed
  if [ "$CHECK_SOL" = true ] && ! npm list solhint >/dev/null 2>&1; then
    log_message "INFO" "Installing Solhint"
    npm install --save-dev solhint
  fi

  log_message "SUCCESS" "Node.js dependencies installed"
}

# Function to install Python dependencies
install_python_dependencies() {
  if [ "$CHECK_PY" = true ]; then
    log_message "INFO" "Checking Python dependencies"

    # Check if pip is available
    if command_exists pip || command_exists pip3; then
      PIP_CMD="pip"
      if ! command_exists pip && command_exists pip3; then
        PIP_CMD="pip3"
      fi

      # Install flake8 if needed
      if ! $PIP_CMD show flake8 >/dev/null 2>&1; then
        log_message "INFO" "Installing flake8"
        $PIP_CMD install flake8
      fi

      # Install black if needed
      if ! $PIP_CMD show black >/dev/null 2>&1; then
        log_message "INFO" "Installing black"
        $PIP_CMD install black
      fi

      # Install isort if needed
      if ! $PIP_CMD show isort >/dev/null 2>&1; then
        log_message "INFO" "Installing isort"
        $PIP_CMD install isort
      fi

      # Install bandit if needed
      if ! $PIP_CMD show bandit >/dev/null 2>&1; then
        log_message "INFO" "Installing bandit"
        $PIP_CMD install bandit
      fi

      log_message "SUCCESS" "Python dependencies installed"
    else
      log_message "ERROR" "Python pip not found. Please install pip to check Python code."
      CHECK_PY=false
    fi
  fi
}

# Function to create configuration files
create_config_files() {
  log_message "INFO" "Creating configuration files if needed"

  cd "$PROJECT_DIR"

  # Create ESLint configuration if it doesn't exist
  if [ ! -f ".eslintrc.js" ] && [ ! -f ".eslintrc.json" ]; then
    echo 'module.exports = {
  env: {
    browser: true,
    es2021: true,
    node: true
  },
  extends: [
    "standard"
  ],
  parserOptions: {
    ecmaVersion: 12,
    sourceType: "module"
  },
  rules: {
  },
  overrides: [
    {
      files: ["*.ts", "*.tsx"],
      parser: "@typescript-eslint/parser",
      plugins: ["@typescript-eslint"],
      extends: [
        "plugin:@typescript-eslint/recommended"
      ]
    }
  ]
}' > ".eslintrc.js"
    log_message "INFO" "Created ESLint configuration"
  fi

  # Create Prettier configuration if it doesn't exist
  if [ ! -f ".prettierrc.json" ] && [ ! -f ".prettierrc.js" ]; then
    echo '{
  "semi": true,
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "trailingComma": "es5",
  "bracketSpacing": true,
  "arrowParens": "avoid"
}' > ".prettierrc.json"
    log_message "INFO" "Created Prettier configuration"
  fi

  # Create Solhint configuration if it doesn't exist
  if [ "$CHECK_SOL" = true ] && [ ! -f ".solhint.json" ]; then
    echo '{
  "extends": "solhint:recommended",
  "rules": {
    "compiler-version": ["error", "^0.8.0"],
    "func-visibility": ["warn", {"ignoreConstructors": true}]
  }
}' > ".solhint.json"
    log_message "INFO" "Created Solhint configuration"
  fi

  # Create flake8 configuration if it doesn't exist
  if [ "$CHECK_PY" = true ] && [ ! -f ".flake8" ]; then
    echo '[flake8]
max-line-length = 100
exclude = .git,__pycache__,build,dist,venv
' > ".flake8"
    log_message "INFO" "Created flake8 configuration"
  fi

  log_message "SUCCESS" "Configuration files created"
}

# Function to check JavaScript/TypeScript files
check_js_ts_files() {
  if [ "$CHECK_JS" = true ] || [ "$CHECK_TS" = true ]; then
    log_message "INFO" "Checking JavaScript/TypeScript files"

    cd "$PROJECT_DIR"

    echo "" >> "$REPORT_FILE"
    echo "## JavaScript/TypeScript" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # ESLint check
    log_message "INFO" "Running ESLint"

    ESLINT_CMD="npx eslint"
    if [ "$CHECK_JS" = true ] && [ "$CHECK_TS" = false ]; then
      ESLINT_CMD="$ESLINT_CMD \"**/*.js\""
    elif [ "$CHECK_JS" = false ] && [ "$CHECK_TS" = true ]; then
      ESLINT_CMD="$ESLINT_CMD \"**/*.ts\" \"**/*.tsx\""
    else
      ESLINT_CMD="$ESLINT_CMD \"**/*.js\" \"**/*.ts\" \"**/*.tsx\""
    fi

    if [ "$FIX_ISSUES" = true ]; then
      ESLINT_CMD="$ESLINT_CMD --fix"
    fi

    echo "### ESLint" >> "$REPORT_FILE"
    echo "```" >> "$REPORT_FILE"

    ESLINT_OUTPUT=$(eval $ESLINT_CMD 2>&1 || true)
    echo "$ESLINT_OUTPUT" >> "$REPORT_FILE"

    echo "```" >> "$REPORT_FILE"

    if [[ "$ESLINT_OUTPUT" == *"error"* ]]; then
      log_message "ERROR" "ESLint found errors"
    elif [[ "$ESLINT_OUTPUT" == *"warning"* ]]; then
      log_message "WARNING" "ESLint found warnings"
    else
      log_message "SUCCESS" "ESLint check passed"
    fi

    # Prettier check
    log_message "INFO" "Running Prettier"

    PRETTIER_CMD="npx prettier --check"
    if [ "$CHECK_JS" = true ] && [ "$CHECK_TS" = false ]; then
      PRETTIER_CMD="$PRETTIER_CMD \"**/*.js\""
    elif [ "$CHECK_JS" = false ] && [ "$CHECK_TS" = true ]; then
      PRETTIER_CMD="$PRETTIER_CMD \"**/*.ts\" \"**/*.tsx\""
    else
      PRETTIER_CMD="$PRETTIER_CMD \"**/*.js\" \"**/*.ts\" \"**/*.tsx\""
    fi

    if [ "$FIX_ISSUES" = true ]; then
      PRETTIER_CMD="npx prettier --write"
      if [ "$CHECK_JS" = true ] && [ "$CHECK_TS" = false ]; then
        PRETTIER_CMD="$PRETTIER_CMD \"**/*.js\""
      elif [ "$CHECK_JS" = false ] && [ "$CHECK_TS" = true ]; then
        PRETTIER_CMD="$PRETTIER_CMD \"**/*.ts\" \"**/*.tsx\""
      else
        PRETTIER_CMD="$PRETTIER_CMD \"**/*.js\" \"**/*.ts\" \"**/*.tsx\""
      fi
    fi

    echo "### Prettier" >> "$REPORT_FILE"
    echo "```" >> "$REPORT_FILE"

    PRETTIER_OUTPUT=$(eval $PRETTIER_CMD 2>&1 || true)
    echo "$PRETTIER_OUTPUT" >> "$REPORT_FILE"

    echo "```" >> "$REPORT_FILE"

    if [[ "$PRETTIER_OUTPUT" == *"Code style issues found"* ]]; then
      if [ "$FIX_ISSUES" = true ]; then
        log_message "WARNING" "Prettier found and fixed formatting issues"
      else
        log_message "WARNING" "Prettier found formatting issues"
      fi
    else
      log_message "SUCCESS" "Prettier check passed"
    fi
  fi
}

# Function to check Python files
check_python_files() {
  if [ "$CHECK_PY" = true ]; then
    log_message "INFO" "Checking Python files"

    cd "$PROJECT_DIR"

    echo "" >> "$REPORT_FILE"
    echo "## Python" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # flake8 check
    log_message "INFO" "Running flake8"

    echo "### flake8" >> "$REPORT_FILE"
    echo "```" >> "$REPORT_FILE"

    FLAKE8_OUTPUT=$(flake8 . 2>&1 || true)
    echo "$FLAKE8_OUTPUT" >> "$REPORT_FILE"

    echo "```" >> "$REPORT_FILE"

    if [ -n "$FLAKE8_OUTPUT" ]; then
      log_message "WARNING" "flake8 found issues"
    else
      log_message "SUCCESS" "flake8 check passed"
    fi

    # black check
    log_message "INFO" "Running black"

    BLACK_CMD="black --check ."
    if [ "$FIX_ISSUES" = true ]; then
      BLACK_CMD="black ."
    fi

    echo "### black" >> "$REPORT_FILE"
    echo "```" >> "$REPORT_FILE"

    BLACK_OUTPUT=$(eval $BLACK_CMD 2>&1 || true)
    echo "$BLACK_OUTPUT" >> "$REPORT_FILE"

    echo "```" >> "$REPORT_FILE"

    if [[ "$BLACK_OUTPUT" == *"would reformat"* ]]; then
      if [ "$FIX_ISSUES" = true ]; then
        log_message "WARNING" "black found and fixed formatting issues"
      else
        log_message "WARNING" "black found formatting issues"
      fi
    elif [[ "$BLACK_OUTPUT" == *"reformatted"* ]]; then
      log_message "WARNING" "black fixed formatting issues"
    else
      log_message "SUCCESS" "black check passed"
    fi

    # isort check
    log_message "INFO" "Running isort"

    ISORT_CMD="isort --check-only --profile black ."
    if [ "$FIX_ISSUES" = true ]; then
      ISORT_CMD="isort --profile black ."
    fi

    echo "### isort" >> "$REPORT_FILE"
    echo "```" >> "$REPORT_FILE"

    ISORT_OUTPUT=$(eval $ISORT_CMD 2>&1 || true)
    echo "$ISORT_OUTPUT" >> "$REPORT_FILE"

    echo "```" >> "$REPORT_FILE"

    if [[ "$ISORT_OUTPUT" == *"ERROR"* || "$ISORT_OUTPUT" == *"would be"* ]]; then
      if [ "$FIX_ISSUES" = true ]; then
        log_message "WARNING" "isort found and fixed import order issues"
      else
        log_message "WARNING" "isort found import order issues"
      fi
    elif [[ "$ISORT_OUTPUT" == *"Fixing"* ]]; then
      log_message "WARNING" "isort fixed import order issues"
    else
      log_message "SUCCESS" "isort check passed"
    fi

    # bandit check
    log_message "INFO" "Running bandit"

    echo "### bandit" >> "$REPORT_FILE"
    echo "```" >> "$REPORT_FILE"

    BANDIT_OUTPUT=$(bandit -r . 2>&1 || true)
    echo "$BANDIT_OUTPUT" >> "$REPORT_FILE"

    echo "```" >> "$REPORT_FILE"

    if [[ "$BANDIT_OUTPUT" == *"Issue:"* ]]; then
      log_message "ERROR" "bandit found security issues"
    else
      log_message "SUCCESS" "bandit check passed"
    fi
  fi
}

# Function to check Solidity files
check_solidity_files() {
  if [ "$CHECK_SOL" = true ]; then
    log_message "INFO" "Checking Solidity files"

    cd "$PROJECT_DIR"

    echo "" >> "$REPORT_FILE"
    echo "## Solidity" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # solhint check
    log_message "INFO" "Running solhint"

    SOLHINT_CMD="npx solhint \"**/*.sol\""
    if [ "$FIX_ISSUES" = true ]; then
      SOLHINT_CMD="$SOLHINT_CMD --fix"
    fi

    echo "### solhint" >> "$REPORT_FILE"
    echo "```" >> "$REPORT_FILE"

    SOLHINT_OUTPUT=$(eval $SOLHINT_CMD 2>&1 || true)
    echo "$SOLHINT_OUTPUT" >> "$REPORT_FILE"

    echo "```" >> "$REPORT_FILE"

    if [[ "$SOLHINT_OUTPUT" == *"Error"* ]]; then
      log_message "ERROR" "solhint found errors"
    elif [[ "$SOLHINT_OUTPUT" == *"Warning"* ]]; then
      log_message "WARNING" "solhint found warnings"
    else
      log_message "SUCCESS" "solhint check passed"
    fi

    # Check if slither is installed (if Python is available)
    if command_exists slither; then
      log_message "INFO" "Running slither"

      echo "### slither" >> "$REPORT_FILE"
      echo "```" >> "$REPORT_FILE"

      # Find directories containing Solidity files
      SOL_DIRS=$(find . -name "*.sol" -exec dirname {} \; | sort -u)

      for dir in $SOL_DIRS; do
        if [ -f "$dir/hardhat.config.js" ] || [ -f "$dir/hardhat.config.ts" ] || [ -f "$dir/truffle-config.js" ]; then
          echo "Analyzing $dir" >> "$REPORT_FILE"
          SLITHER_OUTPUT=$(cd "$dir" && slither . 2>&1 || true)
          echo "$SLITHER_OUTPUT" >> "$REPORT_FILE"

          if [[ "$SLITHER_OUTPUT" == *"Error"* || "$SLITHER_OUTPUT" == *"Warning"* ]]; then
            log_message "WARNING" "slither found issues in $dir"
          fi
        fi
      done

      echo "```" >> "$REPORT_FILE"
    else
      log_message "WARNING" "slither not available, skipping advanced Solidity analysis"
    fi
  fi
}

# Function to create pre-commit hook
create_pre_commit_hook() {
  log_message "INFO" "Creating pre-commit hook"

  cd "$PROJECT_DIR"

  # Create .git/hooks directory if it doesn't exist
  mkdir -p ".git/hooks"

  # Create pre-commit hook
  PRE_COMMIT_HOOK=".git/hooks/pre-commit"

  echo '#!/bin/bash
# BlockScore pre-commit hook

# Run code quality check script
./scripts/code_quality_check.sh --fix

# Check exit status
if [ $? -ne 0 ]; then
  echo "Code quality check failed. Please fix the issues before committing."
  exit 1
fi

exit 0' > "$PRE_COMMIT_HOOK"

  # Make pre-commit hook executable
  chmod +x "$PRE_COMMIT_HOOK"

  log_message "SUCCESS" "Pre-commit hook created"
}

# Function to generate summary
generate_summary() {
  log_message "INFO" "Generating summary"

  # Count issues
  ERROR_COUNT=$(grep -c "ERROR" "$REPORT_FILE" || true)
  WARNING_COUNT=$(grep -c "WARNING" "$REPORT_FILE" || true)
  SUCCESS_COUNT=$(grep -c "SUCCESS" "$REPORT_FILE" || true)

  # Update summary in report
  sed -i "s/## Summary/## Summary\n\n- Errors: $ERROR_COUNT\n- Warnings: $WARNING_COUNT\n- Successes: $SUCCESS_COUNT/" "$REPORT_FILE"

  # Print summary
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${BLUE}                      Summary                                  ${NC}"
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${RED}Errors: $ERROR_COUNT${NC}"
  echo -e "${YELLOW}Warnings: $WARNING_COUNT${NC}"
  echo -e "${GREEN}Successes: $SUCCESS_COUNT${NC}"
  echo -e "${BLUE}================================================================${NC}"
  echo -e "${BLUE}Report: $REPORT_FILE${NC}"
  echo -e "${BLUE}================================================================${NC}"

  # Return error if there are errors
  if [ "$ERROR_COUNT" -gt 0 ]; then
    return 1
  fi

  return 0
}

# Main execution
main() {
  log_message "INFO" "Starting code quality check"

  # Install dependencies
  install_node_dependencies
  install_python_dependencies

  # Create configuration files
  create_config_files

  # Check files
  check_js_ts_files
  check_python_files
  check_solidity_files

  # Create pre-commit hook
  create_pre_commit_hook

  # Generate summary
  generate_summary

  local status=$?

  if [ $status -eq 0 ]; then
    log_message "SUCCESS" "Code quality check completed successfully"
  else
    log_message "ERROR" "Code quality check completed with errors"
  fi

  return $status
}

# Execute main function
main
