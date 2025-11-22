const CreditScore = artifacts.require('CreditScore');

contract('CreditScore', (accounts) => {
    it('should store credit records', async () => {
        const instance = await CreditScore.deployed();
        await instance.addRecord(1000, { from: accounts[0] });
        const records = await instance.getCreditHistory(accounts[0]);
        assert.equal(records.length, 1, 'Record not stored');
    });
});
