const request = require('supertest');
const { expect } = require('chai');
const sinon = require('sinon');
const axios = require('axios');
const app = require('../app');
const contractService = require('../services/contractService');
const authService = require('../services/authService');

describe('API Routes', function () {
    // Authentication routes tests
    describe('Auth Routes', function () {
        beforeEach(function () {
            // Register test user
            authService.registerUser('testuser', 'password123', 'user');
        });

        it('should register a new user', async function () {
            const res = await request(app).post('/api/auth/register').send({
                username: 'newuser',
                password: 'password123',
            });

            expect(res.statusCode).to.equal(201);
            expect(res.body.success).to.be.true;
            expect(res.body.data.username).to.equal('newuser');
        });

        it('should authenticate a valid user', async function () {
            const res = await request(app).post('/api/auth/login').send({
                username: 'testuser',
                password: 'password123',
            });

            expect(res.statusCode).to.equal(200);
            expect(res.body.success).to.be.true;
            expect(res.body.token).to.exist;
        });

        it('should reject invalid credentials', async function () {
            const res = await request(app).post('/api/auth/login').send({
                username: 'testuser',
                password: 'wrongpassword',
            });

            expect(res.statusCode).to.equal(401);
            expect(res.body.success).to.be.false;
        });
    });

    // Credit routes tests
    describe('Credit Routes', function () {
        let authToken;

        beforeEach(async function () {
            // Register and login as admin
            authService.registerUser('admin', 'admin123', 'admin');

            const loginRes = await request(app).post('/api/auth/login').send({
                username: 'admin',
                password: 'admin123',
            });

            authToken = loginRes.body.token;

            // Stub contract service methods
            sinon.stub(contractService, 'getCreditScore').resolves({
                score: 750,
                lastUpdated: Date.now(),
            });

            sinon.stub(contractService, 'getCreditHistory').resolves([
                {
                    timestamp: Date.now() - 1000000,
                    amount: 5000,
                    repaid: true,
                    repaymentTimestamp: Date.now() - 500000,
                    provider: '0x123...',
                    recordType: 'loan',
                    scoreImpact: 5,
                },
            ]);

            sinon.stub(contractService, 'addCreditRecord').resolves({
                transactionHash: '0xabc123...',
            });

            sinon.stub(contractService, 'markRecordRepaid').resolves({
                transactionHash: '0xdef456...',
            });

            // Stub axios for model API calls
            sinon.stub(axios, 'post').resolves({
                data: {
                    score: 720,
                    confidence: 0.85,
                    factors: [
                        {
                            factor: 'Good payment history',
                            impact: 'positive',
                            description: 'Generally repaying debts on time',
                        },
                    ],
                },
            });
        });

        afterEach(function () {
            contractService.getCreditScore.restore();
            contractService.getCreditHistory.restore();
            contractService.addCreditRecord.restore();
            contractService.markRecordRepaid.restore();
            axios.post.restore();
        });

        it('should get credit score for an address', async function () {
            const res = await request(app).get('/api/credit/score/0x123456789...');

            expect(res.statusCode).to.equal(200);
            expect(res.body.success).to.be.true;
            expect(res.body.data.score).to.equal(750);
        });

        it('should get credit history for an address', async function () {
            const res = await request(app).get('/api/credit/history/0x123456789...');

            expect(res.statusCode).to.equal(200);
            expect(res.body.success).to.be.true;
            expect(res.body.data).to.be.an('array');
            expect(res.body.data.length).to.equal(1);
        });

        it('should add a credit record when authorized', async function () {
            const res = await request(app)
                .post('/api/credit/record')
                .set('Authorization', `Bearer ${authToken}`)
                .send({
                    userAddress: '0x123456789...',
                    amount: 10000,
                    recordType: 'loan',
                    scoreImpact: 5,
                    privateKey: 'abcdef123456',
                });

            expect(res.statusCode).to.equal(200);
            expect(res.body.success).to.be.true;
            expect(res.body.data.transactionHash).to.exist;
        });

        it('should reject unauthorized credit record additions', async function () {
            const res = await request(app).post('/api/credit/record').send({
                userAddress: '0x123456789...',
                amount: 10000,
                recordType: 'loan',
                scoreImpact: 5,
                privateKey: 'abcdef123456',
            });

            expect(res.statusCode).to.equal(403);
            expect(res.body.success).to.be.false;
        });

        it('should calculate score using AI model', async function () {
            const res = await request(app).post('/api/credit/calculate-score').send({
                walletAddress: '0x123456789...',
            });

            expect(res.statusCode).to.equal(200);
            expect(res.body.success).to.be.true;
            expect(res.body.data.calculatedScore).to.equal(720);
            expect(res.body.data.blockchainScore).to.equal(750);
            expect(res.body.data.factors).to.be.an('array');
        });
    });

    // Loan routes tests
    describe('Loan Routes', function () {
        let authToken;

        beforeEach(async function () {
            // Register and login as admin
            authService.registerUser('admin', 'admin123', 'admin');

            const loginRes = await request(app).post('/api/auth/login').send({
                username: 'admin',
                password: 'admin123',
            });

            authToken = loginRes.body.token;

            // Stub contract service methods
            sinon.stub(contractService, 'getLoanDetails').resolves({
                borrower: '0x123456789...',
                amount: 10000,
                interestRate: 500,
                creationTimestamp: Date.now() - 1000000,
                dueDate: Date.now() + 1000000,
                approved: true,
                repaid: false,
                repaymentTimestamp: 0,
            });

            sinon.stub(contractService, 'getBorrowerLoans').resolves([1, 2, 3]);

            sinon.stub(contractService, 'createLoan').resolves({
                receipt: { transactionHash: '0xabc123...' },
                loanId: 4,
            });

            sinon.stub(contractService, 'approveLoan').resolves({
                transactionHash: '0xdef456...',
            });

            sinon.stub(contractService, 'repayLoan').resolves({
                transactionHash: '0xghi789...',
            });
        });

        afterEach(function () {
            contractService.getLoanDetails.restore();
            contractService.getBorrowerLoans.restore();
            contractService.createLoan.restore();
            contractService.approveLoan.restore();
            contractService.repayLoan.restore();
        });

        it('should get loan details by ID', async function () {
            const res = await request(app).get('/api/loans/1');

            expect(res.statusCode).to.equal(200);
            expect(res.body.success).to.be.true;
            expect(res.body.data.amount).to.equal(10000);
        });

        it('should get all loans for a borrower', async function () {
            const res = await request(app).get('/api/loans/borrower/0x123456789...');

            expect(res.statusCode).to.equal(200);
            expect(res.body.success).to.be.true;
            expect(res.body.data.loanIds).to.be.an('array');
            expect(res.body.data.loanIds.length).to.equal(3);
        });

        it('should create a loan when authenticated', async function () {
            const res = await request(app)
                .post('/api/loans/create')
                .set('Authorization', `Bearer ${authToken}`)
                .send({
                    amount: 20000,
                    interestRate: 500,
                    durationDays: 30,
                    privateKey: 'abcdef123456',
                });

            expect(res.statusCode).to.equal(200);
            expect(res.body.success).to.be.true;
            expect(res.body.data.loanId).to.equal(4);
        });

        it('should approve a loan when admin', async function () {
            const res = await request(app)
                .post('/api/loans/approve/1')
                .set('Authorization', `Bearer ${authToken}`)
                .send({
                    privateKey: 'abcdef123456',
                });

            expect(res.statusCode).to.equal(200);
            expect(res.body.success).to.be.true;
            expect(res.body.data.transactionHash).to.exist;
        });

        it('should repay a loan when authenticated', async function () {
            const res = await request(app)
                .post('/api/loans/repay/1')
                .set('Authorization', `Bearer ${authToken}`)
                .send({
                    privateKey: 'abcdef123456',
                });

            expect(res.statusCode).to.equal(200);
            expect(res.body.success).to.be.true;
            expect(res.body.data.transactionHash).to.exist;
        });
    });
});
