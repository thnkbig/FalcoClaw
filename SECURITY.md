# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 2.x     | ✅                 |
| 1.x     | ⚠️ Security only   |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them to the maintainers via one of the following:

1. **GitHub Private Vulnerability Reporting** (preferred)
   - Navigate to the Security tab → " Advisories" → "Report a vulnerability"

2. **Email**
   - Contact the maintainers directly through the THNKBIG security team

## What to Include

When reporting, please include:

- A description of the vulnerability
- Steps to reproduce the issue
- Potential impact of the vulnerability
- Any suggested fixes (optional)

## Response Timeline

- **Acknowledgment**: Within 48 hours
- **Initial Assessment**: Within 7 days  
- **Fix Development**: Depends on severity (critical = ASAP)
- **Disclosure**: After fix is available, with credit to reporter (with permission)

## Security Considerations

- FalcoClaw runs with root privileges to execute response actions (kill, block_ip, etc.)
- **Always deploy in dry_run mode first** and validate response rules before enabling live response
- Response actions like `linux:kill` and `linux:block_ip` are destructive — test thoroughly
- Keep response rules files (`rules.yaml`) readable only by the falcoclaw service user
- Bot tokens in response rules should use environment variables, never hardcoded values

## Response Action Safety

All destructive actions have built-in safety guards:

- `linux:kill`: Protected PIDs (1, 0) cannot be killed
- `linux:block_ip`: Localhost (127.0.0.1, ::1) cannot be blocked  
- `linux:quarantine`: Requires file path, applies immutable flag
- `linux:disable_user`: Cannot disable root or system users
