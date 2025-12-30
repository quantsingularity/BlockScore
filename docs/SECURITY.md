# BlockScore Security Guide

## Authentication & Authorization

### JWT Tokens

- Access token: 15 minutes expiry
- Refresh token: 7 days expiry
- Tokens use HS256 algorithm

### Password Requirements

- Minimum 8 characters
- Must include: uppercase, lowercase, numbers, special characters
- Bcrypt hashing with 12 rounds

### Account Protection

- Account locks after 5 failed login attempts
- 30-minute lockout period
- Failed attempts tracked per user

## Rate Limiting

| Endpoint                  | Limit        | Window     |
| ------------------------- | ------------ | ---------- |
| `/auth/register`          | 5 requests   | per minute |
| `/auth/login`             | 5 requests   | per minute |
| `/credit/calculate-score` | 10 requests  | per minute |
| `/loans/apply`            | 3 requests   | per hour   |
| Default                   | 100 requests | per hour   |

## Data Protection

### Encryption

- Passwords: Bcrypt hashing
- JWTs: HS256 signing
- Database: SQLAlchemy ORM (SQL injection protection)

### CORS

- Configurable allowed origins
- Credentials support enabled
- Preflight request handling

### Audit Logging

- All authentication events logged
- 10-year retention for audit logs
- Includes: user_id, IP address, user agent, timestamp

## Best Practices

1. **Never commit secrets**: Use environment variables
2. **Rotate keys regularly**: JWT_SECRET_KEY, SECRET_KEY
3. **Use HTTPS in production**: Enable FORCE_HTTPS
4. **Enable MFA**: Two-factor authentication available
5. **Monitor audit logs**: Review for suspicious activity

See [Configuration Guide](CONFIGURATION.md) for security settings.
