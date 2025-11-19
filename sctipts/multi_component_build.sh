#!/bin/bash
# ========================================================================
# BlockScore Multi-Component Build Orchestration Script
#
# This script automates the build process for all BlockScore components
# in the correct order with proper dependency management.
#
# Features:
# - Parallel or sequential build options
# - Selective component building
# - Dependency tracking between components
# - Build status reporting
# - Error handling and recovery
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
CONFIG_DIR="${PROJECT_DIR}/.blockscore_config"
BUILD_LOG="${PROJECT_DIR}/build.log"

# Print banner
echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}          BlockScore Multi-Component Build System               ${NC}"
echo -e "${BLUE}================================================================${NC}"

# Initialize log file
echo "BlockScore Build Log - $(date)" > "$BUILD_LOG"

# Parse command line arguments
PARALLEL_BUILD=false
COMPONENTS=()
CLEAN_BUILD=false

print_usage() {
  echo "Usage: $0 [options] [components]"
  echo ""
  echo "Options:"
  echo "  -h, --help                 Show this help message"
  echo "  -p, --parallel             Build components in parallel (default: sequential)"
  echo "  -c, --clean                Perform clean build (remove node_modules, etc.)"
  echo ""
  echo "Components:"
  echo "  all                        Build all components (default)"
  echo "  shared                     Build shared libraries"
  echo "  blockchain                 Build blockchain contracts"
  echo "  backend                    Build backend services"
  echo "  frontend                   Build frontend application"
  echo "  mobile                     Build mobile application"
  echo "  ai                         Build AI models"
  echo ""
  echo "Examples:"
  echo "  $0                         Build all components sequentially"
  echo "  $0 -p frontend backend     Build frontend and backend in parallel"
  echo "  $0 -c blockchain           Clean and build blockchain contracts"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      print_usage
      exit 0
      ;;
    -p|--parallel)
      PARALLEL_BUILD=true
      shift
      ;;
    -c|--clean)
      CLEAN_BUILD=true
      shift
      ;;
    all|shared|blockchain|backend|frontend|mobile|ai)
      COMPONENTS+=("$1")
      shift
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      print_usage
      exit 1
      ;;
  esac
done

# If no components specified, build all
if [ ${#COMPONENTS[@]} -eq 0 ]; then
  COMPONENTS=("shared" "blockchain" "backend" "frontend" "mobile" "ai")
fi

# Function to log messages
log_message() {
  local level=$1
  local message=$2
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")

  echo "[$timestamp] [$level] $message" >> "$BUILD_LOG"

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

# Function to check if a component exists
component_exists() {
  local component=$1

  case $component in
    shared)
      [ -d "${PROJECT_DIR}/code/shared" ]
      ;;
    blockchain)
      [ -d "${PROJECT_DIR}/code/blockchain" ]
      ;;
    backend)
      [ -d "${PROJECT_DIR}/code/backend" ]
      ;;
    frontend)
      [ -d "${PROJECT_DIR}/code/frontend" ]
      ;;
    mobile)
      [ -d "${PROJECT_DIR}/mobile-frontend" ]
      ;;
    ai)
      [ -d "${PROJECT_DIR}/code/ai_models" ]
      ;;
    *)
      return 1
      ;;
  esac

  return $?
}

# Function to clean a component
clean_component() {
  local component=$1

  log_message "INFO" "Cleaning component: $component"

  case $component in
    shared)
      if [ -d "${PROJECT_DIR}/code/shared" ]; then
        cd "${PROJECT_DIR}/code/shared"
        rm -rf node_modules dist
        rm -f package-lock.json yarn.lock
      fi
      ;;
    blockchain)
      if [ -d "${PROJECT_DIR}/code/blockchain" ]; then
        cd "${PROJECT_DIR}/code/blockchain"
        rm -rf node_modules artifacts cache
        rm -f package-lock.json yarn.lock
      fi
      ;;
    backend)
      if [ -d "${PROJECT_DIR}/code/backend" ]; then
        cd "${PROJECT_DIR}/code/backend"
        rm -rf node_modules dist
        rm -f package-lock.json yarn.lock
      fi
      ;;
    frontend)
      if [ -d "${PROJECT_DIR}/code/frontend" ]; then
        cd "${PROJECT_DIR}/code/frontend"
        rm -rf node_modules build
        rm -f package-lock.json yarn.lock
      fi
      ;;
    mobile)
      if [ -d "${PROJECT_DIR}/mobile-frontend" ]; then
        cd "${PROJECT_DIR}/mobile-frontend"
        rm -rf node_modules
        rm -f package-lock.json yarn.lock
      fi
      ;;
    ai)
      if [ -d "${PROJECT_DIR}/code/ai_models" ]; then
        cd "${PROJECT_DIR}/code/ai_models"
        rm -rf __pycache__ .pytest_cache
        find . -name "*.pyc" -delete
      fi
      ;;
  esac

  cd "${PROJECT_DIR}"
  log_message "SUCCESS" "Component cleaned: $component"
}

# Function to build a component
build_component() {
  local component=$1
  local build_status=0

  log_message "INFO" "Building component: $component"

  # Clean component if requested
  if [ "$CLEAN_BUILD" = true ]; then
    clean_component "$component"
  fi

  case $component in
    shared)
      if [ -d "${PROJECT_DIR}/code/shared" ]; then
        cd "${PROJECT_DIR}/code/shared"
        npm install || build_status=$?
        npm run build || build_status=$?
      else
        log_message "WARNING" "Shared component directory not found, skipping"
      fi
      ;;
    blockchain)
      if [ -d "${PROJECT_DIR}/code/blockchain" ]; then
        cd "${PROJECT_DIR}/code/blockchain"
        npm install || build_status=$?
        npx hardhat compile || build_status=$?
      else
        log_message "WARNING" "Blockchain component directory not found, skipping"
      fi
      ;;
    backend)
      if [ -d "${PROJECT_DIR}/code/backend" ]; then
        cd "${PROJECT_DIR}/code/backend"
        npm install || build_status=$?
        npm run build || build_status=$?
      else
        log_message "WARNING" "Backend component directory not found, skipping"
      fi
      ;;
    frontend)
      if [ -d "${PROJECT_DIR}/code/frontend" ]; then
        cd "${PROJECT_DIR}/code/frontend"
        npm install || build_status=$?
        npm run build || build_status=$?
      else
        log_message "WARNING" "Frontend component directory not found, skipping"
      fi
      ;;
    mobile)
      if [ -d "${PROJECT_DIR}/mobile-frontend" ]; then
        cd "${PROJECT_DIR}/mobile-frontend"
        npm install || build_status=$?
        npm run build || build_status=$?
      else
        log_message "WARNING" "Mobile component directory not found, skipping"
      fi
      ;;
    ai)
      if [ -d "${PROJECT_DIR}/code/ai_models" ]; then
        cd "${PROJECT_DIR}/code/ai_models"
        # Activate virtual environment if it exists
        if [ -d "${PROJECT_DIR}/venv" ]; then
          source "${PROJECT_DIR}/venv/bin/activate"
        fi
        # Install requirements if requirements.txt exists
        if [ -f "requirements.txt" ]; then
          pip install -r requirements.txt || build_status=$?
        fi
        # Run build script if it exists
        if [ -f "build.py" ]; then
          python build.py || build_status=$?
        fi
      else
        log_message "WARNING" "AI models component directory not found, skipping"
      fi
      ;;
  esac

  cd "${PROJECT_DIR}"

  if [ $build_status -eq 0 ]; then
    log_message "SUCCESS" "Component built successfully: $component"
  else
    log_message "ERROR" "Failed to build component: $component"
  fi

  return $build_status
}

# Function to build components in parallel
build_parallel() {
  log_message "INFO" "Building components in parallel: ${COMPONENTS[*]}"

  local pids=()
  local results=()

  for component in "${COMPONENTS[@]}"; do
    if component_exists "$component"; then
      # Start build in background
      build_component "$component" > "${PROJECT_DIR}/.build_${component}.log" 2>&1 &
      pids+=($!)
      results+=("$component:$!")
    else
      log_message "WARNING" "Component does not exist: $component"
    fi
  done

  # Wait for all builds to complete
  local failed_components=()

  for result in "${results[@]}"; do
    local component=${result%%:*}
    local pid=${result#*:}

    wait $pid
    local status=$?

    if [ $status -ne 0 ]; then
      failed_components+=("$component")
    fi

    # Append component build log to main log
    if [ -f "${PROJECT_DIR}/.build_${component}.log" ]; then
      cat "${PROJECT_DIR}/.build_${component}.log" >> "$BUILD_LOG"
      rm "${PROJECT_DIR}/.build_${component}.log"
    fi
  done

  if [ ${#failed_components[@]} -eq 0 ]; then
    log_message "SUCCESS" "All components built successfully"
    return 0
  else
    log_message "ERROR" "Failed to build components: ${failed_components[*]}"
    return 1
  fi
}

# Function to build components sequentially
build_sequential() {
  log_message "INFO" "Building components sequentially: ${COMPONENTS[*]}"

  local failed_components=()

  for component in "${COMPONENTS[@]}"; do
    if component_exists "$component"; then
      build_component "$component"
      local status=$?

      if [ $status -ne 0 ]; then
        failed_components+=("$component")
      fi
    else
      log_message "WARNING" "Component does not exist: $component"
    fi
  done

  if [ ${#failed_components[@]} -eq 0 ]; then
    log_message "SUCCESS" "All components built successfully"
    return 0
  else
    log_message "ERROR" "Failed to build components: ${failed_components[*]}"
    return 1
  fi
}

# Function to create build completion marker
create_build_marker() {
  local status=$1
  local build_date=$(date "+%Y-%m-%d %H:%M:%S")

  mkdir -p "${CONFIG_DIR}"

  echo "{
  \"build_completed\": true,
  \"build_status\": \"$status\",
  \"build_date\": \"$build_date\",
  \"components\": [$(printf "\"%s\"," "${COMPONENTS[@]}" | sed 's/,$//')]
}" > "${CONFIG_DIR}/build_complete.json"

  log_message "INFO" "Build completion marker created"
}

# Main execution
main() {
  log_message "INFO" "Starting build process"

  # Create build directory if it doesn't exist
  mkdir -p "${CONFIG_DIR}"

  # Build components
  if [ "$PARALLEL_BUILD" = true ]; then
    build_parallel
  else
    build_sequential
  fi

  local build_status=$?

  if [ $build_status -eq 0 ]; then
    create_build_marker "success"
    log_message "SUCCESS" "Build completed successfully"
    echo -e "${GREEN}Build completed successfully!${NC}"
  else
    create_build_marker "failed"
    log_message "ERROR" "Build failed"
    echo -e "${RED}Build failed. See $BUILD_LOG for details.${NC}"
  fi

  echo -e "${BLUE}================================================================${NC}"
  echo -e "${BLUE}Build Log: $BUILD_LOG${NC}"
  echo -e "${BLUE}================================================================${NC}"

  return $build_status
}

# Execute main function
main
