# Loan Application Example

Examples for calculating loan terms and submitting loan applications.

## Python Example

```python
import requests

BASE_URL = "http://localhost:5000/api"
TOKEN = "your-access-token-here"
headers = {"Authorization": f"Bearer {TOKEN}"}

# 1. Calculate loan terms
calc_data = {
    "amount": 10000,
    "rate": 5.5,
    "term_months": 36
}
response = requests.post(
    f"{BASE_URL}/loans/calculate",
    headers=headers,
    json=calc_data
)
result = response.json()["data"]

print(f"Loan Amount: ${result['loan_amount']:,.2f}")
print(f"Monthly Payment: ${result['monthly_payment']:,.2f}")
print(f"Total Payment: ${result['total_payment']:,.2f}")
print(f"Total Interest: ${result['total_interest']:,.2f}")
print(f"Approval Probability: {result['approval_probability']}%")

# 2. Submit loan application
app_data = {
    "loan_type": "personal",
    "requested_amount": 10000.00,
    "requested_term_months": 36,
    "requested_rate": 5.5,
    "application_data": {
        "purpose": "Debt consolidation",
        "employment_status": "employed",
        "annual_income": 60000
    }
}
response = requests.post(
    f"{BASE_URL}/loans/apply",
    headers=headers,
    json=app_data
)
application = response.json()["data"]

print(f"\nApplication Number: {application['application_number']}")
print(f"Status: {application['status']}")
print(f"Approval Probability: {application['approval_probability']}%")
```

## JavaScript Example

```javascript
const axios = require('axios');

const BASE_URL = 'http://localhost:5000/api';
const token = 'your-access-token-here';
const headers = { Authorization: `Bearer ${token}` };

async function loanExample() {
    // Calculate terms
    const calcRes = await axios.post(
        `${BASE_URL}/loans/calculate`,
        { amount: 10000, rate: 5.5, term_months: 36 },
        { headers },
    );

    const calc = calcRes.data.data;
    console.log(`Loan Amount: $${calc.loan_amount.toFixed(2)}`);
    console.log(`Monthly Payment: $${calc.monthly_payment.toFixed(2)}`);
    console.log(`Total Interest: $${calc.total_interest.toFixed(2)}`);
    console.log(`Approval Probability: ${calc.approval_probability}%`);

    // Submit application
    const appRes = await axios.post(
        `${BASE_URL}/loans/apply`,
        {
            loan_type: 'personal',
            requested_amount: 10000.0,
            requested_term_months: 36,
            requested_rate: 5.5,
            application_data: {
                purpose: 'Debt consolidation',
                employment_status: 'employed',
                annual_income: 60000,
            },
        },
        { headers },
    );

    const app = appRes.data.data;
    console.log(`\nApplication #${app.application_number}`);
    console.log(`Status: ${app.status}`);
    console.log(`Approval Probability: ${app.approval_probability}%`);
}

loanExample();
```
