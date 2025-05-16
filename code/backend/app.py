from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import os
import json
from web3 import Web3
import pandas as pd
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Connect to Ethereum (will be updated with actual provider)
BLOCKCHAIN_PROVIDER = os.getenv('BLOCKCHAIN_PROVIDER', 'http://localhost:8545')
try:
    web3 = Web3(Web3.HTTPProvider(BLOCKCHAIN_PROVIDER))
    print(f"Connected to Ethereum: {web3.is_connected()}")
except Exception as e:
    print(f"Error connecting to blockchain: {e}")
    web3 = None

# Load AI model (will be created if not exists)
MODEL_PATH = '../ai_models/credit_scoring_model.pkl'
try:
    model = joblib.load(MODEL_PATH)
    print("Model loaded successfully")
except:
    print("Model not found, will be created during first request")
    model = None

# Load contract ABI
try:
    with open('../blockchain/build/contracts/CreditScore.json', 'r') as f:
        contract_json = json.load(f)
        contract_abi = contract_json['abi']
    print("Contract ABI loaded successfully")
except Exception as e:
    print(f"Error loading contract ABI: {e}")
    contract_abi = None

# Contract address (will be updated after deployment)
CONTRACT_ADDRESS = os.getenv('CONTRACT_ADDRESS', '0x0000000000000000000000000000000000000000')

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'ok',
        'blockchain_connected': web3.is_connected() if web3 else False,
        'model_loaded': model is not None,
        'contract_abi_loaded': contract_abi is not None
    })

@app.route('/api/calculate-score', methods=['POST'])
def calculate_score():
    """Calculate credit score based on blockchain data and AI model"""
    data = request.json
    wallet_address = data.get('walletAddress')

    if not wallet_address:
        return jsonify({'error': 'Wallet address is required'}), 400

    # For demo purposes, if no blockchain connection, use mock data
    if not web3 or not contract_abi:
        # Special case for the no-history wallet address
        if wallet_address == '0x0000000000000000000000000000000000000000':
            tx_history = []  # Empty history for the zero address
        else:
            # Mock blockchain data for demonstration
            tx_history = [
                {'timestamp': 1617235200, 'amount': 1000, 'repaid': True},
                {'timestamp': 1619827200, 'amount': 2000, 'repaid': True},
                {'timestamp': 1622505600, 'amount': 1500, 'repaid': False}
            ]
    else:
        try:
            # Get contract instance
            contract = web3.eth.contract(address=CONTRACT_ADDRESS, abi=contract_abi)

            # Get credit history from blockchain
            tx_history = contract.functions.getCreditHistory(wallet_address).call()
        except Exception as e:
            return jsonify({'error': f'Blockchain error: {str(e)}'}), 500

    # Process blockchain data for model input
    try:
        # Extract features from transaction history
        if tx_history:
            # Calculate features from transaction history
            total_loans = len(tx_history)
            total_amount = sum(tx['amount'] for tx in tx_history)
            repaid_ratio = sum(1 for tx in tx_history if tx['repaid']) / total_loans if total_loans > 0 else 0
            avg_loan_amount = total_amount / total_loans if total_loans > 0 else 0

            features = {
                'total_loans': total_loans,
                'total_amount': total_amount,
                'repaid_ratio': repaid_ratio,
                'avg_loan_amount': avg_loan_amount
            }

            # If model doesn't exist or there's a feature mismatch, use a simple scoring function
            try:
                if model is None:
                    # Simple scoring algorithm: 300 + (repaid_ratio * 550)
                    # This gives a score between 300-850 (standard credit score range)
                    score = int(300 + (repaid_ratio * 550))
                else:
                    # Convert features to match the model's expected format
                    model_features = {
                        'income': 50000,  # Default value
                        'debt_ratio': 0.3,  # Default value
                        'payment_history': repaid_ratio,
                        'loan_count': total_loans,
                        'loan_amount': avg_loan_amount,
                        'age': 35,  # Default value
                        'credit_utilization': 0.4  # Default value
                    }
                    # Use the trained model
                    features_df = pd.DataFrame([model_features])
                    score = int(model.predict(features_df)[0])
            except Exception as e:
                print(f"Model prediction error: {e}")
                # Fallback to simple scoring
                score = int(300 + (repaid_ratio * 550))

            # Ensure score is within reasonable bounds
            score = max(300, min(score, 850))

            return jsonify({
                'address': wallet_address,
                'score': score,
                'features': features,
                'history': tx_history
            })
        else:
            return jsonify({
                'address': wallet_address,
                'score': 300,  # Base score for no history
                'features': {
                    'total_loans': 0,
                    'total_amount': 0,
                    'repaid_ratio': 0,
                    'avg_loan_amount': 0
                },
                'history': []
            })
    except Exception as e:
        return jsonify({'error': f'Processing error: {str(e)}'}), 500

@app.route('/api/calculate-loan', methods=['POST'])
def calculate_loan():
    """Calculate loan eligibility based on amount, rate and credit score"""
    try:
        data = request.json
        amount = float(data.get('amount', 1000))
        rate = float(data.get('rate', 5))
        wallet_address = data.get('walletAddress')

        if not wallet_address:
            return jsonify({'error': 'Wallet address is required'}), 400

        # Instead of calling calculate_score directly, make a new calculation
        # Get mock credit score for demo purposes
        if not web3 or not contract_abi:
            # Special case for the no-history wallet address
            if wallet_address == '0x0000000000000000000000000000000000000000':
                score = 300  # Base score for no history
            else:
                # Mock data for demonstration
                score = 720  # Good credit score

                # For demo purposes, adjust score based on wallet address
                # This allows testing different scenarios
                if wallet_address.endswith('e'):  # Good credit
                    score = 720
                elif wallet_address.endswith('a'):  # Poor credit
                    score = 580
                elif wallet_address.endswith('b'):  # Excellent credit
                    score = 800
                else:
                    score = 650  # Fair credit
        else:
            try:
                # In a real implementation, we would get this from the blockchain
                # For now, use a mock score
                score = 720
            except Exception as e:
                return jsonify({'error': f'Blockchain error: {str(e)}'}), 500

        # Calculate approval probability based on score and loan parameters
        # Higher score, lower amount, and lower rate increase approval chances
        base_probability = (score - 300) / 550  # 0 to 1 based on score
        amount_factor = max(0, 1 - (amount / 10000))  # Lower for higher amounts
        rate_factor = min(1, rate / 15)  # Higher for higher rates (up to 15%)

        approval_probability = (base_probability * 0.6) + (amount_factor * 0.2) + (rate_factor * 0.2)
        approval_probability = max(0, min(approval_probability, 1)) * 100  # Convert to percentage

        monthly_payment = (amount * (rate/100/12) * ((1 + (rate/100/12)) ** 36)) / (((1 + (rate/100/12)) ** 36) - 1)

        return jsonify({
            'approval_probability': round(approval_probability, 2),
            'monthly_payment': round(monthly_payment, 2),
            'credit_score': score,
            'loan_term': 36,  # 3 years
            'total_payment': round(monthly_payment * 36, 2)
        })
    except Exception as e:
        return jsonify({'error': f'Calculation error: {str(e)}'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
