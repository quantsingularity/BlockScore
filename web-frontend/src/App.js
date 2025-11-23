import React, { useState, useEffect } from 'react';
import { Routes, Route, useLocation } from 'react-router-dom';
import { Box, Container } from '@mui/material';
import { AnimatePresence } from 'framer-motion';

// Layouts
import MainLayout from './layouts/MainLayout';

// Pages
import Dashboard from './pages/Dashboard';
import LoanCalculator from './pages/LoanCalculator';
import Profile from './pages/Profile';
import NotFound from './pages/NotFound';
import Landing from './pages/Landing';

// Components
import LoadingScreen from './components/common/LoadingScreen';

function App() {
    const location = useLocation();
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        // Simulate initial loading
        const timer = setTimeout(() => {
            setIsLoading(false);
        }, 1500);

        return () => clearTimeout(timer);
    }, []);

    if (isLoading) {
        return <LoadingScreen />;
    }

    return (
        <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
            <AnimatePresence mode="wait">
                <Routes location={location} key={location.pathname}>
                    <Route path="/" element={<Landing />} />

                    <Route element={<MainLayout />}>
                        <Route path="/dashboard" element={<Dashboard />} />
                        <Route path="/loan-calculator" element={<LoanCalculator />} />
                        <Route path="/profile" element={<Profile />} />
                    </Route>

                    <Route path="*" element={<NotFound />} />
                </Routes>
            </AnimatePresence>
        </Box>
    );
}

export default App;
