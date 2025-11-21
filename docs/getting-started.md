# Getting Started with BlockScore

## Prerequisites

- Node.js (v16 or higher)
- Python 3.8+
- MongoDB
- Ethereum wallet (MetaMask recommended)
- Git

## Development Environment Setup

### 1. Clone the Repository

```bash
git clone https://github.com/abrar2030/BlockScore
cd BlockScore
```

### 2. Install Dependencies

#### Frontend Dependencies

```bash
cd code/frontend
npm install
```

#### Backend Dependencies

```bash
cd code/backend
npm install
```

#### Python Dependencies

```bash
cd code/ai
pip install -r requirements.txt
```

### 3. Environment Configuration

1. Create `.env` files in both frontend and backend directories using the provided templates
2. Set up your MongoDB connection string
3. Configure your Ethereum network settings

### 4. Running the Development Environment

#### Start the Backend Server

```bash
cd code/backend
npm run dev
```

#### Start the Frontend Application

```bash
cd code/frontend
npm start
```

#### Run AI Model Training (Optional)

```bash
cd code/ai
python train_model.py
```

## Development Workflow

1. Create a new branch for your feature
2. Make your changes
3. Run tests
4. Submit a pull request

## Troubleshooting

See the [troubleshooting guide](./troubleshooting.md) for common issues and solutions.

## Next Steps

- Review the [Architecture Documentation](./architecture.md)
- Check out the [API Documentation](./api-docs.md)
- Learn about [Smart Contract Integration](./smart-contracts.md)
