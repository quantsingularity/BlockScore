# BlockScore Automation Scripts

This package contains automation scripts for the BlockScore project, designed to streamline development workflows, improve consistency, and reduce manual effort.

## Contents

1. **Automation Scripts**
    - `unified_env_setup.sh` - Comprehensive environment setup script
    - `multi_component_build.sh` - Build orchestration for all components
    - `smart_contract_deploy.sh` - Smart contract deployment automation
    - `code_quality_check.sh` - Code quality and linting automation
    - `component_restart.sh` - Selective component restart automation

2. **Documentation**
    - `README.md` - Detailed usage instructions for all scripts
    - `automation_opportunities.md` - Analysis of automation opportunities in BlockScore

## Installation

1. Extract this zip file to the root directory of your BlockScore project
2. Make the scripts executable:
    ```bash
    chmod +x *.sh
    ```
3. Follow the instructions in the README.md file for each script

## Quick Start

After installation, you can:

1. Set up your development environment:

    ```bash
    ./unified_env_setup.sh
    ```

2. Build all components:

    ```bash
    ./multi_component_build.sh
    ```

3. Check code quality:

    ```bash
    ./code_quality_check.sh
    ```

4. Deploy smart contracts:

    ```bash
    ./smart_contract_deploy.sh
    ```

5. Restart components during development:
    ```bash
    ./component_restart.sh -w
    ```

For more detailed instructions, please refer to the README.md file.
