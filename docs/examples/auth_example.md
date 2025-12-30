# Authentication Example

Complete example demonstrating user registration, login, and authenticated requests.

## Python Example

```python
import requests

BASE_URL = "http://localhost:5000/api"

# 1. Register new user
register_data = {
    "email": "demo@blockscore.io",
    "password": "SecurePass123!"
}
response = requests.post(f"{BASE_URL}/auth/register", json=register_data)
print("Register:", response.json())

# 2. Login
login_data = {
    "email": "demo@blockscore.io",
    "password": "SecurePass123!"
}
response = requests.post(f"{BASE_URL}/auth/login", json=login_data)
tokens = response.json()["tokens"]
access_token = tokens["access_token"]
print("Access Token:", access_token[:20] + "...")

# 3. Get profile (authenticated request)
headers = {"Authorization": f"Bearer {access_token}"}
response = requests.get(f"{BASE_URL}/profile", headers=headers)
print("Profile:", response.json())

# 4. Logout
response = requests.post(f"{BASE_URL}/auth/logout", headers=headers)
print("Logout:", response.json())
```

## JavaScript Example

```javascript
const axios = require('axios');
const BASE_URL = 'http://localhost:5000/api';

async function authExample() {
    try {
        // Register
        const registerRes = await axios.post(`${BASE_URL}/auth/register`, {
            email: 'demo@blockscore.io',
            password: 'SecurePass123!',
        });
        console.log('Registered:', registerRes.data);

        // Login
        const loginRes = await axios.post(`${BASE_URL}/auth/login`, {
            email: 'demo@blockscore.io',
            password: 'SecurePass123!',
        });
        const accessToken = loginRes.data.tokens.access_token;
        console.log('Logged in, token:', accessToken.substring(0, 20) + '...');

        // Get profile
        const profileRes = await axios.get(`${BASE_URL}/profile`, {
            headers: { Authorization: `Bearer ${accessToken}` },
        });
        console.log('Profile:', profileRes.data);

        // Logout
        const logoutRes = await axios.post(
            `${BASE_URL}/auth/logout`,
            {},
            {
                headers: { Authorization: `Bearer ${accessToken}` },
            },
        );
        console.log('Logged out:', logoutRes.data);
    } catch (error) {
        console.error('Error:', error.response?.data || error.message);
    }
}

authExample();
```

## cURL Example

```bash
#!/bin/bash

BASE_URL="http://localhost:5000/api"

# Register
echo "Registering..."
curl -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@blockscore.io","password":"SecurePass123!"}'

# Login
echo -e "\n\nLogging in..."
TOKEN=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@blockscore.io","password":"SecurePass123!"}' \
  | jq -r '.tokens.access_token')

echo "Token: ${TOKEN:0:20}..."

# Get profile
echo -e "\n\nGetting profile..."
curl -X GET "$BASE_URL/profile" \
  -H "Authorization: Bearer $TOKEN"

# Logout
echo -e "\n\nLogging out..."
curl -X POST "$BASE_URL/auth/logout" \
  -H "Authorization: Bearer $TOKEN"
```
