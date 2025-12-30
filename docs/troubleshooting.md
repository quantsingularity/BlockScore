# BlockScore Troubleshooting Guide

## Common Issues

### Installation Issues

**Issue**: Python virtual environment creation fails  
**Solution**: Install python3-venv: `sudo apt install python3-venv`

**Issue**: Node.js version incompatible  
**Solution**: Install Node.js 16+: `nvm install 16 && nvm use 16`

### Runtime Issues

**Issue**: Backend fails to start - "Address already in use"  
**Solution**: Kill process on port 5000: `lsof -ti:5000 | xargs kill -9`

**Issue**: Database connection error  
**Solution**: Check DATABASE_URL in .env, ensure SQLite or PostgreSQL is accessible

**Issue**: Blockchain connection fails  
**Solution**: Start Ganache: `ganache-cli -p 8545` or check BLOCKCHAIN_PROVIDER_URL

### Authentication Issues

**Issue**: JWT token expired  
**Solution**: Login again to get new tokens (15min expiry for access tokens)

**Issue**: Account locked after failed logins  
**Solution**: Wait 30 minutes or contact admin to unlock

### API Issues

**Issue**: Rate limit exceeded (429 error)  
**Solution**: Wait for rate limit window to reset (see X-RateLimit-Reset header)

**Issue**: CORS error from frontend  
**Solution**: Check CORS configuration in backend/app.py

See [Configuration Guide](CONFIGURATION.md) for detailed settings.
