# MAX DIRECTIVE — Deploy FalcoClaw Runtime Security System

## Priority: HIGH
## Classification: Security Infrastructure
## Channel: #mission-control

---

Max, we need to stand up FalcoClaw — our runtime security layer for the OpenClaw agent system. This is now a priority given the current OpenClaw threat landscape.

## Context — Why This Matters NOW

OpenClaw has had 6+ CVEs in 6 weeks in 2026:

- **CVE-2026-32922** (CVSS 9.9) — `device.token.rotate` lets any paired device mint admin tokens. Fixed in 2026.3.11.
- **CVE-2026-33579** (CVSS 9.8) — `/pair approve` doesn't validate caller has admin scope. Fixed in 2026.3.28.
- **CVE-2026-23112** (Medium) — `/allowlist add|remove` bypasses admin scope check via `operator.write`.
- **CVE-2026-25253** ("ClawBleed") — Cross-site WebSocket hijacking, confirmed active exploitation.
- **ClawHavoc Campaign** — 341+ malicious ClawHub skills deploying AMOS infostealer.
- **63% of 135K+ public instances run with zero authentication.**

Microsoft says OpenClaw is "not appropriate to run on a standard personal or enterprise workstation." CrowdStrike built an entire content pack just to detect and remove it. We need kernel-level visibility into what our agents are doing.

We also had the Karen incident (unauthorized client email). FalcoClaw would have caught that SMTP connection in real-time.

## What FalcoClaw Is

FalcoClaw deploys Sysdig Falco with custom detection rules built specifically for OpenClaw agent systems. It monitors syscalls via eBPF and detects:

- Privilege escalation (token scope widening, unauthorized pair approvals)
- Unauthorized agent actions (SMTP without approval, writes outside workspace)
- Credential access (reads of .openclaw/, gateway tokens, API keys)
- Supply chain attacks (malicious ClawHub skills spawning processes, accessing creds)
- OpenBrain protection (unauthorized PostgreSQL connections, pg_dump, pgvector tampering)
- Network anomalies (outbound to unknown domains, suspicious TLDs, rare ports)

## Deployment Tasks

### 1. Create GitHub Repo

- Repo: `thnkbig/falcoclaw`
- Visibility: Public (open source, Apache 2.0)
- Description: "Runtime security for AI agent systems — built for OpenClaw"
- Push all files from the FalcoClaw scaffold (README, rules/, config/, scripts/, docs/)

### 2. First — Update OpenClaw

Before deploying FalcoClaw, verify our OpenClaw instance is on version **2026.3.28 or later**. If not:

```bash
# Check current version
openclaw --version

# Update
npm install openclaw@latest
```

This patches CVE-2026-32922 and CVE-2026-33579. Non-negotiable.

### 3. Run OpenClaw Security Audit

```bash
openclaw security audit --deep
openclaw security audit --json > /tmp/openclaw-audit.json
```

Share results in #mission-control. Fix any flagged issues before proceeding.

### 4. Deploy FalcoClaw on the DigitalOcean Droplet

```bash
git clone https://github.com/thnkbig/falcoclaw.git
cd falcoclaw
sudo ./scripts/install.sh --mode host \
  --telegram-token "$TELEGRAM_BOT_TOKEN" \
  --telegram-chat-id "$TELEGRAM_CHAT_ID" \
  --telegram-topic-id "$SECURITY_ALERTS_TOPIC_ID"
```

If Docker mode is preferred (to keep it alongside OpenClaw containers):

```bash
./scripts/install.sh --mode docker \
  --telegram-token "$TELEGRAM_BOT_TOKEN" \
  --telegram-chat-id "$TELEGRAM_CHAT_ID"
```

### 5. Create #security-alerts Telegram Forum Topic

Create a new forum topic in our Telegram group called `#security-alerts`. This is where Falcosidekick routes alerts. Update the topic ID in the FalcoClaw config.

### 6. Set Up OpenBrain Schema

Run the schema SQL against OpenBrain:

```bash
psql -h localhost -p 8888 -d openbrain -U postgres < config/openbrain_schema.sql
```

This creates:
- `falcoclaw_alerts` table with pgvector embedding column
- `falcoclaw_recent_alerts` view (last 24h)
- `falcoclaw_critical_unresolved` view (for agent queries)

### 7. Tune Rules to Our Environment

Edit `config/falcoclaw.yaml`:
- Set correct paths for agent workspaces, MEMORY.md locations
- Add our specific allowed outbound destinations
- Verify agent process names match our OpenClaw config
- Set the 24-hour baseline profiling period

### 8. Configure Alert Escalation

Per the config:
- **CRITICAL** → Max (#mission-control) — auto-escalate
- **WARNING** → Heimdall (#intelligence) — manual review
- **supply_chain** tagged → Reed (#technical) — auto-escalate

### 9. Harden OpenClaw Config

Based on the security research, apply these immediately:

```
# In openclaw.json or via openclaw config
security: "full"
ask: "on"  # Change from "off" — require approval for exec
```

- Set gateway bind to **loopback** or **Tailscale** (not LAN/0.0.0.0)
- Set mDNS to **minimal mode** or disable: `OPENCLAW_DISABLE_BONJOUR=1`
- Audit all installed ClawHub skills: `openclaw skills list`
- Remove any skills not explicitly approved

## Delegation

- **Reed** (#technical): Review the Falco rules for syntax and completeness. Verify eBPF probe loads correctly on the DO droplet kernel.
- **Heimdall** (#intelligence): Once deployed, you own security alert triage. Query `falcoclaw_recent_alerts` in OpenBrain for context.
- **Pepper** (#coordination): Track this deployment as a project. Report status to me.

## Success Criteria

- [ ] `thnkbig/falcoclaw` repo live on GitHub
- [ ] OpenClaw updated to >= 2026.3.28
- [ ] `openclaw security audit --deep` passes clean
- [ ] Falco running on DO droplet with eBPF (no kernel module)
- [ ] FalcoClaw custom rules loaded (4 rule files)
- [ ] Falcosidekick routing to Telegram #security-alerts
- [ ] OpenBrain `falcoclaw_alerts` table created with pgvector index
- [ ] Alert escalation routing confirmed (test alert → Max)
- [ ] 24-hour baseline profiling completed
- [ ] Gateway bind mode set to loopback or Tailscale
- [ ] mDNS disabled or set to minimal
- [ ] exec approval mode set to "on"
- [ ] All ClawHub skills audited

## Timeline

Deploy within 48 hours. The CVE cadence on OpenClaw is accelerating — we cannot wait.

---

*FalcoClaw — Because if your agents have claws, they need a talon to keep them in check.*

**— Rudy**
