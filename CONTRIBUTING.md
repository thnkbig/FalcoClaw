# Contributing to FalcoClaw

Thank you for your interest in contributing to FalcoClaw.

## Development Setup

### Prerequisites
- Go 1.22 or later
- Falco running on the host (for integration testing)
- Docker (for containerized testing)

### Initial Setup

```bash
git clone https://github.com/thnkbig/falcoclaw.git
cd falcoclaw
make setup   # install dev dependencies + pre-commit hooks
make build   # verify the build succeeds
```

### Workflow

1. **Fork** the repository on GitHub
2. **Clone** your fork locally
3. **Create a branch** for your change: `git checkout -b my-feature`
4. **Make your change** and commit using [Conventional Commits](https://www.conventionalcommits.org/)
5. **Run tests**: `make test` (or `make ci-check-fast` for a fast subset)
6. **Push** to your fork and open a Pull Request

### Code Style

- Format: `gofmt` (auto-applied via pre-commit hook)
- Lint: `golangci-lint run`
- No new `//nolint:` suppressions without justification

### Commit Message Format

```
<type>(<scope>): <short description>

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`

Examples:
- `feat(notifiers): add Slack webhook notifier`
- `fix(rules): handle nil pointer in rule loader`
- `docs(contributing): add architecture overview link`

### Pull Request Process

1. Fill out the PR template completely
2. Ensure all CI checks pass
3. Request review from a maintainer
4. Address review feedback promptly

### Reporting Security Issues

**Do not open a public issue for security vulnerabilities.**

See [SECURITY.md](./SECURITY.md) for how to report vulnerabilities securely.

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.
