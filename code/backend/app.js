/**
 * Main application file for BlockScore API
 */
const express = require('express');
const cors = require('cors');
const config = require('./config');
const contractService = require('./services/contractService');
const authService = require('./services/authService');

// Import routes
const authRoutes = require('./routes/authRoutes');
const creditRoutes = require('./routes/creditRoutes');
const loanRoutes = require('./routes/loanRoutes');

// Initialize Express app
const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
    next();
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/credit', creditRoutes);
app.use('/api/loans', loanRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date() });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
        success: false,
        message: 'Internal server error',
        error: process.env.NODE_ENV === 'development' ? err.message : undefined,
    });
});

// Initialize services
const initServices = async () => {
    try {
        // Initialize authentication service
        authService.init();

        // Initialize contract service
        await contractService.init();

        console.log('Services initialized successfully');
    } catch (error) {
        console.error('Failed to initialize services:', error);
        process.exit(1);
    }
};

// Start server
const PORT = config.api.port;
app.listen(PORT, async () => {
    console.log(`BlockScore API running on port ${PORT}`);
    await initServices();
});

module.exports = app;
