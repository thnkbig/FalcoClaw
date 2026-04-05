# FalcoClaw Architecture

## Overview

FalcoClaw is a runtime security response layer that sits between Falco's syscall event stream and automated remediation actions. It subscribes to Falco's output, enriches events with context, matches them against configurable response rules, and executes actions — kill, block, quarantine, or dispatch — in milliseconds.

## System Components

```
┌──────────────────────────────────────────────────────────────┐
│                       Linux Host                            │
│  ┌─────────┐    ┌─────────────┐    ┌───────────────────┐  │
│  │  Falco  │───▶│ FalcoClaw   │───▶│  Response Engine  │  │
│  │ (syscall│    │  (Go agent)  │    │  - kill process   │  │
│  │ monitor)│    │             │    │  - block ip       │  │
│  └─────────┘    └─────────────┘    │  - quarantine     │  │
│                       │              │  - webhook dispatch│  │
│                       ▼              └───────────────────┘  │
│                ┌─────────────┐                              │
│                │ Config/YAML │                              │
│                │   rules     │                              │
│                └─────────────┘                              │
└──────────────────────────────────────────────────────────────┘
```

## Core Packages

### `cmd/falcoclaw`
Entry point. Handles CLI flag parsing, config loading, and server startup.

### `internal/rules`
Loads and evaluates response rules from YAML configuration. Rules define:
- `match` conditions (Falco rule name, severity, process pattern, etc.)
- `actions` to execute on match (kill, block, quarantine, webhook)
- `throttle` window to prevent action storms

### `internal/models`
Event models. Defines the enriched `Event` struct that FalcoClaw produces after parsing and augmenting a Falco output event — includes process tree, file metadata, and matched rule info.

### `notifiers`
Response action implementations:
- `kill.go` — terminates process by PID using `syscall.Kill`
- `blockip.go` — inserts/removes iptables drop rules
- `quarantine.go` — moves file to quarantine dir + sets immutable flag
- `webhook.go` — sends structured JSON payload to HTTP endpoint

### `outputs`
Plugin system for routing events to external systems (SIEM, ticketing, agent frameworks).

## Data Flow

1. **Ingest** — Falco emits JSON events to a named pipe or socket; FalcoClaw reads and parses them.
2. **Enrich** — Events are augmented with process tree (via `/proc`), file metadata, and user context.
3. **Match** — Enriched events are evaluated against the rules engine; first matching rule with a `respond` action fires.
4. **Act** — Action goroutines execute in parallel with bounded timeout. Failures are logged and exposed via metrics.
5. **Dispatch** — Webhook actions POST enriched event JSON to configured endpoints (OpenClaw, PagerDuty, etc.).

## Configuration

See `config.yaml` for the full schema. Key sections:

```yaml
falco:
  socket: /var/run/falco/falco.sock   # named pipe or HTTP endpoint
  timeout: 10s                          # read/write timeout

rules:
  config_dir: /etc/falcoclaw/rules/   # glob pattern for rule YAML files

actions:
  kill:
    enabled: true
  blockip:
    enabled: true
    iptables_path: /usr/sbin/iptables
  quarantine:
    enabled: true
    quarantine_dir: /var/lib/falcoclaw/quarantine
  webhook:
    enabled: true
    timeout: 5s

logging:
  level: info                          # debug, info, warn, error
  format: json
```

## Security Considerations

- FalcoClaw requires `--privileged` or `CAP_KILL + CAP_NET_ADMIN` in Docker —Principle of Least Privilege applies
- iptables modifications require root; restrict `blockip` action to specific source ranges via rule config
- Webhook payloads should be TLS-backed; do not send plain-text over untrusted networks
- Quarantine moves files but does not delete them by default

## Extension Points

- **Custom notifiers**: implement the `Notifier` interface in `notifiers/`
- **Output adapters**: implement the `Outputter` interface in `outputs/`
- **Rule enrichment hooks**: inject extra context into events before rule evaluation

## Performance

- Event loop is single-threaded per instance; action goroutines are pooled
- Target latency from Falco event to action execution: < 50ms p99
- Memory footprint: ~20MB resident for a typical ruleset
