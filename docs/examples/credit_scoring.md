# Credit Scoring Example

Examples for calculating credit scores and viewing credit history.

## Python Example

```python
import requests

BASE_URL = "http://localhost:5000/api"
TOKEN = "your-access-token-here"
headers = {"Authorization": f"Bearer {TOKEN}"}

# 1. Calculate credit score
score_data = {
    "walletAddress": "0x742d35Cc6634C0532925a3b844Bc454e4438f44e",
    "force_recalculation": False
}
response = requests.post(
    f"{BASE_URL}/credit/calculate-score",
    headers=headers,
    json=score_data
)
result = response.json()

print("Credit Score:", result["data"]["score"])
print("Rating:", result["data"]["rating"])
print("\nFactors:")
for factor in result["data"]["factors"]:
    print(f"  - {factor['factor']} ({factor['impact']})")

# 2. Get credit history
response = requests.get(
    f"{BASE_URL}/credit/history?page=1&per_page=10",
    headers=headers
)
history = response.json()

print("\nCredit History:")
for event in history["data"]["history"]:
    print(f"  - {event['event_date']}: {event['description']}")
```

## JavaScript Example

```javascript
const axios = require('axios');

const BASE_URL = 'http://localhost:5000/api';
const token = 'your-access-token-here';
const headers = { Authorization: `Bearer ${token}` };

async function creditScoreExample() {
    // Calculate score
    const scoreRes = await axios.post(
        `${BASE_URL}/credit/calculate-score`,
        {
            walletAddress: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
            force_recalculation: false,
        },
        { headers },
    );

    console.log('Credit Score:', scoreRes.data.data.score);
    console.log('Rating:', scoreRes.data.data.rating);
    console.log('\nFactors:');
    scoreRes.data.data.factors.forEach((f) => {
        console.log(`  - ${f.factor} (${f.impact})`);
    });

    // Get history
    const historyRes = await axios.get(`${BASE_URL}/credit/history?page=1&per_page=10`, {
        headers,
    });

    console.log('\nCredit History:');
    historyRes.data.data.history.forEach((event) => {
        console.log(`  - ${event.event_date}: ${event.description}`);
    });
}

creditScoreExample();
```
