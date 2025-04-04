import React from 'react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import { CssBaseline, Container } from '@material-ui/core';
import Dashboard from './components/Dashboard';
import LoanCalculator from './components/LoanCalculator';

function App() {
  return (
    <Router>
      <CssBaseline />
      <Container maxWidth="md">
        <Switch>
          <Route exact path="/" component={Dashboard} />
          <Route path="/loan-calculator" component={LoanCalculator} />
        </Switch>
      </Container>
    </Router>
  );
}

export default App;