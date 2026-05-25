# 🧪 AUTOMATIC_TEST — Kafka Onboarding POC

Complete guide for **end-to-end automated testing** of the Kafka Onboarding POC built with .NET.
This document describes **how to run**, **what to expect**, and **how to validate** the
full pipeline (Producer → Kafka → Consumer + DLQ + Monitor).

![Kafka](https://img.shields.io/badge/Apache%20Kafka-3.8-231F20?style=for-the-badge&logo=apachekafka&logoColor=white)
![.NET](https://img.shields.io/badge/.NET-8.0-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-7+-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Tests](https://img.shields.io/badge/Tests-E2E_Automated-success?style=for-the-badge&logo=testinglibrary&logoColor=white)
![Status](https://img.shields.io/badge/Status-Production_Ready-green?style=for-the-badge)

---

## 📑 Table of Contents

- [Prerequisites](#-prerequisites)
- [Architecture](#-architecture)
- [Quick Start](#-quick-start-tldr)
- [Available Scripts](#-available-scripts)
- [Automated Test Flow](#-automated-test-flow)
- [Expected Validations](#-expected-validations)
- [Success Criteria Checklist](#-success-criteria-checklist)
- [Troubleshooting](#-troubleshooting)
- [Teardown](#-teardown)
- [Metrics and Observability](#-metrics-and-observability)
- [Full Reset](#-full-reset-clean-smoke-test)
- [Successful Execution Example](#-example-of-successful-execution)
- [Contributing](#-contributing-new-test-scenarios)

---

## ✅ Prerequisites

| Tool                | Minimum version | How to verify                          |
|---------------------|-----------------|-----------------------------------------|
| **Docker Desktop**  | 4.x             | `docker --version`                      |
| **Docker Compose**  | v2              | `docker compose version`                |
| **.NET SDK**        | 8.0+            | `dotnet --version`                      |
| **PowerShell**      | 5.1 or 7+       | `$PSVersionTable.PSVersion`             |
| **Free ports**      | 8080, 8081, 9092 | `Test-NetConnection localhost -Port 9092` |

> 💡 **PowerShell 7+ (pwsh) is recommended** — the orchestrator detects it automatically.

### 🔓 Enable script execution (first time only)

By default, Windows blocks `.ps1` scripts. Run **once**:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

Confirm with `Y`. This unblocks local scripts for your user only.

---

## 🏗️ Architecture

```text
┌───────────────┐      ┌──────────────────┐      ┌───────────────┐
│   PRODUCER    │─────▶│  onboarding-     │─────▶│   CONSUMER    │
│   (.NET)      │      │  events (3 part) │      │   (.NET)      │
└───────────────┘      └──────────────────┘      └───────┬───────┘
                                                         │ error?
                                                         ▼
                              ┌──────────────────────────────────┐
                              │  onboarding-events-dlq (3 part)  │
                              └──────────────────────────────────┘

┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│   Kafka      │   │   Kafka UI   │   │   Flink JM   │   │   Flink TM   │
│ :9092 / :29092│  │    :8080     │   │    :8081     │   │  (worker)    │
└──────────────┘   └──────────────┘   └──────────────┘   └──────────────┘
```

### 🔌 Listeners explained

| Listener | Address | Used by |
|----------|---------|---------|
| **INTERNAL** | `kafka:29092` | Containers (Flink, Kafka UI) |
| **EXTERNAL** | `localhost:9092` | .NET app running on host |

---

## ⚡ Quick Start (TL;DR)

```powershell
# 1. Clone or navigate to the project
cd C:\Projects\POCs\kafka-onboarding-dotnet\KafkaOnboarding

# 2. Run the full end-to-end test
.\scripts\run-poc.ps1

# 3. When you're done validating
.\scripts\99-stop-all.ps1
```

The `run-poc.ps1` orchestrator does **everything automatically**:
1. Spins up the Docker infrastructure
2. Validates Kafka health-check
3. Creates the topics
4. Opens 3 windows (Consumer, Monitor, Producer)

---

## 📂 Available Scripts

All scripts live in `.\scripts\` and are **idempotent** (safe to run multiple times).

| Script                       | Purpose                                          | Avg time   |
|------------------------------|--------------------------------------------------|------------|
| `01-start-infra.ps1`         | Start containers + validate Kafka health + port 9092 | ~30s    |
| `02-create-topics.ps1`       | Create/verify `onboarding-events` and DLQ        | ~3s        |
| `03-run-consumer.ps1`        | Start the .NET consumer                          | continuous |
| `04-run-producer.ps1`        | Send test events                                 | ~10–30s    |
| `05-monitor.ps1`             | Monitor consumer group LAG (refresh every 2s)    | continuous |
| `99-stop-all.ps1`            | Stop containers (optional: remove volumes)       | ~5s        |
| `run-poc.ps1`                | **End-to-end orchestrator**                      | ~60s       |

### 🔁 Manual execution (step-by-step mode)

Want to understand each step? Run them in separate terminals:

```powershell
# Terminal 1 — Infrastructure
.\scripts\01-start-infra.ps1
.\scripts\02-create-topics.ps1

# Terminal 2 — Consumer (keep running)
.\scripts\03-run-consumer.ps1

# Terminal 3 — Monitor (keep running)
.\scripts\05-monitor.ps1

# Terminal 4 — Producer (fire the test)
.\scripts\04-run-producer.ps1
```

---

## 🔄 Automated Test Flow

```
   ┌──────────────────────────┐
   │ [1/5] 01-start-infra     │  Docker compose up
   │       └─ healthcheck     │  Wait for kafka healthy + port 9092
   └────────────┬─────────────┘
                │
   ┌────────────▼─────────────┐
   │ [2/5] 02-create-topics   │  kafka-topics.sh --create
   │       ├─ onboarding-events     (3 partitions)
   │       └─ onboarding-events-dlq (3 partitions)
   └────────────┬─────────────┘
                │
   ┌────────────▼─────────────┐
   │ [3/5] Spawns CONSUMER    │  Start-Process pwsh -NoExit
   │       (waits 15s)        │  Time for subscribe + rebalance
   └────────────┬─────────────┘
                │
   ┌────────────▼─────────────┐
   │ [4/5] Spawns MONITOR     │  2s refresh of consumer-groups
   └────────────┬─────────────┘
                │
   ┌────────────▼─────────────┐
   │ [5/5] Spawns PRODUCER    │  Sends N events
   │       └─ keeps alive     │  ReadKey for visual inspection
   └──────────────────────────┘
```

---

## ✔️ Expected Validations

### 🟢 CONSUMER window

```
CONSUMER - Processing onboarding-events
[partition X] Received: { customerId: ..., status: ... }
[partition Y] Successfully processed
```

### 🟡 MONITOR window (refresh every 2s)

```
GROUP                  TOPIC               PARTITION  CURRENT-OFFSET  LAG
onboarding-processor   onboarding-events   0          XX              0
onboarding-processor   onboarding-events   1          XX              0
onboarding-processor   onboarding-events   2          XX              0
```

> 📌 **LAG = 0** across all partitions = consumer is processing in real-time.

### 🚦 Consumer Lag interpretation

| Observed LAG     | Meaning                                |
|------------------|----------------------------------------|
| `0`              | ✅ Consumer caught up — healthy         |
| `< 100`          | ✅ Normal processing                    |
| `100 — 1,000`    | ⚠️ Investigate throughput              |
| `> 1,000` growing | 🔴 Consumer can't keep up             |

### 🔵 PRODUCER window

```
PRODUCER - Sending events
[OK] Sent: customer-001 -> partition 0, offset 0
[OK] Sent: customer-002 -> partition 2, offset 0
[OK] Sent: customer-003 -> partition 1, offset 0
...
[OK] Producer finished. Press any key to close...
```

### 🌐 Kafka UI — http://localhost:8080

Manually verify:
- [ ] **Brokers** → 1 broker UP
- [ ] **Topics** → `onboarding-events` and `onboarding-events-dlq` listed
- [ ] **Topics → onboarding-events → Messages** → messages visible
- [ ] **Consumers** → `onboarding-processor` active with low/zero LAG
- [ ] **Topics → onboarding-events → Partitions** → 3 partitions with offsets > 0

### 🌐 Flink UI — http://localhost:8081

- [ ] **Overview** → 1 TaskManager registered
- [ ] **Available Task Slots** ≥ 1

---

## 🧪 Success Criteria Checklist

Check as you validate:

- [ ] ✅ `01-start-infra.ps1` finished without errors
- [ ] ✅ Kafka container status is `healthy`
- [ ] ✅ Port 9092 is reachable from host (`Test-NetConnection`)
- [ ] ✅ Topics `onboarding-events` and `onboarding-events-dlq` were created
- [ ] ✅ Consumer started and subscribed to `onboarding-processor` group
- [ ] ✅ Producer sent at least 1 event to each partition (0, 1, 2)
- [ ] ✅ Consumer processed all messages
- [ ] ✅ Monitor shows `LAG = 0` after producer finishes
- [ ] ✅ Kafka UI shows messages across partitions
- [ ] ✅ `99-stop-all.ps1` removed containers without errors

---

## 🔍 Troubleshooting

### ❌ "Cannot find path" when running scripts

**Cause:** PowerShell lacks execution permission.

**Fix:**
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### ❌ "Port 9092 not responding"

**Cause:** Another process is using the port.

**Fix:**
```powershell
# Find who's using the port
Get-NetTCPConnection -LocalPort 9092 | Select-Object OwningProcess
Get-Process -Id <PID>
```

### ❌ "Kafka container unhealthy"

**Cause:** Insufficient Docker memory or network conflict.

**Fix:**
```powershell
docker logs kafka --tail 50
docker compose down -v
docker compose up -d
```

### ❌ Consumer is not receiving messages

**Cause:** Consumer started **after** producer with `auto.offset.reset=latest`.

**Fix:** Make sure the consumer starts **before** the producer (`run-poc.ps1` handles this with `Start-Sleep 15`).

### ❌ Weird characters in terminal (`\`, `\"`, `²`)

**Cause:** PowerShell encoding is not set to UTF-8.

**Fix:** At the start of your session:
```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
```

### ❌ LAG growing continuously

**Cause:** Consumer is slow or stuck.

**Diagnosis:**
```powershell
# Inspect consumer group
docker exec kafka /opt/kafka/bin/kafka-consumer-groups.sh `
    --bootstrap-server localhost:29092 `
    --group onboarding-processor `
    --describe
```

Also check throughput in Kafka UI → Topics → `onboarding-events` → Messages.

### ❌ `Conflict. The container name "/kafka" is already in use`

**Cause:** Leftover orphan container from a previous run.

**Fix:**
```powershell
.\scripts\99-stop-all.ps1   # answer "Y" to remove volumes
.\scripts\run-poc.ps1
```

Or manually:
```powershell
docker rm -f kafka kafka-ui flink-jobmanager flink-taskmanager
.\scripts\01-start-infra.ps1
```

### ❌ `Failed to resolve 'kafka:9092'`

**Cause:** .NET client trying to resolve `kafka` hostname, which only exists inside Docker network.

**Fix:** Check that `KAFKA_ADVERTISED_LISTENERS` in `docker-compose.yml` includes `EXTERNAL://localhost:9092`. If you changed it recently:
```powershell
.\scripts\99-stop-all.ps1   # answer "Y"
.\scripts\run-poc.ps1
```

---

## 🛑 Teardown

### Stop preserving data (volumes kept)

```powershell
.\scripts\99-stop-all.ps1
# Answer "N" when asked about volumes
```

### Stop wiping EVERYTHING (full reset)

```powershell
.\scripts\99-stop-all.ps1
# Answer "Y" when asked about volumes
```

### Manual stop (no script)

```powershell
docker compose down          # keeps volumes
docker compose down -v       # also removes volumes
```

---

## 📊 Metrics and Observability

| Metric                  | Where to find it                          |
|-------------------------|-------------------------------------------|
| **Consumer Lag**        | `.\scripts\05-monitor.ps1` or Kafka UI    |
| **Throughput (msg/s)**  | Kafka UI → Topic → Overview               |
| **Partition balance**   | Kafka UI → Topic → Partitions             |
| **Messages in DLQ**     | Kafka UI → `onboarding-events-dlq`        |
| **Flink Slots**         | http://localhost:8081 → Overview          |
| **Container health**    | `docker ps --filter "name=kafka"`         |
| **Resource usage**      | `docker stats`                            |

---

## 🔁 Full Reset (Clean Smoke Test)

To guarantee a 100% clean test run:

```powershell
# 1. Wipe everything
.\scripts\99-stop-all.ps1   # answer "Y" to remove volumes

# 2. Remove images (optional, deeper clean)
docker rmi apache/kafka:3.8.0 provectuslabs/kafka-ui:latest flink:1.19-scala_2.12

# 3. Run from scratch
.\scripts\run-poc.ps1
```

---

## 📝 Example of Successful Execution

```
===========================================================
  KAFKA ONBOARDING - POC END-TO-END
  Full orchestrator (shell: pwsh)
===========================================================

[1/5] Starting infrastructure...
[OK] Kafka is healthy!
[OK] Port 9092 responding!
[OK] Infra ready!

[2/5] Ensuring topics...
   - onboarding-events
      [CREATED] 3 partitions
   - onboarding-events-dlq
      [CREATED] 3 partitions
[OK] Topics ready!

[3/5] Spawning CONSUMER in new window...
   Waiting 15s for consumer to start and subscribe...

[4/5] Spawning MONITOR in new window...

[5/5] Spawning PRODUCER in new window...

===========================================================
  POC RUNNING!
===========================================================
  Consumer  -> CONSUMER window
  Monitor   -> MONITOR window (real-time LAG)
  Producer  -> PRODUCER window (sending messages)

  Kafka UI  -> http://localhost:8080
  Flink UI  -> http://localhost:8081
```

---

## 🤝 Contributing New Test Scenarios

If you want to add **new test cases**:

1. Create a new script in `scripts/` following the `NN-action-object.ps1` pattern
2. Use **single quotes** in heredocs (`@'...'@`) to avoid escape bugs
3. Document the scenario in this README (in the [Test Flow](#-automated-test-flow) section)
4. Always write files with **UTF-8 BOM** via `[System.IO.File]::WriteAllText`

### 📋 Suggested test scenarios to add

- 🔥 **Chaos test** — kill the broker mid-flight and verify recovery
- 📈 **Load test** — measure throughput with k6 or similar tools
- 🎯 **Schema validation** — produce malformed messages and verify they hit DLQ
- 🔄 **Multiple consumer groups** — same topic consumed by 2 independent groups
- ⏱️ **Latency test** — measure end-to-end delay from produce to consume
- 🌐 **Network partition** — simulate broker disconnection
- 💾 **Persistence test** — restart broker and verify message durability

### 🧪 Template for new test scripts

```powershell
# ============================================================
# Script: NN-test-<scenario>.ps1
# Purpose: <one-line description of what this test validates>
# Idempotent: YES
# Prerequisites: <which scripts must run first>
# Expected outcome: <what success looks like>
# ============================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = 'Stop'

Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "  TEST: <SCENARIO NAME>" -ForegroundColor Cyan
Write-Host "===========================================================" -ForegroundColor Cyan

# 1. Setup
# ...

# 2. Execute test scenario
# ...

# 3. Assertions
# ...

# 4. Report results
Write-Host "[OK] Test passed!" -ForegroundColor Green
```

---

## 📌 Important Notes

- ⚠️ This is a **POC** — do **NOT** use these configurations in production without review (replication factor = 1, no auth, no TLS).
- 🔒 Ports are exposed on `localhost` only — never expose them to a public network.
- 💾 Docker volumes persist between runs unless you answer "Y" in `99-stop-all.ps1`.
- 🕒 The `Start-Sleep 15s` inside `run-poc.ps1` exists so the consumer subscribes before the producer fires — don't remove it.
- 🌐 Both `localhost:9092` (host) and `kafka:29092` (containers) point to the same broker — pick the right one based on **where your code runs**.

---

## 🔗 Related Documents

- 📖 [README.md](./README.md) — Project overview and quick start
- 🤝 [CONTRIBUTING.md](./CONTRIBUTING.md) — How to contribute
- 📜 [LICENSE](./LICENSE) — MIT License

---

## 🆘 Need Help?

- 💬 Open a [Discussion](https://github.com/ntitsolutins01/kafka-onboarding-dotnet/discussions) on GitHub
- 🐛 Open an [Issue](https://github.com/ntitsolutins01/kafka-onboarding-dotnet/issues) for bugs
- 📧 Reach out on [LinkedIn](https://www.linkedin.com/in/fabiomunizdeveloper/)

---

**Project:** Kafka Onboarding .NET POC
**Last update:** 2026-05-24
**Maintainer:** Fábio Muniz

---

> *"In God we trust. All others must bring data."*
> — **W. Edwards Deming**
