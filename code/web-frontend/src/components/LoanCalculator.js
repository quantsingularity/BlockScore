import React, { useState } from 'react';
import { Button, TextField, Paper, Typography } from '@material-ui/core';

export default function LoanCalculator() {
    const [amount, setAmount] = useState(1000);
    const [rate, setRate] = useState(5);
    const [result, setResult] = useState(null);

    const calculate = async () => {
        const response = await fetch('/api/calculate', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ amount, rate }),
        });
        setResult(await response.json());
    };

    return (
        <Paper style={{ padding: 20, margin: 20 }}>
            <Typography variant="h6">Loan Eligibility Calculator</Typography>
            <TextField
                label="Loan Amount"
                type="number"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
            />
            <TextField
                label="Interest Rate %"
                type="number"
                value={rate}
                onChange={(e) => setRate(e.target.value)}
            />
            <Button variant="contained" color="primary" onClick={calculate}>
                Calculate
            </Button>
            {result && (
                <Typography style={{ marginTop: 20 }}>
                    Approval Chance: {result.approval_probability}%
                </Typography>
            )}
        </Paper>
    );
}
