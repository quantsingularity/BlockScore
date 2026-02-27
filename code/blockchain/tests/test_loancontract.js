const LoanContract = artifacts.require('LoanContract');

contract('LoanContract', (accounts) => {
  it('should create loan requests', async () => {
    const instance = await LoanContract.deployed();
    await instance.createLoan(5000, 5, { from: accounts[0] });
    const loan = await instance.loans(accounts[0]);
    assert.equal(loan.amount, 5000, 'Loan creation failed');
  });
});
