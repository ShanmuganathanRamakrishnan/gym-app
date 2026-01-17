# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly:

1. **Do NOT** open a public GitHub issue
2. Email the maintainer directly (add contact email)
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

## Response Timeline

- **Acknowledgment**: Within 48 hours
- **Initial Assessment**: Within 7 days
- **Fix/Patch**: Depends on severity (critical: 24-72 hours)

## Security Best Practices

### For Contributors
- Never commit secrets, tokens, or API keys
- Use environment variables for sensitive config
- Run `git secrets` scan before pushing
- Review dependencies for known vulnerabilities

### For Users
- Keep dependencies updated
- Use strong, unique passwords
- Enable 2FA on GitHub
- Rotate API keys regularly

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.x     | ✅         |
| < 1.0   | ❌         |

## Known Security Measures

- JWT tokens with short expiry
- HTTPS enforced in production
- Input validation on all endpoints
- Rate limiting on API and MCP endpoints
- Audit logging for sensitive operations
