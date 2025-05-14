import React from 'react';
import { Outlet } from 'react-router-dom';
import { Box } from '@mui/material';
import Navbar from '../components/navigation/Navbar';
import Sidebar from '../components/navigation/Sidebar';
import Footer from '../components/navigation/Footer';

const MainLayout = () => {
  const [mobileOpen, setMobileOpen] = React.useState(false);

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen);
  };

  return (
    <Box sx={{ display: 'flex', minHeight: '100vh' }}>
      {/* Navbar for mobile */}
      <Navbar onDrawerToggle={handleDrawerToggle} />

      {/* Sidebar */}
      <Sidebar
        mobileOpen={mobileOpen}
        onDrawerToggle={handleDrawerToggle}
      />

      {/* Main content */}
      <Box
        component="main"
        sx={{
          flexGrow: 1,
          p: { xs: 2, sm: 3, md: 4 },
          width: { sm: `calc(100% - 240px)` },
          mt: '64px',
          display: 'flex',
          flexDirection: 'column'
        }}
      >
        <Box sx={{ flexGrow: 1 }}>
          <Outlet />
        </Box>
        <Footer />
      </Box>
    </Box>
  );
};

export default MainLayout;
