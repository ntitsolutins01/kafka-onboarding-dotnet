<div align="center">

[![🇧🇷 Português](https://img.shields.io/badge/lang-Portugu%C3%AAs-009C3B?style=for-the-badge&logo=googletranslate&logoColor=white)](./README.md)
[![🇺🇸 English](https://img.shields.io/badge/lang-English-B22234?style=for-the-badge&logo=googletranslate&logoColor=white)](./README_EN.md)

**🌐 Current language: English 🇺🇸** • [Mudar para Português 🇧🇷](./README.md)

</div>

---

# 🚀 Apache Kafka Onboarding — .NET (C#) + Flink SQL

> **Practical and didactic onboarding** for .NET developers who want to master
> Apache Kafka from scratch: from event theory to stream processing with Flink SQL.
> All orchestrated by **idempotent PowerShell** scripts.

![Apache Kafka](https://img.shields.io/badge/Apache%20Kafka-3.8-231F20?style=for-the-badge&logo=apachekafka&logoColor=white)
![.NET](https://img.shields.io/badge/.NET-8.0-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)
![Apache Flink](https://img.shields.io/badge/Apache%20Flink-1.19-E6526F?style=for-the-badge&logo=apacheflink&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-7+-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Tests](https://img.shields.io/badge/Tests-E2E_Automated-success?style=for-the-badge&logo=testinglibrary&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-POC_Ready-blueviolet?style=for-the-badge)

---

## 📑 Table of Contents

- [About the Project](#-about-the-project)
- [What you will learn](#-what-you-will-learn)
- [Project Architecture](#️-project-architecture)
- [Tech Stack](#-tech-stack)
- [Repository Structure](#-repository-structure)
- [Prerequisites](#-prerequisites)
- [Quick Start (1 command)](#️-quick-start-1-command)
- [How it Works](#-how-it-works)
- [Available Scripts](#️-available-scripts)
- [🧪 Automated End-to-End Tests](#-automated-end-to-end-tests)
- [Dashboards and Tools](#-dashboards-and-tools)
- [Key Concepts Illustrated in the Code](#-key-concepts-illustrated-in-the-code)
- [Stream Processing with Flink SQL](#-stream-processing-with-flink-sql)
- [Configuration](#️-configuration)
- [Study Roadmap](#️-study-roadmap)
- [Troubleshooting](#️-troubleshooting)
- [FAQ](#-faq)
- [Contributing](#-contributing)
- [References and Resources](#-references-and-resources)
- [License](#-license)
- [Author](#-author)

---

## 📌 About the Project

This repository is a **complete onboarding guide** for Apache Kafka using **.NET 8 (C#)** as the main language, with stream processing via **Apache Flink SQL**. The project was built based on the official Confluent course *"Getting Started with Apache Kafka® and Real-Time Data Streaming"* and translates each theoretical concept into **working code**, ready to run locally in minutes.

### 💡 Why this project?

- 🎓 **Learn Kafka in practice** — every concept (partitions, consumer groups, DLQ, lag) is demonstrated with working code
- 🚀 **Quick start in 60 seconds** — `.\scripts\run-poc.ps1` and everything is up and running
- 📚 **Real and reproducible** — based on real production patterns, not toy examples
- 🇧🇷 **Documentation in PT-BR and EN** — accessible to the global community
- 🛠️ **Modern stack** — .NET 8, Kafka 3.8 (KRaft), Flink 1.19, Docker Compose v2
- 🤖 **Full automation via PowerShell** — a single command spins up the infra, validates health-checks, creates topics, opens Consumer, LAG Monitor, and Producer in separate windows

The proposal is simple: **learn by doing**. Each file in this repository represents a real concept from the Kafka ecosystem — no unnecessary abstractions, no excessive boilerplate, with total focus on clarity and applicability.

### 🎯 Who is this project for?

- 👨‍💻 **.NET developers** who want to learn Kafka
- 🎓 **Students** of distributed and event-driven architectures
- 🏗️ **Architects** prototyping event-oriented solutions
- 👨‍🏫 **Instructors** looking for didactic material with real code
- 🔍 **SREs** wanting to understand the Kafka ecosystem end-to-end

---

## 🎯 What you will learn

| Concept                  | Description                                                       |
|--------------------------|-------------------------------------------------------------------|
| **Topics and Partitions**| How Kafka organizes and distributes events into immutable logs    |
| **Brokers and Clusters** | The distributed infrastructure that powers Kafka                  |
| **Replication**          | Fault tolerance with leaders and followers                        |
| **KRaft**                | Modern Zookeeper-less mode (Apache Kafka 4.0+)                    |
| **.NET Producer**        | Publish events with guaranteed idempotence and durability         |
| **.NET Consumer**        | Consume events with manual offset commit and consumer groups      |
| **Consumer Lag**         | Real-time monitoring of processing delay                          |
| **Dead Letter Queue**    | Error message handling via `*-dlq` topic                          |
| **Internal/External Listeners** | How to expose Kafka to host apps and containers            |
| **Schema Registry**      | Schema governance with Avro, JSON Schema, and Protobuf            |
| **Kafka Connect**        | Integration with external systems without writing code            |
| **Flink SQL**            | Stream processing with time windows and real-time alerts          |

---

## 🏗️ Project Architecture

```text
                ┌─────────────────────────────────────────────┐
                │      Apache Kafka (KRaft - no Zookeeper)    │
                │                                             │
                │     ┌──────────────────────────────────┐    │
                │     │   Topic: onboarding-events       │    │
                │     │  Partition 0 | Partition 1 | P2  │    │
                │     └──────────────────────────────────┘    │
                │     ┌──────────────────────────────────┐    │
                │     │   Topic: onboarding-events-dlq   │    │
                │     │  Partition 0 | Partition 1 | P2  │    │
                │     └──────────────────────────────────┘    │
                │                                             │
                │  Listeners:                                 │
                │   • INTERNAL → kafka:29092 (containers)     │
                │   • EXTERNAL → localhost:9092 (host .NET)   │
                └────────┬───────────────────────┬────────────┘
                         │                       │
              ┌──────────▼──────────┐   ┌────────▼──────────┐
              │   .NET Producer     │   │  Apache Flink     │
              │   .NET Consumer     │   │  (JobManager +    │
              │   (Windows host)    │   │   TaskManager)    │
              └─────────────────────┘   └───────────────────┘

              ┌──────────────────────┐  ┌─────────────────────┐
              │  Kafka UI :8080      │  │  Flink Dashboard    │
              │  (Provectus)         │  │  :8081              │
              └──────────────────────┘  └─────────────────────┘
```

### 🔌 Network listeners

| Listener     | Endpoint            | Used by                                |
|--------------|---------------------|----------------------------------------|
| **INTERNAL** | `kafka:29092`       | Containers (Flink, Kafka UI)           |
| **EXTERNAL** | `localhost:9092`    | .NET apps running on the host          |

---

## 🛠️ Tech Stack

| Layer                  | Technology                         | Version  | Purpose                                     |
|------------------------|------------------------------------|----------|---------------------------------------------|
| **Messaging**          | Apache Kafka                       | 3.8.0    | Distributed streaming platform              |
| **Stream Processing**  | Apache Flink                       | 1.19     | Real-time stream processing                 |
| **Application**        | .NET                               | 8.0      | Producer & Consumer apps                    |
| **Kafka Client**       | Confluent.Kafka                    | 2.x      | Official .NET client for Kafka              |
| **Containerization**   | Docker + Docker Compose            | v2       | Local infra orchestration                   |
| **Monitoring UI**      | Kafka UI (Provectus)               | latest   | Graphical cluster visualization             |
| **Automation**         | PowerShell                         | 5.1 / 7+ | Idempotent orchestration scripts            |
| **Serialization**      | System.Text.Json                   | built-in | JSON event serialization                    |

---

## 📁 Repository Structure

```text
kafka-onboarding-dotnet/
│
├── 📄 docker-compose.yml          # Kafka (KRaft) + Kafka UI + Flink (JM + TM)
├── 📄 KafkaOnboarding.csproj      # .NET 8 project
├── 📄 Program.cs                  # Entry point — producer / consumer
├── 📄 README.md                   # Portuguese version
├── 📄 README_EN.md                # You are here 😊
├── 📄 AUTOMATIC_TEST.md           # 🧪 Complete automated E2E tests guide
├── 📄 MANUAL_TEST.md              # 🧑‍🔬 Didactic manual tests guide
├── 📄 CONTRIBUTING.md             # 🤝 How to contribute
├── 📄 LICENSE                     # 📜 MIT License
│
├── 📁 scripts/                    # 🤖 Full PowerShell automation
│   ├── 01-start-infra.ps1         # Spins up containers + validates Kafka health + port 9092
│   ├── 02-create-topics.ps1       # Creates onboarding-events and DLQ topics (idempotent)
│   ├── 03-run-consumer.ps1        # Starts .NET consumer (dedicated window)
│   ├── 04-run-producer.ps1        # Sends test events (dedicated window)
│   ├── 05-monitor.ps1             # Monitors consumer group LAG (2s refresh)
│   ├── 99-stop-all.ps1            # Stops containers (optional: cleans volumes)
│   └── run-poc.ps1                # ⭐ End-to-end orchestrator (one command does it all)
│
├── 📁 Models/
│   └── OnboardingEvent.cs         # C# record representing an event
│
├── 📁 Producer/
│   └── OnboardingProducer.cs      # Producer with Acks.All and idempotence
│
├── 📁 Consumer/
│   ├── OnboardingConsumer.cs      # Consumer with manual commit + DLQ
│   └── DlqHandler.cs              # Dead Letter Queue handler
│
└── 📁 flink/
    ├── lib/
    │   └── flink-sql-connector-kafka-3.3.0-1.19.jar
    └── onboarding_queries.sql     # Flink SQL queries: windows and alerts
```

---

## 🔧 Prerequisites

| Tool                | Minimum version | How to verify                                |
|---------------------|-----------------|----------------------------------------------|
| **Docker Desktop**  | 4.x             | `docker --version`                           |
| **Docker Compose**  | v2              | `docker compose version`                     |
| **.NET SDK**        | 8.0+            | `dotnet --version`                           |
| **PowerShell**      | 5.1 or 7+       | `$PSVersionTable.PSVersion`                  |
| **Free ports**      | 8080, 8081, 9092 | `Test-NetConnection localhost -Port 9092`   |

> 💡 Recommended **PowerShell 7+ (pwsh)** — the orchestrator detects it automatically.

### 🔓 Allow script execution (1st time)

By default, Windows blocks `.ps1` scripts. Run **once**:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

Confirm with `Y`. This only enables local scripts for your user.

---

## ▶️ Quick Start (1 command)

> 💡 All commands below are executed in **PowerShell**.

### 1️⃣ Clone the repository

```powershell
git clone https://github.com/ntitsolutins01/kafka-onboarding-dotnet.git
Set-Location kafka-onboarding-dotnet\KafkaOnboarding
```

### 2️⃣ Run the end-to-end orchestrator 🚀

```powershell
.\scripts\run-poc.ps1
```

The script does **everything automatically in 5 steps**:

```text
[1/5] Spins up Docker infrastructure
      └─ waits for Kafka healthy + validates port 9092
[2/5] Creates/verifies topics (idempotent)
      ├─ onboarding-events       (3 partitions)
      └─ onboarding-events-dlq   (3 partitions)
[3/5] Opens CONSUMER window  → processes onboarding-events
      └─ waits 15s for subscribe + rebalance
[4/5] Opens MONITOR window   → real-time LAG (refresh 2s)
[5/5] Opens PRODUCER window  → sends test events
```

**Result:** 3 separate windows + Kafka UI + Flink UI running, ready for visual inspection.

```text
===========================================================
  KAFKA ONBOARDING - POC END-TO-END
  Complete orchestrator (shell: pwsh)
===========================================================

[OK] Kafka is healthy!
[OK] Port 9092 responding!
[OK] Infra ready!

   - onboarding-events       [CREATED] 3 partitions
   - onboarding-events-dlq   [CREATED] 3 partitions
[OK] Topics ready!

===========================================================
  POC RUNNING!
===========================================================
  Consumer  -> CONSUMER window
  Monitor   -> MONITOR window (real-time LAG)
  Producer  -> PRODUCER window (sending msgs)

  Kafka UI  -> http://localhost:8080
  Flink UI  -> http://localhost:8081
```

### 3️⃣ When you're done, tear everything down

```powershell
.\scripts\99-stop-all.ps1
```

The script asks whether you want to **preserve** or **delete** the volumes (Kafka data).

### 🌐 Access points

After `run-poc.ps1` finishes:

- 🖥️ **Kafka UI**: http://localhost:8080
- 🌊 **Flink Dashboard**: http://localhost:8081
- 🔌 **Kafka Broker**: `localhost:9092`

---

## 🧠 How it Works

### 1️⃣ The Producer

Sends customer onboarding events to the `onboarding-events` topic:

```csharp
var evt = new OnboardingEvent(
    CustomerId: "CUST-001",
    Name: "John Doe",
    Status: "PENDING",
    Timestamp: DateTime.UtcNow
);

await producer.ProduceAsync(evt);
// → goes to the partition based on hash(CustomerId)
```

**Main features:**
- ✅ `Acks.All` → waits for all replicas to confirm
- ✅ `EnableIdempotence = true` → avoids duplicates on retries
- ✅ Partitioning by `CustomerId` → guarantees ordering per customer

### 2️⃣ The Consumer

Reads events from `onboarding-events` and processes them:

```csharp
while (!ct.IsCancellationRequested)
{
    var result = consumer.Consume(ct);

    try
    {
        var evt = JsonSerializer.Deserialize<OnboardingEvent>(result.Message.Value);
        await ProcessAsync(evt);
        consumer.Commit(result);  // ✅ manual commit after success
    }
    catch (Exception ex)
    {
        await dlqHandler.SendAsync(result, ex);  // 🛡️ goes to DLQ
        consumer.Commit(result);  // avoids reprocessing the poison pill
    }
}
```

**Main features:**
- ✅ Consumer group: `onboarding-processor`
- ✅ Manual offset commit (fine-grained control)
- ✅ Automatic DLQ on failure
- ✅ Resilient to malformed messages

### 3️⃣ The DLQ (Dead Letter Queue)

Messages that fail processing go to `onboarding-events-dlq` with **error headers**:

```text
Headers:
  - exception-type: System.Text.Json.JsonException
  - exception-message: "The input is not valid JSON"
  - original-topic: onboarding-events
  - original-partition: 1
  - original-offset: 42
  - failed-at: 2026-05-24T22:00:00Z
```

This allows **reprocessing** messages after fixing the bug.

---

## 🎛️ Available Scripts

All scripts live in `.\scripts\` and are **idempotent** (can run multiple times without side effects).

| Script                       | Function                                          | Avg. time   |
|------------------------------|---------------------------------------------------|-------------|
| `01-start-infra.ps1`         | Spins up containers + validates Kafka health + port | ~30s      |
| `02-create-topics.ps1`       | Creates/verifies `onboarding-events` and DLQ      | ~3s         |
| `03-run-consumer.ps1`        | Starts .NET consumer                              | continuous  |
| `04-run-producer.ps1`        | Sends test events                                 | ~10–30s     |
| `05-monitor.ps1`             | Monitors consumer group LAG (2s refresh)          | continuous  |
| `99-stop-all.ps1`            | Stops containers (optional: cleans volumes)       | ~5s         |
| `run-poc.ps1`                | **End-to-end orchestrator**                       | ~60s        |

### 🔁 Manual execution (step-by-step mode)

Want to understand each step? Run them separately in different terminals:

```powershell
# Terminal 1 — Infra
.\scripts\01-start-infra.ps1
.\scripts\02-create-topics.ps1

# Terminal 2 — Consumer (leave it running)
.\scripts\03-run-consumer.ps1

# Terminal 3 — LAG Monitor (leave it running)
.\scripts\05-monitor.ps1

# Terminal 4 — Producer (trigger the test)
.\scripts\04-run-producer.ps1
```

### 🆘 Something went wrong?

If the environment becomes inconsistent (orphan containers, name conflicts, corrupted volume):

```powershell
.\scripts\99-stop-all.ps1   # answer "Y" to delete volumes
.\scripts\run-poc.ps1       # starts from scratch
```

This solves **99% of the problems** by returning to a clean state.

---

## 🧪 Automated End-to-End Tests

Want to validate that everything is working beautifully? I prepared **two complete test guides**:

### 🤖 [AUTOMATIC_TEST.md](./AUTOMATIC_TEST.md)
Automated E2E tests — ideal for **CI/CD**, **demos**, and **smoke tests**.
- ⏱️ **Time:** ~60 seconds
- 🎯 **Focus:** Does it work?

**What you'll find there:**

- ✅ Automated flow diagram in 5 steps
- ✅ Table with average time of each script
- ✅ Checkable success criteria checklist
- ✅ Expected validations in each window (Consumer / Monitor / Producer)
- ✅ Interpretation of **Consumer Lag** levels
- ✅ Troubleshooting for the most common errors (encoding, port in use, unhealthy container)
- ✅ Complete reset procedure (smoke test from scratch)
- ✅ Metrics and observability (where to see throughput, LAG, DLQ)

### 🧑‍🔬 [MANUAL_TEST.md](./MANUAL_TEST.md)
Step-by-step manual tests — ideal for **learning**, **debugging**, and **teaching**.
- ⏱️ **Time:** ~30–60 minutes
- 🎯 **Focus:** Why does it work?
- 🎓 Includes **4 extra didactic scenarios** (rebalance, ordering, resilience, replay)

### ⚡ Quick test in 1 command

```powershell
.\scripts\run-poc.ps1
```

Then observe:
- 🟢 **CONSUMER window** — messages being processed
- 🟡 **MONITOR window** — LAG zeroing in real time
- 🔵 **PRODUCER window** — events being sent
- 🌐 **Kafka UI** ([http://localhost:8080](http://localhost:8080)) — visual inspection

---

## 🌐 Dashboards and Tools

| Tool | URL | What it does |
|---|---|---|
| **Kafka UI** | http://localhost:8080 | Visualizes topics, partitions, messages, consumer groups |
| **Flink Dashboard** | http://localhost:8081 | Manages Flink jobs, sees metrics and flame graphs |

### 📊 Metrics and Observability

| Metric                  | Where to see                              |
|-------------------------|-------------------------------------------|
| **Consumer Lag**        | `.\scripts\05-monitor.ps1` or Kafka UI    |
| **Throughput (msg/s)**  | Kafka UI → Topic → Overview               |
| **Partition balance**   | Kafka UI → Topic → Partitions             |
| **Messages in DLQ**     | Kafka UI → `onboarding-events-dlq`        |
| **Flink Slots**         | http://localhost:8081 → Overview          |

### 🚦 Consumer Lag Interpretation

| Observed LAG       | Meaning                                |
|--------------------|----------------------------------------|
| `0`                | ✅ Consumer caught up — healthy         |
| `< 100`            | ✅ Normal processing                    |
| `100 — 1000`       | ⚠️ Investigate throughput               |
| `> 1000` growing   | 🔴 Consumer can't keep up               |

---

## 💡 Key Concepts Illustrated in the Code

This POC covers, in practice, the following **fundamental Kafka concepts**:

| Concept                          | Where to see it in the code                       |
|----------------------------------|---------------------------------------------------|
| 🎯 **Topics and Partitions**     | `02-create-topics.ps1` creates 3 partitions       |
| 🔑 **Partitioning by key**       | Producer uses `CustomerId` as key                 |
| 👥 **Consumer Groups**           | Group `onboarding-processor`                      |
| 💾 **Manual offset commit**      | `consumer.Commit()` after success                 |
| 🛡️ **Dead Letter Queue (DLQ)**   | Topic `onboarding-events-dlq` + error headers     |
| 📊 **Lag monitoring**            | `05-monitor.ps1` shows real-time LAG              |
| ⚡ **Idempotent Producer**       | `EnableIdempotence = true`                        |
| 🔄 **Replay from offset**        | `--reset-offsets --to-earliest` manual            |
| 🌐 **Multi-listener config**     | INTERNAL + EXTERNAL listeners                     |
| 🚦 **Acks and durability**       | `Acks.All` waits for all replicas                 |
| 🔁 **Rebalance**                 | See Scenario A in `MANUAL_TEST.md`                |
| 🔥 **Client resilience**         | Auto-reconnection after broker outage             |

### 🔑 Partitioning by Key

```csharp
// Events from the same customer always go to the same partition
// Guarantees per-customer ordering
var key = $"CUST-{customerId}";
```

### 🛡️ Guaranteed Durability in the Producer

```csharp
Acks = Acks.All,           // waits for confirmation from all brokers
EnableIdempotence = true   // guarantees exactly-once delivery
```

### 📍 Manual Offset Commit in the Consumer

```csharp
// Only commits the offset AFTER processing successfully
// Avoids message loss on failure
consumer.Commit(result);
```

### ☠️ Dead Letter Queue (DLQ)

```csharp
// Messages with deserialization or validation errors
// are redirected to onboarding-events-dlq
await producer.ProduceAsync("onboarding-events-dlq", failedMessage);
```

### 🔌 Internal vs External Listeners

```yaml
KAFKA_ADVERTISED_LISTENERS: INTERNAL://kafka:29092,EXTERNAL://localhost:9092
```

- **INTERNAL (`kafka:29092`)** → used by containers (Flink, Kafka UI)
- **EXTERNAL (`localhost:9092`)** → used by the .NET app running on the host

Without this separation, either the host can't connect or the containers can't connect. 🎯

### 🔄 Non-Destructive Reads

In Kafka, consuming a message **does not remove it** from the topic. Multiple consumers (or different groups) can read the same events independently. Messages only expire by the retention time configured on the topic (default: **7 days**).

---

## 📊 Stream Processing with Flink SQL

The `flink/onboarding_queries.sql` file contains examples of:

- ✅ Creating a table over a Kafka topic
- ✅ Time-window aggregation (tumbling/sliding windows)
- ✅ Filtering critical events (e.g., KYC failures)
- ✅ Sinking to a new summary topic

### How to submit a Flink job

```powershell
# Open the SQL Client inside the container
docker exec -it flink-jobmanager /opt/flink/bin/sql-client.sh

# Inside the prompt, paste/execute the queries from the file
```

### Query example

```sql
-- Create a table over the Kafka topic
CREATE TABLE onboarding_events (
    customerId STRING,
    name STRING,
    status STRING,
    event_time TIMESTAMP(3),
    WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
) WITH (
    'connector' = 'kafka',
    'topic' = 'onboarding-events',
    'properties.bootstrap.servers' = 'kafka:29092',
    'format' = 'json',
    'scan.startup.mode' = 'earliest-offset'
);

-- Count events by status in 1-minute windows
SELECT
    status,
    TUMBLE_START(event_time, INTERVAL '1' MINUTE) AS window_start,
    COUNT(*) AS event_count
FROM onboarding_events
GROUP BY status, TUMBLE(event_time, INTERVAL '1' MINUTE);
```

---

## ⚙️ Configuration

### 🐳 docker-compose.yml

Main services:

```yaml
services:
  kafka:
    image: apache/kafka:3.8.0
    ports:
      - "9092:9092"        # EXTERNAL (host)
    environment:
      KAFKA_ADVERTISED_LISTENERS: INTERNAL://kafka:29092,EXTERNAL://localhost:9092
      KAFKA_LISTENERS: INTERNAL://0.0.0.0:29092,EXTERNAL://0.0.0.0:9092
    healthcheck:
      test: ["CMD", "/opt/kafka/bin/kafka-topics.sh", "--bootstrap-server", "localhost:29092", "--list"]
      interval: 5s
      timeout: 10s
      retries: 10

  kafka-ui:
    image: provectuslabs/kafka-ui:latest
    ports:
      - "8080:8080"

  flink-jobmanager:
    image: flink:1.19-scala_2.12
    ports:
      - "8081:8081"

  flink-taskmanager:
    image: flink:1.19-scala_2.12
    depends_on:
      - flink-jobmanager
```

### 🔧 Producer Configuration

```csharp
var config = new ProducerConfig
{
    BootstrapServers = "localhost:9092",
    Acks = Acks.All,                    // wait for all replicas
    EnableIdempotence = true,           // avoid duplicates
    MessageSendMaxRetries = 3,          // retry up to 3 times
    CompressionType = CompressionType.Snappy
};
```

### 🔧 Consumer Configuration

```csharp
var config = new ConsumerConfig
{
    BootstrapServers = "localhost:9092",
    GroupId = "onboarding-processor",
    AutoOffsetReset = AutoOffsetReset.Earliest,
    EnableAutoCommit = false,           // manual commit
    SessionTimeoutMs = 30_000
};
```

---

## 🗺️ Study Roadmap

```text
✅ Phase 1 — Fundamentals
   ├── Events vs. Tables
   ├── Topics, Partitions, and Offsets
   ├── Brokers, Clusters, and KRaft
   └── Replication and Fault Tolerance

✅ Phase 2 — .NET Development
   ├── Producer with idempotence
   ├── Consumer with manual commit
   ├── Consumer Groups and scalability
   ├── Dead Letter Queue (DLQ)
   └── Internal vs external listeners

✅ Phase 3 — Automation and Observability
   ├── Idempotent PowerShell scripts
   ├── Container health-checks
   ├── Real-time LAG monitoring
   └── Automated E2E tests

✅ Phase 4 — Stream Processing
   ├── Flink JobManager + TaskManager
   ├── Flink SQL Client
   └── Time windows and aggregations

🚧 Phase 5 — In Progress
   ├── Submit Flink job consuming from Kafka
   ├── Schema Registry + Avro serialization
   ├── CI/CD with GitHub Actions
   └── Integration tests with TestContainers

🔮 Phase 6 — Planned
   ├── Multi-broker setup (3 brokers + replication-factor 3)
   ├── OAuth/TLS authentication
   ├── Prometheus + Grafana metrics
   ├── Distributed tracing with OpenTelemetry
   ├── Kafka Streams example in .NET
   ├── Producer/Consumer in Kotlin for comparison
   └── Kubernetes deployment (Strimzi)
```

---

## 🛠️ Troubleshooting

### ❌ `Failed to resolve 'kafka:9092'`

The .NET client is trying to resolve the `kafka` hostname, which only exists in the Docker network.

**Solution:** check that `KAFKA_ADVERTISED_LISTENERS` in `docker-compose.yml` has the `EXTERNAL://localhost:9092` listener. If you changed it recently:

```powershell
.\scripts\99-stop-all.ps1   # answer "Y"
.\scripts\run-poc.ps1
```

### ❌ `Conflict. The container name "/kafka" is already in use`

An orphan container from a previous project is blocking the restart.

**Solution:**

```powershell
.\scripts\99-stop-all.ps1   # answer "Y"
.\scripts\run-poc.ps1
```

Or manually:

```powershell
docker rm -f kafka kafka-ui flink-jobmanager flink-taskmanager
.\scripts\01-start-infra.ps1
```

### ❌ Kafka doesn't become `healthy`

Check the logs:

```powershell
docker logs kafka --tail 50
```

If there's a **corrupted metadata in the volume** error, perform a reset:

```powershell
.\scripts\99-stop-all.ps1   # answer "Y"
.\scripts\run-poc.ps1
```

### ❌ Port 9092 doesn't respond

Some other process is occupying the port.

```powershell
# Find out who is using the port
Get-NetTCPConnection -LocalPort 9092 | Select-Object OwningProcess
Get-Process -Id <PID>
```

### ❌ Weird characters in the terminal (`\`, `\"`, `²`)

PowerShell encoding is not UTF-8.

```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
```

### ❌ Consumer doesn't receive messages

The consumer started **after** the producer with `auto.offset.reset=latest`.

**Solution:** `run-poc.ps1` already handles this with `Start-Sleep 15` between starting the consumer and the producer. If running manually, make sure to follow this order:
1. Consumer first
2. Wait for rebalance (10–15s)
3. Producer afterward

### ❌ LAG growing continuously

```powershell
docker exec kafka /opt/kafka/bin/kafka-consumer-groups.sh `
    --bootstrap-server localhost:29092 `
    --group onboarding-processor `
    --describe
```

Check throughput in Kafka UI → Topics → onboarding-events → Messages.

> 📌 More detailed scenarios in [**AUTOMATIC_TEST.md**](./AUTOMATIC_TEST.md).

---

## ❓ FAQ

<details>
<summary><strong>🤔 Why Kafka 3.8 in KRaft mode (no Zookeeper)?</strong></summary>

Since Kafka 3.3+, KRaft mode is **production-ready** and **eliminates the Zookeeper dependency**.
This simplifies the architecture, reduces operational overhead, and is the **official future of Kafka**.
Zookeeper is deprecated and will be removed in Kafka 4.0.
</details>

<details>
<summary><strong>🤔 Why PowerShell instead of Bash?</strong></summary>

The project was developed on **Windows**, where PowerShell is native. With PowerShell 7+ being
**cross-platform** (Windows, Linux, macOS), the scripts also run on Unix systems. If you
prefer Bash, contributions with equivalent versions are welcome (see [CONTRIBUTING.md](./CONTRIBUTING.md)).
</details>

<details>
<summary><strong>🤔 Can I use this in production?</strong></summary>

**NO**. This is a **didactic POC** with simplified configurations:
- ❌ `replication-factor = 1` (no fault tolerance)
- ❌ No authentication/TLS
- ❌ No real monitoring (Prometheus, alerts)
- ❌ No backup/disaster recovery strategy

For production, see the [Roadmap](#️-study-roadmap) and adapt accordingly.
</details>

<details>
<summary><strong>🤔 Why .NET 8 and not 9?</strong></summary>

.NET 8 is an **LTS (Long-Term Support)** version, supported until **November 2026**.
.NET 9 is STS (Standard-Term Support) and expires faster. For didactic projects,
LTS offers more longevity.
</details>

<details>
<summary><strong>🤔 How do I add a new event type?</strong></summary>

1. Create a new record in `Models/`
2. Update the producer to send the new type
3. Update the consumer to handle the new type
4. Document it in this README (in [How it Works](#-how-it-works))
5. Add a test scenario in [MANUAL_TEST.md](./MANUAL_TEST.md)
</details>

<details>
<summary><strong>🤔 Can I use this with Confluent Cloud?</strong></summary>

Yes! Just change the `BootstrapServers` and add SASL credentials:

```csharp
var config = new ProducerConfig
{
    BootstrapServers = "your-cluster.confluent.cloud:9092",
    SecurityProtocol = SecurityProtocol.SaslSsl,
    SaslMechanism = SaslMechanism.Plain,
    SaslUsername = "YOUR_API_KEY",
    SaslPassword = "YOUR_API_SECRET"
};
```
</details>

<details>
<summary><strong>🤔 Where's the Flink job?</strong></summary>

The Flink job is on the [Roadmap](#️-study-roadmap) and hasn't been implemented yet.
Flink in this POC is **prepared** (JobManager + TaskManager running) but **doesn't execute jobs yet**.
This will be the **next major feature** of the project.
</details>

<details>
<summary><strong>🤔 Can I run this on Linux/macOS?</strong></summary>

Yes, with **PowerShell 7+** installed. Docker and the .NET SDK are cross-platform.
The `.ps1` scripts run normally via `pwsh` on Linux and macOS.

```bash
# Linux/macOS
pwsh ./scripts/run-poc.ps1
```
</details>

---

## 🤝 Contributing

Contributions are welcome! Feel free to:

1. **Fork** the repository
2. Create a branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m "feat: add Schema Registry example"`
4. Push: `git push origin feature/my-feature`
5. Open a **Pull Request** 🚀

### 📝 Standards for new scripts

When adding scripts to `.\scripts\`:

1. Follow the naming convention `NN-action-object.ps1`
2. Use **single quotes** in heredocs (`@'...'@`) to avoid escape bugs
3. Always write files with **UTF-8 BOM** via `[System.IO.File]::WriteAllText`
4. Document the scenario in [`AUTOMATIC_TEST.md`](./AUTOMATIC_TEST.md)

> 📖 See the full guide in [**CONTRIBUTING.md**](./CONTRIBUTING.md).

---

## 📚 References and Resources

| Resource                       | Link                                                                     |
|-------------------------------|--------------------------------------------------------------------------|
| Apache Kafka Documentation    | [kafka.apache.org](https://kafka.apache.org/documentation/)              |
| Confluent Developer           | [developer.confluent.io](https://developer.confluent.io/)                |
| Confluent Hub (Connectors)    | [confluent.io/hub](https://www.confluent.io/hub/)                        |
| Confluent.Kafka library (.NET)| [NuGet — Confluent.Kafka](https://www.nuget.org/packages/Confluent.Kafka) |
| Apache Flink SQL              | [flink.apache.org](https://flink.apache.org/)                            |
| Kafka UI (Provectus)          | [github.com/provectus/kafka-ui](https://github.com/provectus/kafka-ui)   |
| Confluent Cloud (Free Tier)   | [confluent.io/get-started](https://www.confluent.io/get-started/)        |

---

## 📜 License

Distributed under the **MIT** License. See the [`LICENSE`](./LICENSE) file for more details.

```text
MIT License

Copyright (c) 2026 Fábio Muniz

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

---

## 👤 Author

Made with 💙 and lots of ☕ by **Fábio Muniz**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=flat&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/fabiomunizdeveloper/)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white)](https://github.com/ntitsolutins01?tab=repositories)

---

## 🙏 Acknowledgments

- 🚀 [Confluent](https://www.confluent.io/) — for `Confluent.Kafka` and the great documentation
- 🐳 [Provectus](https://provectus.com/) — for the wonderful Kafka UI
- 📚 [Apache Kafka Community](https://kafka.apache.org/) — for the amazing platform
- ❤️ All [contributors](https://github.com/ntitsolutins01/kafka-onboarding-dotnet/graphs/contributors)

---

## 🔗 Related documents

- 🌐 [README.md](./README.md) — Portuguese version
- 🤖 [AUTOMATIC_TEST.md](./AUTOMATIC_TEST.md) — Automated tests guide
- 🧑‍🔬 [MANUAL_TEST.md](./MANUAL_TEST.md) — Manual didactic tests guide
- 🤝 [CONTRIBUTING.md](./CONTRIBUTING.md) — How to contribute
- 📜 [LICENSE](./LICENSE) — MIT License

---

## ⭐ Liked the project?

If this POC helped you in any way, consider:

- ⭐ Giving the GitHub repository a **star**
- 🐛 Reporting **bugs** via Issues
- 💡 Suggesting **improvements** via Discussions
- 🤝 **Contributing** with code or documentation
- 📢 **Sharing** it with friends and colleagues

---

## 📌 How to publish updates on GitHub (PowerShell)

```powershell
git add README.md README_EN.md AUTOMATIC_TEST.md MANUAL_TEST.md scripts/
git commit -m "docs: update README + add automated E2E guide"
git push origin main
```

---

**Project:** Kafka Onboarding .NET POC
**Version:** 1.0.0
**Last updated:** 05/24/2026
**Status:** ✅ Ready to use

---

> *"An event happens and you do the work right now. Not tomorrow, not in batch — now."*
> — **Tim Berglund**, Confluent

> *"The best way to learn a distributed system is to break it on purpose."*
> — **Fábio Muniz**
