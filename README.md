# FalcoClaw 🦅🔒

**Runtime security for AI agent systems — built for [OpenClaw](https://github.com/openclaw/openclaw).**

FalcoClaw deploys [Falco](https://falco.org) with purpose-built rules that detect privilege escalation, unauthorized agent actions, prompt injection artifacts, credential access, and supply chain attacks targeting self-hosted AI agent gateways.

> **Why this matters:** In 2026 alone, OpenClaw has seen 6+ CVEs in 6 weeks (CVE-2026-32922 CVSS 9.9, CVE-2026-33579 CVSS 9.8, and more), 1,000+ malicious ClawHub skills, cross-site WebSocket hijacking, and 63% of 135K+ public instances running with zero authentication. FalcoClaw gives you kernel-level eyes on what your agents are actually doing.

---

## What FalcoClaw Detects

| Threat Category | Detection |
|---|---|
| **Privilege Escalation** | Token rotation scope widening, `/pair approve` without admin scope, synthetic `operator.admin` fallback |
| **Unauthorized Agent Actions** | Outbound SMTP/HTTP from agent processes without approval, unexpected file writes to MEMORY.md / SHARED-STATE.md |
| **Credential Access** | Reads of `.openclaw/` config, gateway tokens, API keys, database credentials |
| **Supply Chain / ClawHub** | Skill installation spawning unexpected child processes, network callbacks to unknown domains |
| **Prompt Injection Artifacts** | Agent processes writing to config files, modifying allowlists, or executing shell commands after ingesting external content |
| **Lateral Movement** | WebSocket connections from unexpected origins, mDNS broadcast data leakage, node pairing from non-local sources |
| **Data Exfiltration** | Large outbound transfers from agent memory stores (PostgreSQL/pgvector, MEMORY.md files) |
| **OpenBrain Protection** | Unauthorized connections to PostgreSQL (port 8888), pg_dump/pg_dumpall invocations, pgvector index tampering |

---

## Quick Start

### Option 1: Host Install (Debian/Ubuntu — e.g., DigitalOcean Droplet)

```bash
git clone https://github.com/thnkbig/falcoclaw.git
cd falcoclaw
sudo ./scripts/install.sh --mode host
```

### Option 2: Docker (alongside OpenClaw)

```bash
git clone https://github.com/thnkbig/falcoclaw.git
cd falcoclaw
./scripts/install.sh --mode docker
```

Both modes deploy:
- Falco with eBPF probe (no kernel module required)
- FalcoClaw custom rules (`rules/`)
- Falcosidekick for alert routing → Telegram + OpenBrain (PostgreSQL)

---

## Configuration

Copy and edit the config:

```bash
cp config/falcoclaw.yaml.example config/falcoclaw.yaml
```

Key settings:

```yaml
# config/falcoclaw.yaml
openclaw:
  gateway_pid_file: /var/run/openclaw-gateway.pid
  config_dir: ~/.openclaw
  agent_processes:
    - openclaw
    - node
  memory_paths:
    - /path/to/MEMORY.md
    - /path/to/SHARED-STATE.md
    - /path/to/HEARTBEAT.md

openbrain:
  host: localhost
  port: 8888
  db: openbrain
  alerts_table: falcoclaw_alerts

alerts:
  telegram:
    enabled: true
    webhook_url: "https://api.telegram.org/bot<TOKEN>/sendMessage"
    chat_id: "<SECURITY_ALERTS_TOPIC_ID>"
    forum_topic_id: "<TOPIC_ID>"
  openbrain:
    enabled: true
    # Alerts stored with pgvector embeddings for agent-queryable security context
```

---

## Architecture

```
┌──────────────────────────────────────────────────┐
│                  Linux Host / VM                  │
│                                                   │
│  ┌─────────────┐    ┌──────────────────────────┐ │
│  │   OpenClaw   │    │     Falco (eBPF)         │ │
│  │   Gateway    │    │  ┌────────────────────┐  │ │
│  │             ◄──────┤  FalcoClaw Rules     │  │ │
│  │  Agents:     │    │  │ • priv_escalation  │  │ │
│  │  • Max       │    │  │ • agent_behavior   │  │ │
│  │  • Karen     │    │  │ • credential_access│  │ │
│  │  • Heimdall  │    │  │ • supply_chain     │  │ │
│  │  • ...       │    │  │ • data_exfil       │  │ │
│  └──────┬───────┘    │  └────────────────────┘  │ │
│         │            └────────────┬─────────────┘ │
│  ┌──────┴───────┐                 │               │
│  │  OpenBrain   │    ┌────────────┴─────────────┐ │
│  │  PostgreSQL  │◄───┤    Falcosidekick         │ │
│  │  + pgvector  │    │  ┌─────┐  ┌───────────┐  │ │
│  │  port 8888   │    │  │ TG  │  │ PostgreSQL│  │ │
│  └──────────────┘    │  │ Bot │  │  Insert   │  │ │
│                      │  └──┬──┘  └─────┬─────┘  │ │
│                      └─────┼───────────┼────────┘ │
└────────────────────────────┼───────────┼──────────┘
                             │           │
                    ┌────────┴──┐   ┌────┴─────────┐
                    │ Telegram  │   │  OpenBrain    │
                    │ #security │   │  alerts table │
                    │ -alerts   │   │  + pgvector   │
                    └───────────┘   └──────────────┘
```

---

## Rule Sets

| File | Purpose |
|---|---|
| `rules/falcoclaw_base.yaml` | Core OpenClaw process monitoring |
| `rules/falcoclaw_agents.yaml` | Agent-specific behavioral rules |
| `rules/falcoclaw_openbrain.yaml` | PostgreSQL/pgvector protection |
| `rules/falcoclaw_network.yaml` | Network egress and WebSocket monitoring |
| `rules/falcoclaw_supply_chain.yaml` | ClawHub skill installation monitoring |

---

## Agent Integration

FalcoClaw is designed to feed into your agent hierarchy:

- **Heimdall** (`#intelligence`) — consumes security alerts as threat intelligence
- **Max** (`#mission-control`) — receives escalations for agent containment decisions
- **Pepper** (`#coordination`) — coordinates cross-agent response to incidents

Alerts are stored in OpenBrain with pgvector embeddings, so any agent can query:
*"Have there been any suspicious outbound connections in the last 24 hours?"*

---

## Addressing OpenClaw's Known Vulnerabilities

| CVE / Threat | How FalcoClaw Detects It |
|---|---|
| CVE-2026-32922 (token scope escalation, CVSS 9.9) | Detects `device.token.rotate` API calls that result in scope widening |
| CVE-2026-33579 (`/pair approve` priv esc, CVSS 9.8) | Monitors pairing approval events from non-admin processes |
| CVE-2026-23112 (allowlist bypass) | Watches for `/allowlist` mutations from `operator.write` scoped tokens |
| ClawHavoc malicious skills (341+ AMOS infostealers) | Detects skill-spawned processes making outbound connections or accessing credentials |
| Cross-site WebSocket hijacking (ClawBleed) | Monitors WebSocket connections from non-local origins to gateway port |
| mDNS data leakage | Alerts on mDNS broadcasts containing filesystem paths or SSH details |
| Prompt injection → shell exec | Detects shell spawns that trace back to agent message processing |

---

## Contributing

PRs welcome. See [CONTRIBUTING.md](docs/CONTRIBUTING.md).

---

## License

Apache 2.0 — See [LICENSE](LICENSE).

---

**Built by [THNKBIG Technologies](https://thnkbig.com)** — Give Engineers Their Time Back.
