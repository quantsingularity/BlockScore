#!/bin/bash

# BlockScore Backend Startup Script

echo "==================================="
echo "BlockScore Backend Startup"
echo "==================================="

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "Creating .env from template..."
    cp .env.example .env
    echo "⚠️  Please edit .env and set SECRET_KEY and JWT_SECRET_KEY"
    echo "⚠️  Press Enter to continue after editing, or Ctrl+C to exit"
    read
fi

# Install dependencies if needed
echo "Checking dependencies..."
pip install -q --no-input -r requirements.txt 2>&1 | grep -v "Requirement already satisfied" || true

echo ""
echo "==================================="
echo "Starting BlockScore Backend..."
echo "==================================="
echo ""
echo "Server will be available at: http://0.0.0.0:5000"
echo "Health check: http://0.0.0.0:5000/api/health"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start the application
python app.py
