# Project Structure: Decentralized Credit Scoring System

```
Decentralized_Credit_Scoring_System/
├── docs/
│   ├── README.md
│   ├── Design_Documentation.pdf
│   ├── User_Guide.md
├── code/
│   ├── backend/
│   │   ├── app.py
│   │   ├── requirements.txt
│   │   └── tests/
│   │       ├── test_api.py
│   │       └── test_integration.py
│   ├── frontend/
│   │   ├── src/
│   │   │   ├── App.js
│   │   │   ├── index.js
│   │   │   └── components/
│   │   │       ├── Dashboard.js
│   │   │       └── LoanCalculator.js
│   │   ├── public/
│   │   │   ├── index.html
│   │   │   └── favicon.ico
│   │   ├── package.json
│   │   └── webpack.config.js
│   ├── ai_models/
│   │   ├── credit_scoring_model.pkl
│   │   └── training_scripts/
│   │       ├── train_model.py
│   │       └── data_preprocessing.py
│   ├── blockchain/
│   │   ├── contracts/
│   │   │   ├── CreditScore.sol
│   │   │   └── LoanContract.sol
│   │   ├── migrations/
│   │   │   ├── 1_initial_migration.js
│   │   │   └── 2_deploy_contracts.js
│   │   ├── truffle-config.js
│   │   └── tests/
│   │       ├── test_creditscore.js
│   │       └── test_loancontract.js
├── resources/
│   ├── datasets/
│   │   ├── financial_data.csv
│   │   └── user_profiles.csv
│   ├── references/
│   │   ├── Blockchain_Overview.pdf
│   │   └── AI_in_Finance.pdf
│   ├── designs/
│   │   ├── wireframes.pdf
│   │   └── architecture_diagram.png
