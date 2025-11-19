# BlockScore Backend Deployment Guide

## Overview

This guide provides comprehensive instructions for deploying the BlockScore backend in production environments. The application is designed for high availability, scalability, and security in financial services environments.

## Prerequisites

### System Requirements

**Minimum Requirements:**
- CPU: 4 cores
- RAM: 8GB
- Storage: 50GB SSD
- Network: 1Gbps

**Recommended Production:**
- CPU: 8+ cores
- RAM: 16GB+
- Storage: 100GB+ SSD with backup
- Network: 10Gbps
- Load balancer support

### Software Dependencies

- **Python**: 3.11+
- **PostgreSQL**: 14+
- **Redis**: 6.2+
- **Nginx**: 1.20+ (reverse proxy)
- **Docker**: 20.10+ (containerized deployment)
- **SSL Certificate**: Valid TLS certificate

### External Services

- **Blockchain Node**: Ethereum/Polygon RPC endpoint
- **Email Service**: SMTP server or service (SendGrid, AWS SES)
- **Monitoring**: Application performance monitoring (APM)
- **Logging**: Centralized logging service

## Environment Setup

### 1. Server Preparation

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y python3.11 python3.11-venv python3-pip \
    postgresql postgresql-contrib redis-server nginx \
    supervisor git curl wget

# Create application user
sudo useradd -m -s /bin/bash blockscore
sudo usermod -aG sudo blockscore
```

### 2. Database Setup

```bash
# Switch to postgres user
sudo -u postgres psql

# Create database and user
CREATE DATABASE blockscore_prod;
CREATE USER blockscore_user WITH PASSWORD 'secure_password_here';
GRANT ALL PRIVILEGES ON DATABASE blockscore_prod TO blockscore_user;
ALTER USER blockscore_user CREATEDB;
\q

# Configure PostgreSQL
sudo nano /etc/postgresql/14/main/postgresql.conf
# Set: shared_preload_libraries = 'pg_stat_statements'
# Set: max_connections = 200
# Set: shared_buffers = 256MB

sudo nano /etc/postgresql/14/main/pg_hba.conf
# Add: local   blockscore_prod   blockscore_user   md5

sudo systemctl restart postgresql
```

### 3. Redis Configuration

```bash
# Configure Redis
sudo nano /etc/redis/redis.conf

# Key settings:
# maxmemory 2gb
# maxmemory-policy allkeys-lru
# save 900 1
# save 300 10
# save 60 10000
# requirepass your_redis_password_here

sudo systemctl restart redis-server
sudo systemctl enable redis-server
```

## Application Deployment

### 1. Code Deployment

```bash
# Switch to application user
sudo su - blockscore

# Clone repository
git clone https://github.com/your-org/BlockScore.git
cd BlockScore/code/backend

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Install production dependencies
pip install gunicorn supervisor psycopg2-binary
```

### 2. Environment Configuration

```bash
# Create production environment file
nano .env.production
```

```env
# Application Settings
FLASK_ENV=production
SECRET_KEY=your_super_secret_key_here_minimum_32_characters
JWT_SECRET_KEY=your_jwt_secret_key_here_minimum_32_characters

# Database Configuration
DATABASE_URL=postgresql://blockscore_user:secure_password_here@localhost:5432/blockscore_prod
SQLALCHEMY_DATABASE_URI=postgresql://blockscore_user:secure_password_here@localhost:5432/blockscore_prod

# Redis Configuration
REDIS_URL=redis://:your_redis_password_here@localhost:6379/0
CACHE_REDIS_URL=redis://:your_redis_password_here@localhost:6379/1
CELERY_BROKER_URL=redis://:your_redis_password_here@localhost:6379/2

# Security Settings
BCRYPT_LOG_ROUNDS=12
SESSION_COOKIE_SECURE=True
SESSION_COOKIE_HTTPONLY=True
SESSION_COOKIE_SAMESITE=Lax
WTF_CSRF_ENABLED=True

# Email Configuration
MAIL_SERVER=smtp.your-provider.com
MAIL_PORT=587
MAIL_USE_TLS=True
MAIL_USERNAME=your_email@company.com
MAIL_PASSWORD=your_email_password
MAIL_DEFAULT_SENDER=noreply@blockscore.com

# Blockchain Configuration
BLOCKCHAIN_PROVIDER_URL=https://mainnet.infura.io/v3/your_project_id
BLOCKCHAIN_FROM_ADDRESS=0x_your_ethereum_address
BLOCKCHAIN_PRIVATE_KEY=0x_your_private_key
CREDIT_SCORE_CONTRACT_ADDRESS=0x_deployed_contract_address

# External APIs
OPENAI_API_KEY=your_openai_api_key
PLAID_CLIENT_ID=your_plaid_client_id
PLAID_SECRET=your_plaid_secret
PLAID_ENV=production

# Monitoring and Logging
SENTRY_DSN=https://your_sentry_dsn
LOG_LEVEL=INFO
ENABLE_METRICS=True

# Rate Limiting
RATELIMIT_STORAGE_URL=redis://:your_redis_password_here@localhost:6379/3

# File Storage
UPLOAD_FOLDER=/var/blockscore/uploads
MAX_CONTENT_LENGTH=16777216  # 16MB
```

### 3. Database Migration

```bash
# Initialize database
export FLASK_APP=app.py
export FLASK_ENV=production
source venv/bin/activate

# Run migrations
flask db init
flask db migrate -m "Initial migration"
flask db upgrade

# Create admin user (optional)
python scripts/create_admin.py
```

### 4. Application Server Setup (Gunicorn)

```bash
# Create Gunicorn configuration
nano gunicorn.conf.py
```

```python
# Gunicorn configuration file
import multiprocessing

# Server socket
bind = "127.0.0.1:5000"
backlog = 2048

# Worker processes
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "gevent"
worker_connections = 1000
max_requests = 1000
max_requests_jitter = 50
preload_app = True
timeout = 30
keepalive = 2

# Logging
accesslog = "/var/log/blockscore/access.log"
errorlog = "/var/log/blockscore/error.log"
loglevel = "info"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'

# Process naming
proc_name = "blockscore-backend"

# Server mechanics
daemon = False
pidfile = "/var/run/blockscore/gunicorn.pid"
user = "blockscore"
group = "blockscore"
tmp_upload_dir = None

# SSL (if terminating SSL at application level)
# keyfile = "/path/to/private.key"
# certfile = "/path/to/certificate.crt"
```

### 5. Process Management (Supervisor)

```bash
# Create supervisor configuration
sudo nano /etc/supervisor/conf.d/blockscore.conf
```

```ini
[program:blockscore-backend]
command=/home/blockscore/BlockScore/code/backend/venv/bin/gunicorn -c gunicorn.conf.py app:app
directory=/home/blockscore/BlockScore/code/backend
user=blockscore
group=blockscore
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/log/blockscore/supervisor.log
stdout_logfile_maxbytes=50MB
stdout_logfile_backups=10
environment=FLASK_ENV=production

[program:blockscore-celery]
command=/home/blockscore/BlockScore/code/backend/venv/bin/celery -A app.celery worker --loglevel=info
directory=/home/blockscore/BlockScore/code/backend
user=blockscore
group=blockscore
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/log/blockscore/celery.log
stdout_logfile_maxbytes=50MB
stdout_logfile_backups=10
environment=FLASK_ENV=production

[program:blockscore-celery-beat]
command=/home/blockscore/BlockScore/code/backend/venv/bin/celery -A app.celery beat --loglevel=info
directory=/home/blockscore/BlockScore/code/backend
user=blockscore
group=blockscore
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/log/blockscore/celery-beat.log
stdout_logfile_maxbytes=50MB
stdout_logfile_backups=10
environment=FLASK_ENV=production
```

### 6. Reverse Proxy (Nginx)

```bash
# Create Nginx configuration
sudo nano /etc/nginx/sites-available/blockscore
```

```nginx
upstream blockscore_backend {
    server 127.0.0.1:5000 fail_timeout=0;
}

server {
    listen 80;
    server_name api.blockscore.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.blockscore.com;

    # SSL Configuration
    ssl_certificate /etc/ssl/certs/blockscore.crt;
    ssl_certificate_key /etc/ssl/private/blockscore.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options DENY;
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy "strict-origin-when-cross-origin";
    add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'";

    # Rate Limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=auth:10m rate=5r/s;

    # Logging
    access_log /var/log/nginx/blockscore_access.log;
    error_log /var/log/nginx/blockscore_error.log;

    # General Settings
    client_max_body_size 16M;
    keepalive_timeout 65;
    gzip on;
    gzip_types text/plain application/json application/javascript text/css;

    # API Endpoints
    location /api/ {
        limit_req zone=api burst=20 nodelay;

        proxy_pass http://blockscore_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Authentication Endpoints (stricter rate limiting)
    location /api/auth/ {
        limit_req zone=auth burst=10 nodelay;

        proxy_pass http://blockscore_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
    }

    # Health Check
    location /api/health {
        proxy_pass http://blockscore_backend;
        access_log off;
    }

    # Static Files (if any)
    location /static/ {
        alias /home/blockscore/BlockScore/code/backend/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

```bash
# Enable site and restart Nginx
sudo ln -s /etc/nginx/sites-available/blockscore /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 7. SSL Certificate Setup

```bash
# Using Let's Encrypt (Certbot)
sudo apt install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d api.blockscore.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

### 8. Logging Setup

```bash
# Create log directories
sudo mkdir -p /var/log/blockscore
sudo chown blockscore:blockscore /var/log/blockscore

# Configure log rotation
sudo nano /etc/logrotate.d/blockscore
```

```
/var/log/blockscore/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 blockscore blockscore
    postrotate
        supervisorctl restart blockscore-backend
    endscript
}
```

## Docker Deployment

### 1. Dockerfile

```dockerfile
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV FLASK_ENV=production

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Create application user
RUN useradd --create-home --shell /bin/bash blockscore

# Set work directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Change ownership to application user
RUN chown -R blockscore:blockscore /app
USER blockscore

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/api/health || exit 1

# Run application
CMD ["gunicorn", "-c", "gunicorn.conf.py", "app:app"]
```

### 2. Docker Compose

```yaml
version: '3.8'

services:
  backend:
    build: .
    ports:
      - "5000:5000"
    environment:
      - FLASK_ENV=production
      - DATABASE_URL=postgresql://blockscore_user:password@postgres:5432/blockscore_prod
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - postgres
      - redis
    volumes:
      - ./uploads:/app/uploads
    restart: unless-stopped

  postgres:
    image: postgres:14
    environment:
      - POSTGRES_DB=blockscore_prod
      - POSTGRES_USER=blockscore_user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  redis:
    image: redis:6.2-alpine
    command: redis-server --requirepass password
    volumes:
      - redis_data:/data
    restart: unless-stopped

  celery:
    build: .
    command: celery -A app.celery worker --loglevel=info
    environment:
      - FLASK_ENV=production
      - DATABASE_URL=postgresql://blockscore_user:password@postgres:5432/blockscore_prod
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - postgres
      - redis
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
    depends_on:
      - backend
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
```

## Kubernetes Deployment

### 1. Namespace and ConfigMap

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: blockscore

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: blockscore-config
  namespace: blockscore
data:
  FLASK_ENV: "production"
  LOG_LEVEL: "INFO"
  REDIS_URL: "redis://redis-service:6379/0"
```

### 2. Secrets

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: blockscore-secrets
  namespace: blockscore
type: Opaque
stringData:
  SECRET_KEY: "your_super_secret_key_here"
  JWT_SECRET_KEY: "your_jwt_secret_key_here"
  DATABASE_URL: "postgresql://user:pass@postgres:5432/blockscore"
  BLOCKCHAIN_PRIVATE_KEY: "0x_your_private_key"
```

### 3. Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blockscore-backend
  namespace: blockscore
spec:
  replicas: 3
  selector:
    matchLabels:
      app: blockscore-backend
  template:
    metadata:
      labels:
        app: blockscore-backend
    spec:
      containers:
      - name: backend
        image: blockscore/backend:latest
        ports:
        - containerPort: 5000
        envFrom:
        - configMapRef:
            name: blockscore-config
        - secretRef:
            name: blockscore-secrets
        livenessProbe:
          httpGet:
            path: /api/health
            port: 5000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /api/health
            port: 5000
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
```

### 4. Service and Ingress

```yaml
apiVersion: v1
kind: Service
metadata:
  name: blockscore-backend-service
  namespace: blockscore
spec:
  selector:
    app: blockscore-backend
  ports:
  - port: 80
    targetPort: 5000
  type: ClusterIP

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: blockscore-ingress
  namespace: blockscore
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/rate-limit: "100"
spec:
  tls:
  - hosts:
    - api.blockscore.com
    secretName: blockscore-tls
  rules:
  - host: api.blockscore.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: blockscore-backend-service
            port:
              number: 80
```

## Monitoring and Observability

### 1. Application Monitoring

```bash
# Install monitoring dependencies
pip install prometheus-client sentry-sdk

# Configure Prometheus metrics endpoint
# Add to app.py:
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}
```

### 2. Health Checks

```python
# Enhanced health check endpoint
@app.route('/api/health/detailed')
@jwt_required()
def detailed_health():
    health_status = {
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'services': {
            'database': check_database_health(),
            'redis': check_redis_health(),
            'blockchain': check_blockchain_health()
        }
    }
    return jsonify(health_status)
```

### 3. Logging Configuration

```python
import logging
from logging.handlers import RotatingFileHandler
import sentry_sdk
from sentry_sdk.integrations.flask import FlaskIntegration

# Configure Sentry
sentry_sdk.init(
    dsn=os.getenv('SENTRY_DSN'),
    integrations=[FlaskIntegration()],
    traces_sample_rate=0.1
)

# Configure logging
if not app.debug:
    file_handler = RotatingFileHandler(
        '/var/log/blockscore/app.log',
        maxBytes=10240000,
        backupCount=10
    )
    file_handler.setFormatter(logging.Formatter(
        '%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
    ))
    file_handler.setLevel(logging.INFO)
    app.logger.addHandler(file_handler)
    app.logger.setLevel(logging.INFO)
```

## Security Configuration

### 1. Firewall Setup

```bash
# Configure UFW firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 2. Fail2Ban Configuration

```bash
# Install and configure Fail2Ban
sudo apt install fail2ban

sudo nano /etc/fail2ban/jail.local
```

```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[nginx-http-auth]
enabled = true
filter = nginx-http-auth
logpath = /var/log/nginx/blockscore_error.log
maxretry = 3

[nginx-limit-req]
enabled = true
filter = nginx-limit-req
logpath = /var/log/nginx/blockscore_error.log
maxretry = 10
```

### 3. Database Security

```sql
-- Create read-only user for monitoring
CREATE USER blockscore_monitor WITH PASSWORD 'monitor_password';
GRANT CONNECT ON DATABASE blockscore_prod TO blockscore_monitor;
GRANT USAGE ON SCHEMA public TO blockscore_monitor;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO blockscore_monitor;

-- Enable row-level security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_isolation ON users FOR ALL TO blockscore_user USING (id = current_user_id());
```

## Backup and Recovery

### 1. Database Backup

```bash
# Create backup script
nano /home/blockscore/scripts/backup_db.sh
```

```bash
#!/bin/bash
BACKUP_DIR="/var/backups/blockscore"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="blockscore_prod"
DB_USER="blockscore_user"

mkdir -p $BACKUP_DIR

# Create database backup
pg_dump -U $DB_USER -h localhost $DB_NAME | gzip > $BACKUP_DIR/db_backup_$DATE.sql.gz

# Keep only last 30 days of backups
find $BACKUP_DIR -name "db_backup_*.sql.gz" -mtime +30 -delete

# Upload to S3 (optional)
# aws s3 cp $BACKUP_DIR/db_backup_$DATE.sql.gz s3://blockscore-backups/database/
```

```bash
# Schedule backup
crontab -e
# Add: 0 2 * * * /home/blockscore/scripts/backup_db.sh
```

### 2. Application Backup

```bash
# Create application backup script
nano /home/blockscore/scripts/backup_app.sh
```

```bash
#!/bin/bash
BACKUP_DIR="/var/backups/blockscore"
DATE=$(date +%Y%m%d_%H%M%S)
APP_DIR="/home/blockscore/BlockScore"

# Create application backup
tar -czf $BACKUP_DIR/app_backup_$DATE.tar.gz -C $APP_DIR .

# Keep only last 7 days of application backups
find $BACKUP_DIR -name "app_backup_*.tar.gz" -mtime +7 -delete
```

## Performance Optimization

### 1. Database Optimization

```sql
-- Create indexes for better performance
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
CREATE INDEX CONCURRENTLY idx_credit_scores_user_id ON credit_scores(user_id);
CREATE INDEX CONCURRENTLY idx_credit_scores_calculated_at ON credit_scores(calculated_at);
CREATE INDEX CONCURRENTLY idx_loan_applications_user_id ON loan_applications(user_id);
CREATE INDEX CONCURRENTLY idx_audit_logs_user_id_timestamp ON audit_logs(user_id, timestamp);

-- Analyze tables
ANALYZE;

-- Configure PostgreSQL for production
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
ALTER SYSTEM SET maintenance_work_mem = '64MB';
ALTER SYSTEM SET checkpoint_completion_target = 0.9;
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET default_statistics_target = 100;
SELECT pg_reload_conf();
```

### 2. Redis Optimization

```bash
# Configure Redis for production
echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
echo 'net.core.somaxconn = 65535' >> /etc/sysctl.conf
sysctl -p
```

### 3. Application Optimization

```python
# Enable connection pooling
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool

engine = create_engine(
    DATABASE_URL,
    poolclass=QueuePool,
    pool_size=20,
    max_overflow=30,
    pool_pre_ping=True,
    pool_recycle=3600
)
```

## Troubleshooting

### Common Issues

1. **High Memory Usage**
   - Check Gunicorn worker count
   - Monitor Redis memory usage
   - Review database query performance

2. **Slow Response Times**
   - Enable query logging
   - Check Redis hit rates
   - Monitor database connections

3. **SSL Certificate Issues**
   - Verify certificate chain
   - Check certificate expiration
   - Validate DNS configuration

### Useful Commands

```bash
# Check application status
sudo supervisorctl status

# View application logs
tail -f /var/log/blockscore/supervisor.log

# Check database connections
sudo -u postgres psql -c "SELECT * FROM pg_stat_activity;"

# Monitor Redis
redis-cli info memory

# Check Nginx status
sudo nginx -t
sudo systemctl status nginx

# View system resources
htop
df -h
free -m
```

## Maintenance

### Regular Tasks

1. **Daily**
   - Monitor application logs
   - Check system resources
   - Verify backup completion

2. **Weekly**
   - Review security logs
   - Update system packages
   - Analyze performance metrics

3. **Monthly**
   - Update application dependencies
   - Review and rotate logs
   - Test backup restoration

### Update Procedure

```bash
# 1. Backup current version
cp -r /home/blockscore/BlockScore /home/blockscore/BlockScore.backup

# 2. Pull latest code
cd /home/blockscore/BlockScore
git pull origin main

# 3. Update dependencies
source venv/bin/activate
pip install -r requirements.txt

# 4. Run database migrations
flask db upgrade

# 5. Restart services
sudo supervisorctl restart blockscore-backend
sudo supervisorctl restart blockscore-celery

# 6. Verify deployment
curl -f https://api.blockscore.com/api/health
```

This deployment guide provides a comprehensive foundation for running BlockScore in production. Adjust configurations based on your specific infrastructure requirements and security policies.
