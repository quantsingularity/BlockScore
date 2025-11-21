import React, { useState, useEffect } from 'react';
import { Card, CardContent, Typography } from '@material-ui/core';
import axios from 'axios';

export default function Dashboard() {
  const [score, setScore] = useState(null);

  useEffect(() => {
    const fetchScore = async () => {
      const response = await axios.post('/calculate-score', {
        walletAddress: '0x123...',
      });
      setScore(response.data.score);
    };
    fetchScore();
  }, []);

  return (
    <Card>
      <CardContent>
        <Typography variant="h5">
          Credit Score: {score || 'Loading...'}
        </Typography>
        <Typography color="textSecondary">
          Updated in real-time from blockchain
        </Typography>
      </CardContent>
    </Card>
  );
}
