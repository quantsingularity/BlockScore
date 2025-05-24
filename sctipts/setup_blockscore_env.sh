#!/bin/bash

# BlockScore Project Setup Script

# Exit immediately if a command exits with a non-zero status.
set -e

# Prerequisites (ensure these are installed and configured):
# - Python 3.x (the script will use python3.11 available in the environment)
# - pip (Python package installer)
# - Node.js (for backend and frontend)
# - npm (Node package manager)
# - MongoDB (for off-chain data storage, ensure it's running and accessible)
# - Access to an Ethereum or Polygon compatible blockchain node (for smart contract interaction)

echo "Starting BlockScore project setup..."

PROJECT_DIR="/home/ubuntu/projects_extracted/BlockScore"

if [ ! -d "${PROJECT_DIR}" ]; then
  echo "Error: Project directory ${PROJECT_DIR} not found."
  echo "Please ensure the project is extracted correctly."
  exit 1
fi

cd "${PROJECT_DIR}"
echo "Changed directory to $(pwd)"

# --- AI Models Setup (Python) ---
echo ""
echo "Setting up BlockScore AI Models environment..."
AI_MODELS_DIR="${PROJECT_DIR}/code/ai_models/training_scripts"

if [ ! -d "${AI_MODELS_DIR}" ]; then
    echo "Error: AI Models directory ${AI_MODELS_DIR} not found."
else
    cd "${AI_MODELS_DIR}"
    echo "Changed directory to $(pwd) for AI Models setup."

    if [ ! -f "requirements.txt" ]; then
        echo "Warning: requirements.txt not found in ${AI_MODELS_DIR}. Skipping Python dependency installation for AI Models."
    else
        echo "Creating Python virtual environment for AI Models (venv_blockscore_ai)..."
        if ! python3.11 -m venv venv_blockscore_ai; then
            echo "Failed to create AI Models virtual environment. Please check your Python installation."
        else
            source venv_blockscore_ai/bin/activate
            echo "AI Models Python virtual environment created and activated."
            echo "Installing AI Models Python dependencies from requirements.txt..."
            pip3 install -r requirements.txt
            echo "AI Models dependencies installed."
            echo "To activate the AI Models virtual environment later, run: source ${AI_MODELS_DIR}/venv_blockscore_ai/bin/activate"
            deactivate
            echo "AI Models virtual environment deactivated."
        fi
    fi
    cd "${PROJECT_DIR}" # Return to the main project directory
fi

# --- Backend Setup (Node.js and Python) ---
echo ""
echo "Setting up BlockScore Backend environment..."
BACKEND_DIR="${PROJECT_DIR}/code/backend"

if [ ! -d "${BACKEND_DIR}" ]; then
    echo "Error: Backend directory ${BACKEND_DIR} not found."
else
    cd "${BACKEND_DIR}"
    echo "Changed directory to $(pwd) for Backend setup."

    # Backend Node.js dependencies
    if [ ! -f "package.json" ]; then
        echo "Warning: package.json not found in ${BACKEND_DIR}. Skipping Node.js dependency installation for Backend."
    else
        echo "Installing Backend Node.js dependencies using npm..."
        if ! command -v npm &> /dev/null; then
            echo "npm command could not be found. Please ensure Node.js and npm are installed and in your PATH."
        else
            npm install
            echo "Backend Node.js dependencies installed."
        fi
    fi

    # Backend Python dependencies
    if [ ! -f "requirements.txt" ]; then
        echo "Warning: requirements.txt not found in ${BACKEND_DIR}. Skipping Python dependency installation for Backend."
    else
        echo "Creating Python virtual environment for Backend (venv_blockscore_backend_py)..."
        if ! python3.11 -m venv venv_blockscore_backend_py; then
            echo "Failed to create Backend Python virtual environment. Please check your Python installation."
        else
            source venv_blockscore_backend_py/bin/activate
            echo "Backend Python virtual environment created and activated."
            echo "Installing Backend Python dependencies from requirements.txt..."
            pip3 install -r requirements.txt
            echo "Backend Python dependencies installed."
            echo "To activate the Backend Python virtual environment later, run: source ${BACKEND_DIR}/venv_blockscore_backend_py/bin/activate"
            deactivate
            echo "Backend Python virtual environment deactivated."
        fi
    fi
    cd "${PROJECT_DIR}" # Return to the main project directory
fi

# --- Frontend Setup (React - Node.js) ---
echo ""
echo "Setting up BlockScore Frontend environment..."
FRONTEND_DIR="${PROJECT_DIR}/code/web-frontend"

if [ ! -d "${FRONTEND_DIR}" ]; then
    echo "Error: Frontend directory ${FRONTEND_DIR} not found."
else
    cd "${FRONTEND_DIR}"
    echo "Changed directory to $(pwd) for Frontend setup."

    if [ ! -f "package.json" ]; then
        echo "Error: package.json not found in ${FRONTEND_DIR}. Cannot install frontend dependencies."
    else
        echo "Installing Frontend Node.js dependencies using npm..."
        if ! command -v npm &> /dev/null; then
            echo "npm command could not be found. Please ensure Node.js and npm are installed and in your PATH."
        else
            npm install
            echo "Frontend dependencies installed."
        fi
    fi
    echo "To start the frontend development server (from ${FRONTEND_DIR}): npm start"
    echo "To build the frontend for production (from ${FRONTEND_DIR}): npm run build"
    cd "${PROJECT_DIR}" # Return to the main project directory
fi

# --- General Instructions & Reminders ---
echo ""
echo "BlockScore project setup script finished."
echo "Please ensure all prerequisites are met:"
echo "  - Python 3.x, pip"
echo "  - Node.js, npm"
echo "  - MongoDB (running and accessible)"
echo "  - Ethereum/Polygon node access for smart contract interactions."
echo "Review the project's README.md for further instructions on smart contract deployment, running services, and potential .env configurations."
echo "You may need to create .env files in backend or other relevant directories based on project needs (e.g., for API keys, database URIs, private keys)."
