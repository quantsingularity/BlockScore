import os
from datetime import datetime

import joblib
import numpy as np
import pandas as pd
from flask import Flask, jsonify, request

app = Flask(__name__)

# Load the trained model
model_path = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "credit_scoring_model.pkl",
)
model = joblib.load(model_path)


def preprocess_blockchain_data(credit_history):
    """
    Preprocess blockchain credit history data for model input

    Parameters:
    -----------
    credit_history : list
        List of credit record objects from blockchain

    Returns:
    --------
    pandas.DataFrame
        Processed features ready for model input
    """
    if not credit_history:
        return None

    # Extract features from credit history
    datetime.now().timestamp()

    # Initialize feature values
    income_proxy = 0
    debt_ratio = 0
    payment_history = 0
    loan_count = 0
    credit_utilization = 0

    # Count of repaid and total records
    repaid_count = 0
    total_records = len(credit_history)

    # Total borrowed amount
    total_borrowed = 0

    # Average time to repayment (in days)
    repayment_times = []

    for record in credit_history:
        # Count loans
        if record["recordType"] == "loan":
            loan_count += 1
            total_borrowed += int(record["amount"])

        # Track repayments
        if record["repaid"]:
            repaid_count += 1

            # Calculate time to repayment if available
            if record["repaymentTimestamp"] > 0:
                days_to_repay = (
                    int(record["repaymentTimestamp"]) - int(record["timestamp"])
                ) / (60 * 60 * 24)
                repayment_times.append(days_to_repay)

    # Calculate payment history score (0-1)
    payment_history = repaid_count / total_records if total_records > 0 else 0

    # Use average loan amount as a proxy for income
    avg_loan = total_borrowed / loan_count if loan_count > 0 else 0
    income_proxy = avg_loan * 10  # Simple heuristic

    # Calculate debt ratio proxy
    active_debt = (
        total_borrowed - (repaid_count / total_records * total_borrowed)
        if total_records > 0
        else 0
    )
    debt_ratio = active_debt / income_proxy if income_proxy > 0 else 0.5

    # Cap debt ratio at 1.0
    debt_ratio = min(debt_ratio, 1.0)

    # Use average repayment time as a proxy for credit utilization
    avg_repayment_time = np.mean(repayment_times) if repayment_times else 30
    credit_utilization = min(
        avg_repayment_time / 90, 1.0
    )  # Normalize to 0-1, capped at 90 days

    # Create feature dictionary
    features = {
        "income": income_proxy,
        "debt_ratio": debt_ratio,
        "payment_history": payment_history,
        "loan_count": loan_count,
        "loan_amount": avg_loan,
        "age": 30,  # Default value as we don't have age data
        "credit_utilization": credit_utilization,
    }

    return pd.DataFrame([features])


def calculate_score_factors(features, prediction):
    """
    Calculate contributing factors to the credit score

    Parameters:
    -----------
    features : pandas.DataFrame
        Input features used for prediction
    prediction : float
        Model prediction (credit score)

    Returns:
    --------
    list
        List of factors affecting the credit score
    """
    factors = []

    # Payment history factor
    payment_history = features["payment_history"].values[0]
    if payment_history >= 0.9:
        factors.append(
            {
                "factor": "Excellent payment history",
                "impact": "positive",
                "description": "Consistently repaying debts on time",
            }
        )
    elif payment_history >= 0.7:
        factors.append(
            {
                "factor": "Good payment history",
                "impact": "positive",
                "description": "Generally repaying debts on time",
            }
        )
    elif payment_history <= 0.5:
        factors.append(
            {
                "factor": "Poor payment history",
                "impact": "negative",
                "description": "Frequently missing payments",
            }
        )

    # Debt ratio factor
    debt_ratio = features["debt_ratio"].values[0]
    if debt_ratio <= 0.3:
        factors.append(
            {
                "factor": "Low debt ratio",
                "impact": "positive",
                "description": "Low amount of debt relative to income",
            }
        )
    elif debt_ratio >= 0.6:
        factors.append(
            {
                "factor": "High debt ratio",
                "impact": "negative",
                "description": "High amount of debt relative to income",
            }
        )

    # Credit utilization factor
    credit_util = features["credit_utilization"].values[0]
    if credit_util <= 0.3:
        factors.append(
            {
                "factor": "Low credit utilization",
                "impact": "positive",
                "description": "Using a small portion of available credit",
            }
        )
    elif credit_util >= 0.7:
        factors.append(
            {
                "factor": "High credit utilization",
                "impact": "negative",
                "description": "Using a large portion of available credit",
            }
        )

    # Loan count factor
    loan_count = features["loan_count"].values[0]
    if loan_count >= 5:
        factors.append(
            {
                "factor": "Multiple loans",
                "impact": "neutral",
                "description": "History of managing multiple loans",
            }
        )
    elif loan_count == 0:
        factors.append(
            {
                "factor": "Limited credit history",
                "impact": "neutral",
                "description": "Few or no previous loans on record",
            }
        )

    return factors


@app.route("/health", methods=["GET"])
def health_check():
    """Health check endpoint"""
    return jsonify(
        {
            "status": "ok",
            "model_loaded": model is not None,
            "timestamp": datetime.now().isoformat(),
        }
    )


@app.route("/predict", methods=["POST"])
def predict():
    """
    Endpoint for credit score prediction

    Expected JSON input:
    {
        "creditHistory": [
            {
                "timestamp": 1621500000,
                "amount": 5000,
                "repaid": true,
                "repaymentTimestamp": 1623500000,
                "provider": "0x123...",
                "recordType": "loan",
                "scoreImpact": 5
            },
            ...
        ]
    }
    """
    try:
        data = request.get_json()

        if not data or "creditHistory" not in data:
            return (
                jsonify(
                    {"error": 'Invalid input data. Expected "creditHistory" field.'}
                ),
                400,
            )

        credit_history = data["creditHistory"]

        # Handle empty credit history
        if not credit_history:
            return jsonify(
                {
                    "score": 500,  # Default score for no history
                    "confidence": 0,
                    "factors": [
                        {
                            "factor": "No credit history",
                            "impact": "neutral",
                            "description": "No credit records found",
                        }
                    ],
                }
            )

        # Preprocess blockchain data
        features = preprocess_blockchain_data(credit_history)

        if features is None:
            return jsonify({"error": "Failed to process credit history data"}), 400

        # Make prediction
        prediction = model.predict(features)[0]

        # Ensure prediction is within valid credit score range
        prediction = max(300, min(850, prediction))

        # Calculate confidence (simple heuristic based on number of records)
        confidence = min(0.5 + (len(credit_history) * 0.05), 0.95)

        # Calculate factors affecting the score
        factors = calculate_score_factors(features, prediction)

        return jsonify(
            {
                "score": int(prediction),
                "confidence": round(confidence, 2),
                "factors": factors,
            }
        )

    except Exception as e:
        return jsonify({"error": f"Prediction failed: {str(e)}"}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
