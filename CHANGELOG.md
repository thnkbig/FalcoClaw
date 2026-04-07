# Changelog

All notable changes to FalcoClaw will be documented in this file.

## [v0.1.0] — 2026-04-05

Initial open source release.

### Added
- Core response engine with webhook listener (port 2804)
- 7 Linux actionners: kill, block_ip, quarantine, disable_user, stop_service, firewall, script
- 4 OpenClaw actionners: disable_skill, revoke_token, restart, disable_agent
- 3 Agent actionners: notify, investigate, telegram
- YAML response rules with priority operators and tag matching
- Safety guards on all destructive actionners
- Dry run mode (global, per-rule, per-action)
- CLI commands: server, check, actionners, version
- Falco and Falcosidekick webhook integration
- Docker and systemd deployment options
- GitHub Actions CI/CD pipeline
- goreleaser for multi-arch binary and Docker image builds
- Architecture documentation
- Contributing guide, security policy, code of conduct

[v0.1.0]: https://github.com/thnkbig/FalcoClaw/releases/tag/v0.1.0
