# Changelog

All notable changes to FalcoClaw will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release as Falco Talon for Linux
- 14 response actionners (linux:kill, linux:block_ip, linux:quarantine, linux:disable_user, linux:stop_service, linux:firewall, linux:script, openclaw:disable_skill, openclaw:revoke_token, openclaw:restart, openclaw:disable_agent, agent:investigate, agent:notify, agent:telegram)
- 12 response rules covering CRITICAL and WARNING priority events
- systemd service for automated startup
- Dockerfile and goreleaser for multi-platform binary releases
- GitHub Actions CI/CD pipeline (lint, test, security scan, auto-tag, release)
- CONTRIBUTORS.md and SECURITY.md

## [v2.0.0] - 2026-04-05

### Added
- Complete rewrite as a Go response engine
- Migration from Falco-sidekick plugin to standalone binary
- Environment variable expansion in response rules
- Telegram forum topic routing via `message_thread_id`

[Unreleased]: https://github.com/thnkbig/falcoclaw/compare/v2.0.0...HEAD
[v2.0.0]: https://github.com/thnkbig/falcoclaw/releases/tag/v2.0.0
