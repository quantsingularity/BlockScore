#!/bin/bash
# BlockScore Backend Startup Script

set -e  # Exit on error

echo "================================"
echo "BlockScore Backend Startup"
echo "================================"

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "Installing dependencies..."
pip install --quiet --no-input -r requirements.txt

# Check if .env exists, if not copy from .env.example
if [ ! -f ".env" ]; then
    echo "Creating .env file from .env.example..."
    cp .env.example .env
    echo "⚠️  Please edit .env file with your actual configuration values"
fi

# Initialize database
echo "Initializing database..."
python3 << 'ENDPYTHON'
from app import create_app
from models import db

app = create_app()
with app.app_context():
    db.create_all()
    print("✓ Database tables created successfully")
ENDPYTHON

# Start the application
echo ""
echo "================================"
echo "Starting BlockScore Backend..."
echo "================================"
echo ""
echo "Server will be available at: http://0.0.0.0:5000"
echo "Health check endpoint: http://0.0.0.0:5000/api/health"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

python3 app.py
