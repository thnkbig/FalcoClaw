# Contributors

Thank you to everyone who contributes to FalcoClaw!

## How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes with clear, descriptive messages
4. Run `falco --validate` on any modified rules files
5. Submit a pull request

## Pull Request Guidelines

- All CI checks must pass
- New rules must include a `desc` field explaining the threat they address
- Response rules must have at least one non-destructive action before adding destructive ones
- Breaking changes require a `BREAKING CHANGE:` in the commit message

## Reporting Security Issues

See [SECURITY.md](./SECURITY.md) for responsible disclosure guidelines.

## Code of Conduct

This project follows the [Falco Community Code of Conduct](https://github.com/falcosecurity/.github/blob/main/CODE_OF_CONDUCT.md).
