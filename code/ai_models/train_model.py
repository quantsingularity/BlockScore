import pandas as pd
import numpy as np
from xgboost import XGBRegressor
from sklearn.model_selection import train_test_split
import joblib
import os

def generate_synthetic_data(n_samples=1000):
    """
    Generate synthetic financial data for training the credit scoring model
    """
    np.random.seed(42)

    # Generate features
    income = np.random.normal(50000, 20000, n_samples)  # Income with mean 50k
    debt_ratio = np.random.beta(2, 5, n_samples)  # Debt ratio between 0-1, skewed towards lower values
    payment_history = np.random.binomial(10, 0.8, n_samples) / 10  # Payment history score (0-1)
    loan_count = np.random.poisson(3, n_samples)  # Number of previous loans
    loan_amount = np.random.lognormal(8, 1, n_samples)  # Loan amounts

    # Additional features
    age = np.random.normal(35, 10, n_samples)
    age = np.clip(age, 18, 80)  # Clip to reasonable age range
    credit_utilization = np.random.beta(2, 4, n_samples)  # Credit utilization ratio

    # Generate target variable (credit score) based on features
    # Credit scores typically range from 300-850
    base_score = 300 + (payment_history * 300) + (income / 100000 * 150) - (debt_ratio * 200) + (np.log1p(loan_count) * 50) - (credit_utilization * 100)

    # Add some noise
    noise = np.random.normal(0, 30, n_samples)
    credit_score = base_score + noise

    # Clip to valid credit score range
    credit_score = np.clip(credit_score, 300, 850).astype(int)

    # Create DataFrame
    data = pd.DataFrame({
        'income': income,
        'debt_ratio': debt_ratio,
        'payment_history': payment_history,
        'loan_count': loan_count,
        'loan_amount': loan_amount,
        'age': age,
        'credit_utilization': credit_utilization,
        'credit_score': credit_score
    })

    return data

def preprocess_data(df):
    """
    Preprocess data for model training
    """
    # Create features and target
    X = df.drop('credit_score', axis=1)
    y = df['credit_score']

    # Split data
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    return X_train, X_test, y_train, y_test

def train_model(X_train, y_train):
    """
    Train XGBoost model for credit scoring
    """
    model = XGBRegressor(
        n_estimators=100,
        learning_rate=0.1,
        max_depth=5,
        objective='reg:squarederror',
        random_state=42
    )

    model.fit(X_train, y_train)
    return model

def evaluate_model(model, X_test, y_test):
    """
    Evaluate model performance
    """
    predictions = model.predict(X_test)
    mse = np.mean((predictions - y_test) ** 2)
    rmse = np.sqrt(mse)
    mae = np.mean(np.abs(predictions - y_test))

    print(f"Model Performance:")
    print(f"Mean Squared Error: {mse:.2f}")
    print(f"Root Mean Squared Error: {rmse:.2f}")
    print(f"Mean Absolute Error: {mae:.2f}")

    return mse, rmse, mae

def save_model(model, output_path):
    """
    Save trained model to disk
    """
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    joblib.dump(model, output_path)
    print(f"Model saved to {output_path}")

def main():
    # Create directory for datasets if it doesn't exist
    os.makedirs('../ai_models', exist_ok=True)

    # Generate synthetic data
    print("Generating synthetic financial data...")
    data = generate_synthetic_data(n_samples=5000)

    # Save data to CSV
    data_path = '../ai_models/financial_data.csv'
    data.to_csv(data_path, index=False)
    print(f"Data saved to {data_path}")

    # Preprocess data
    print("Preprocessing data...")
    X_train, X_test, y_train, y_test = preprocess_data(data)

    # Train model
    print("Training credit scoring model...")
    model = train_model(X_train, y_train)

    # Evaluate model
    print("Evaluating model performance...")
    evaluate_model(model, X_test, y_test)

    # Save model
    model_path = '../ai_models/credit_scoring_model.pkl'
    save_model(model, model_path)

    print("Model training complete!")

if __name__ == "__main__":
    main()
