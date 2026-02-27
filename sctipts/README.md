# BlockScore Automation Scripts

This directory contains automation scripts for the BlockScore project. These scripts are designed to streamline development workflows, improve consistency, and reduce manual effort.

## Scripts Overview

1. **unified_env_setup.sh** - Comprehensive environment setup script
2. **multi_component_build.sh** - Build orchestration for all components
3. **smart_contract_deploy.sh** - Smart contract deployment automation
4. **code_quality_check.sh** - Code quality and linting automation
5. **component_restart.sh** - Selective component restart automation

## Installation

1. Clone the BlockScore repository
2. Copy these scripts to the root directory of your BlockScore project
3. Make the scripts executable:
   ```bash
   chmod +x scripts/*.sh
   ```

## Usage Instructions

### Unified Environment Setup

This script automates the complete setup of the BlockScore development environment.

```bash
./scripts/unified_env_setup.sh
```

Features:

- Automatic OS detection and package installation
- Python, Node.js, and MongoDB setup
- Blockchain development environment configuration
- Environment variable management
- Project structure validation

### Multi-Component Build

This script orchestrates the build process for all BlockScore components.

```bash
./scripts/multi_component_build.sh [options] [components]
```

Options:

- `-h, --help`: Show help message
- `-p, --parallel`: Build components in parallel
- `-c, --clean`: Perform clean build

Components:

- `all`: Build all components (default)
- `shared`, `blockchain`, `backend`, `frontend`, `mobile`, `ai`: Build specific components

Examples:

```bash
./scripts/multi_component_build.sh                         # Build all components sequentially
./scripts/multi_component_build.sh -p frontend backend     # Build frontend and backend in parallel
./scripts/multi_component_build.sh -c blockchain           # Clean and build blockchain contracts
```

### Smart Contract Deployment

This script automates the deployment of smart contracts to different blockchain networks.

```bash
./scripts/smart_contract_deploy.sh [options]
```

Options:

- `-h, --help`: Show help message
- `-n, --network <network>`: Specify network (development, test, mainnet)
- `-v, --verify`: Verify contracts on block explorer
- `--no-gas-optimization`: Disable gas optimization
- `--no-security-check`: Disable security checks

Examples:

```bash
./scripts/smart_contract_deploy.sh                         # Deploy to development network
./scripts/smart_contract_deploy.sh -n test -v              # Deploy to test network and verify contracts
./scripts/smart_contract_deploy.sh -n mainnet -v           # Deploy to mainnet and verify contracts
```

### Code Quality Check

This script performs comprehensive code quality checks across all components.

```bash
./scripts/code_quality_check.sh [options]
```

Options:

- `-h, --help`: Show help message
- `-f, --fix`: Automatically fix issues when possible
- `-v, --verbose`: Show detailed output
- `--js`, `--ts`, `--py`, `--sol`: Check specific file types

Examples:

```bash
./scripts/code_quality_check.sh                         # Check all file types
./scripts/code_quality_check.sh -f                      # Check all file types and fix issues
./scripts/code_quality_check.sh --js --ts -f            # Check JavaScript and TypeScript files and fix issues
```

### Component Restart

This script automates the process of selectively restarting only the components that have been modified.

```bash
./scripts/component_restart.sh [options] [components]
```

Options:

- `-h, --help`: Show help message
- `-f, --force`: Force restart even if no changes detected
- `-w, --watch`: Watch for changes and restart automatically

Components:

- `all`: Restart all components (default)
- `blockchain`, `backend`, `frontend`, `mobile`, `ai`: Restart specific components

Examples:

```bash
./scripts/component_restart.sh                         # Restart all modified components
./scripts/component_restart.sh -f backend              # Force restart backend services
./scripts/component_restart.sh -w frontend backend     # Watch and restart frontend and backend when changes detected
```

## Integration with Development Workflow

These scripts can be integrated into your development workflow in several ways:

1. **Manual Execution**: Run scripts as needed during development
2. **Git Hooks**: The code quality check script can be used as a pre-commit hook
3. **CI/CD Integration**: Scripts can be incorporated into CI/CD pipelines
4. **IDE Integration**: Configure your IDE to run these scripts for specific tasks

## Customization

All scripts are designed to be modular and customizable. You can modify them to fit your specific project requirements by editing the script files directly.

## Troubleshooting

If you encounter any issues with the scripts:

1. Check the log files in the `.blockscore_config` directory
2. Ensure all dependencies are installed
3. Verify that the project structure matches the expected structure
4. Run scripts with verbose output for more detailed information

## Contributing

Feel free to enhance these scripts by adding new features, fixing bugs, or improving documentation. Submit pull requests to the main BlockScore repository.
