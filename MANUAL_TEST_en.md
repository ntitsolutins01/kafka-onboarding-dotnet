# 🧑‍🔬 MANUAL_TEST — Kafka Onboarding POC

**Step-by-step manual testing guide** for the Kafka Onboarding .NET POC.
This document is the **didactic complement** to [`AUTOMATIC_TEST.md`](./AUTOMATIC_TEST.md):
here you execute **each piece of the pipeline manually** to understand how
Producer, Consumer, Kafka, and Flink connect.

![Kafka](https://img.shields.io/badge/Apache%20Kafka-3.8-231F20?style=for-the-badge&logo=apachekafka&logoColor=white)
![.NET](https://img.shields.io/badge/.NET-8.0-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-7+-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Manual Test](https://img.shields.io/badge/Tests-Manual_Didactic-orange?style=for-the-badge&logo=bookstack&logoColor=white)
![Status](https://img.shields.io/badge/Status-For_Learning-blueviolet?style=for-the-badge)

---

## 📑 Table of Contents

- [Who is this guide for?](#-who-is-this-guide-for)
- [Automatic vs. Manual](#-automatic-vs-manual-which-to-use)
- [Prerequisites](#-prerequisites)
- [Complete Roadmap](#-complete-manual-test-roadmap)
- [Step 1 — Start Infrastructure](#1️⃣-step-1--start-the-infrastructure)
- [Step 2 — Validate Kafka via CLI](#2️⃣-step-2--validate-kafka-via-cli)
- [Step 3 — Create Topics](#3️⃣-step-3--create-the-topics)
- [Step 4 — Inspect via Kafka UI](#4️⃣-step-4--inspect-via-kafka-ui)
- [Step 5 — Manual Producer via CLI](#5️⃣-step-5--manual-producer-via-cli)
- [Step 6 — Manual Consumer via CLI](#6️⃣-step-6--manual-consumer-via-cli)
- [Step 7 — Run .NET Consumer](#7️⃣-step-7--run-the-net-consumer)
- [Step 8 — Run .NET Producer](#8️⃣-step-8--run-the-net-producer)
- [Step 9 — Monitor Consumer Lag](#9️⃣-step-9--monitor-consumer-lag)
- [Step 10 — Test the DLQ](#-step-10--test-the-dlq-dead-letter-queue)
- [Step 11 — Validate Flink](#1️⃣1️⃣-step-11--validate-flink)
- [Step 12 — Clean Up](#1️⃣2️⃣-step-12--clean-up-the-environment)
- [Extra Didactic Scenarios](#-extra-didactic-scenarios)
- [Troubleshooting](#-troubleshooting)
- [Learning Checklist](#-learning-checklist)

---

## 🎯 Who is this guide for?

This document is ideal if you:

- 🎓 Are **learning Kafka** and want to understand every concept hands-on
- 🔍 Want to **manually inspect** messages, partitions, and offsets
- 🐛 Are **debugging** a specific scenario in isolation
- 👨‍🏫 Are **teaching Kafka** to someone and need a didactic script
- 🧪 Want to **test specific behaviors** (DLQ, rebalance, lag, etc.)

> 💡 If you just want to **run the POC quickly**, use [`AUTOMATIC_TEST.md`](./AUTOMATIC_TEST.md).

---

## ⚖️ Automatic vs. Manual: which to use?

| Characteristic            | 🤖 Automatic                     | 🧑‍🔬 Manual                          |
|---------------------------|----------------------------------|---------------------------------------|
| **Time**                  | ~60 seconds                      | ~30–60 minutes                        |
| **Learning depth**        | ⭐⭐                              | ⭐⭐⭐⭐⭐                              |
| **Detail inspection**     | Limited                          | Total                                 |
| **Ideal for**             | CI/CD, smoke test, demo          | Study, debug, teaching                |
| **Main command**          | `.\scripts\run-poc.ps1`          | Multiple step-by-step commands        |
| **Reference document**    | `AUTOMATIC_TEST.md`              | `MANUAL_TEST.md` (this one)           |

---

## ✅ Prerequisites

Same as `AUTOMATIC_TEST.md`:

| Tool                | Minimum version | Verify with                             |
|---------------------|-----------------|------------------------------------------|
| **Docker Desktop**  | 4.x             | `docker --version`                       |
| **Docker Compose**  | v2              | `docker compose version`                 |
| **.NET SDK**        | 8.0+            | `dotnet --version`                       |
| **PowerShell**      | 5.1 or 7+       | `$PSVersionTable.PSVersion`              |

### 🪟 Open MULTIPLE terminals

Unlike automatic mode, manual testing requires **several terminals open at the same time**:

```text
┌────────────────────────────────────────────────────────────┐
│  Terminal 1 — General commands (you're here)                │
├────────────────────────────────────────────────────────────┤
│  Terminal 2 — Console Producer (Kafka CLI)                  │
├────────────────────────────────────────────────────────────┤
│  Terminal 3 — Console Consumer (Kafka CLI)                  │
├────────────────────────────────────────────────────────────┤
│  Terminal 4 — .NET Consumer                                 │
├────────────────────────────────────────────────────────────┤
│  Terminal 5 — .NET Producer                                 │
├────────────────────────────────────────────────────────────┤
│  Terminal 6 — Lag Monitor                                   │
└────────────────────────────────────────────────────────────┘
```

> 💡 **Tip:** use **Windows Terminal** with tabs for better organization.

---

## 🗺️ Complete Manual Test Roadmap

```text
   ┌──────────────────────────────┐
   │ 1. Start infrastructure       │ docker compose up
   └────────────┬─────────────────┘
                │
   ┌────────────▼─────────────────┐
   │ 2. Validate Kafka via CLI     │ docker exec
   └────────────┬─────────────────┘
                │
   ┌────────────▼─────────────────┐
   │ 3. Create topics              │ kafka-topics.sh
   └────────────┬─────────────────┘
                │
   ┌────────────▼─────────────────┐
   │ 4. Inspect via Kafka UI       │ http://localhost:8080
   └────────────┬─────────────────┘
                │
   ┌────────────▼─────────────────┐
   │ 5. Manual producer (CLI)      │ kafka-console-producer
   └────────────┬─────────────────┘
                │
   ┌────────────▼─────────────────┐
   │ 6. Manual consumer (CLI)      │ kafka-console-consumer
   └────────────┬─────────────────┘
                │
   ┌────────────▼─────────────────┐
   │ 7. Run .NET consumer          │ dotnet run
   └────────────┬─────────────────┘
                │
   ┌────────────▼─────────────────┐
   │ 8. Run .NET producer          │ dotnet run
   └────────────┬─────────────────┘
                │
   ┌────────────▼─────────────────┐
   │ 9. Monitor consumer lag       │ kafka-consumer-groups.sh
   └────────────┬─────────────────┘
                │
   ┌────────────▼─────────────────┐
   │ 10. Test DLQ                  │ send invalid message
   └────────────┬─────────────────┘
                │
   ┌────────────▼─────────────────┐
   │ 11. Validate Flink            │ http://localhost:8081
   └────────────┬─────────────────┘
                │
   ┌────────────▼─────────────────┐
   │ 12. Clean up                  │ docker compose down -v
   └──────────────────────────────┘
```

---

## 1️⃣ Step 1 — Start the infrastructure

### 🎯 Goal
Start Kafka, Kafka UI, and Flink **without** the automatic script.

### 📋 Commands

```powershell
# Navigate to the project root
cd C:\Projects\POCs\kafka-onboarding-dotnet\KafkaOnboarding

# Start containers in background
docker compose up -d

# Follow logs in real-time (Ctrl+C to exit without stopping containers)
docker compose logs -f kafka
```

### ✔️ Validation

```powershell
# List containers — all should be "Up" and Kafka "(healthy)"
docker ps

# Expected output:
# CONTAINER ID   IMAGE                            STATUS                   PORTS
# abc123         apache/kafka:3.8.0               Up 30s (healthy)         0.0.0.0:9092->9092/tcp
# def456         provectuslabs/kafka-ui:latest    Up 30s                   0.0.0.0:8080->8080/tcp
# ghi789         flink:1.19-scala_2.12            Up 30s                   0.0.0.0:8081->8081/tcp
# jkl012         flink:1.19-scala_2.12            Up 30s
```

### 🧠 What to learn here

- 🔍 **Health-check in action**: Kafka only becomes "healthy" after full initialization
- 🔌 **Port mapping**: `9092` (host) → `9092` (container) for external clients
- 🌐 **Docker network**: containers talk by name (`kafka:29092`), host uses `localhost:9092`

---

## 2️⃣ Step 2 — Validate Kafka via CLI

### 🎯 Goal
Confirm the broker is responding by running commands **inside the container**.

### 📋 Commands

```powershell
# Enter the Kafka container (interactive shell)
docker exec -it kafka bash

# Inside the container, check Kafka version
/opt/kafka/bin/kafka-topics.sh --version

# List topics (should be empty on first run)
/opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:29092 --list

# Exit the container
exit
```

### ✔️ Validation

Expected output from `--list`:
```
__consumer_offsets   (may or may not appear — it's internal)
```

### 🧠 What to learn here

- 🐳 **`docker exec`** lets you run commands inside running containers
- 🔌 **`localhost:29092`** inside the container = INTERNAL listener
- 📋 **`__consumer_offsets`** is the internal topic where Kafka stores consumer offsets

---

## 3️⃣ Step 3 — Create the topics

### 🎯 Goal
Manually create the `onboarding-events` and `onboarding-events-dlq` topics with 3 partitions.

### 📋 Commands

```powershell
# Create main topic
docker exec kafka /opt/kafka/bin/kafka-topics.sh `
    --bootstrap-server localhost:29092 `
    --create `
    --topic onboarding-events `
    --partitions 3 `
    --replication-factor 1

# Create DLQ (Dead Letter Queue) topic
docker exec kafka /opt/kafka/bin/kafka-topics.sh `
    --bootstrap-server localhost:29092 `
    --create `
    --topic onboarding-events-dlq `
    --partitions 3 `
    --replication-factor 1
```

### ✔️ Validation

```powershell
# List all topics
docker exec kafka /opt/kafka/bin/kafka-topics.sh `
    --bootstrap-server localhost:29092 `
    --list

# Describe the topic in detail
docker exec kafka /opt/kafka/bin/kafka-topics.sh `
    --bootstrap-server localhost:29092 `
    --describe `
    --topic onboarding-events
```

Expected `--describe` output:
```
Topic: onboarding-events   PartitionCount: 3   ReplicationFactor: 1
    Topic: onboarding-events   Partition: 0   Leader: 1   Replicas: 1   Isr: 1
    Topic: onboarding-events   Partition: 1   Leader: 1   Replicas: 1   Isr: 1
    Topic: onboarding-events   Partition: 2   Leader: 1   Replicas: 1   Isr: 1
```

### 🧠 What to learn here

- 🔢 **Partitions** define the maximum consumption parallelism
- 📋 **Replication factor = 1** = no fault tolerance (POC only!)
- 👑 **Leader** = broker responsible for writes/reads for that partition
- 🔄 **ISR (In-Sync Replicas)** = replicas in sync with the leader

---

## 4️⃣ Step 4 — Inspect via Kafka UI

### 🎯 Goal
Visualize the infrastructure through a graphical interface.

### 📋 Steps

1. Open your browser at **http://localhost:8080**
2. Navigate to **Brokers** → confirm 1 broker exists (ID = 1, or similar)
3. Go to **Topics** → check that `onboarding-events` and `onboarding-events-dlq` are listed
4. Click `onboarding-events` → **Partitions** tab → confirm 3 partitions

### ✔️ Visual validation

- [ ] 1 broker UP with green status
- [ ] 2 topics listed
- [ ] Each topic with 3 partitions
- [ ] Each partition with offset = 0 (no messages yet)

### 🧠 What to learn here

- 🖥️ **Kafka UI** is a graphical alternative to the CLI — makes visualization easier
- 📊 **Real-time metrics** can be monitored from the interface
- 🎯 Great for **demos** and **onboarding** new devs to the team

---

## 5️⃣ Step 5 — Manual producer via CLI

### 🎯 Goal
Send messages manually to Kafka using the native CLI, without any .NET code.

### 📋 Commands

**Terminal 2:**

```powershell
# Start interactive producer
docker exec -it kafka /opt/kafka/bin/kafka-console-producer.sh `
    --bootstrap-server localhost:29092 `
    --topic onboarding-events `
    --property "parse.key=true" `
    --property "key.separator=:"
```

The console waits for input. Type messages in `key:value` format:

```
CUST-001:{"customerId":"001","status":"PENDING","timestamp":"2026-05-24T22:00:00Z"}
CUST-002:{"customerId":"002","status":"APPROVED","timestamp":"2026-05-24T22:01:00Z"}
CUST-003:{"customerId":"003","status":"REJECTED","timestamp":"2026-05-24T22:02:00Z"}
```

Press **Ctrl+C** to exit when done.

### ✔️ Validation

Go to Kafka UI → `onboarding-events` → **Messages** → see the 3 messages you sent.

### 🧠 What to learn here

- 📨 **Kafka messages** have `key`, `value`, `timestamp`, and `headers`
- 🎯 **Key determines the partition** via hash (key → partition)
- 🔄 Same key **always** goes to the same partition (guarantees per-key ordering)

---

## 6️⃣ Step 6 — Manual consumer via CLI

### 🎯 Goal
Read messages manually from Kafka using the native CLI.

### 📋 Commands

**Terminal 3:**

```powershell
# Consume from the beginning (all existing messages)
docker exec -it kafka /opt/kafka/bin/kafka-console-consumer.sh `
    --bootstrap-server localhost:29092 `
    --topic onboarding-events `
    --from-beginning `
    --property "print.key=true" `
    --property "key.separator= | "
```

### ✔️ Validation

You'll see messages sent in the previous step:
```
CUST-001 | {"customerId":"001","status":"PENDING",...}
CUST-002 | {"customerId":"002","status":"APPROVED",...}
CUST-003 | {"customerId":"003","status":"REJECTED",...}
```

### 🧪 Experiment

1. **Keep the consumer running**
2. Go back to Terminal 2 (producer) and send **more messages**
3. Watch the consumer receive them in real-time ⚡

### 🧠 What to learn here

- 📥 **`--from-beginning`** reads from offset 0 (all historical messages)
- 🔄 Without this flag, the consumer only reads **new** messages (auto.offset.reset=latest)
- 👥 Without `--group`, each consumer receives **all** messages (broadcast)

---

## 7️⃣ Step 7 — Run the .NET consumer

### 🎯 Goal
Replace the CLI consumer with the .NET consumer from this project.

### 📋 Commands

**Terminal 4:**

```powershell
# Stop the CLI consumer from the previous step (Ctrl+C)

# Navigate to the consumer project
cd C:\Projects\POCs\kafka-onboarding-dotnet\KafkaOnboarding\src\KafkaOnboarding.Consumer

# Run the consumer
dotnet run
```

### ✔️ Validation

Expected output:
```
CONSUMER - Processing onboarding-events
[INFO] Connected to broker localhost:9092
[INFO] Subscribed to topic onboarding-events
[INFO] Consumer group: onboarding-processor
[INFO] Waiting for messages...
```

### 🧠 What to learn here

- 👥 **Consumer group** (`onboarding-processor`) enables **parallelism** between instances
- 💾 **Offset commit** is manual (controlled by code)
- 🔄 If you kill the consumer and restart it, it **resumes from the last committed offset**

---

## 8️⃣ Step 8 — Run the .NET producer

### 🎯 Goal
Send messages via the .NET application while watching the consumer process them.

### 📋 Commands

**Terminal 5:**

```powershell
# Navigate to the producer project
cd C:\Projects\POCs\kafka-onboarding-dotnet\KafkaOnboarding\src\KafkaOnboarding.Producer

# Run the producer
dotnet run
```

### ✔️ Validation

**Terminal 5 (Producer):**
```
PRODUCER - Sending events
[OK] Sent: customer-001 -> partition 0, offset 4
[OK] Sent: customer-002 -> partition 2, offset 3
[OK] Sent: customer-003 -> partition 1, offset 3
...
```

**Terminal 4 (Consumer) — in real-time:**
```
[partition 0] Received: customer-001
[partition 2] Received: customer-002
[partition 1] Received: customer-003
...
```

### 🧠 What to learn here

- 🚀 **.NET Producer and Consumer** use the `Confluent.Kafka` package
- 🎯 **Partitioning by key**: different customers go to different partitions
- ⚡ **Acks.All + Idempotence** guarantee exactly-once delivery

---

## 9️⃣ Step 9 — Monitor consumer lag

### 🎯 Goal
Watch in real-time how "behind" the consumer is compared to the producer.

### 📋 Commands

**Terminal 6:**

```powershell
# Describe the consumer group (single snapshot)
docker exec kafka /opt/kafka/bin/kafka-consumer-groups.sh `
    --bootstrap-server localhost:29092 `
    --group onboarding-processor `
    --describe

# Monitor mode (refresh every 2 seconds)
while ($true) {
    Clear-Host
    docker exec kafka /opt/kafka/bin/kafka-consumer-groups.sh `
        --bootstrap-server localhost:29092 `
        --group onboarding-processor `
        --describe
    Start-Sleep 2
}
```

### ✔️ Validation

Expected output:
```
GROUP                  TOPIC               PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG
onboarding-processor   onboarding-events   0          15              15              0
onboarding-processor   onboarding-events   1          12              12              0
onboarding-processor   onboarding-events   2          18              18              0
```

### 🧪 Lag experiment

1. **Stop the .NET consumer** (Terminal 4 — Ctrl+C)
2. **Send more messages** via the producer (Terminal 5)
3. Watch **LAG growing** on Terminal 6
4. **Restart the consumer** → see LAG drop to 0 as it catches up

### 🧠 What to learn here

- 📊 **LAG = LOG-END-OFFSET − CURRENT-OFFSET**
- 🔴 **Growing LAG** = consumer can't keep up with the producer
- ✅ **Stable LAG near 0** = healthy system
- 🎯 It's the **most important** metric to monitor in production

---

## 🔟 Step 10 — Test the DLQ (Dead Letter Queue)

### 🎯 Goal
Validate that malformed messages go to the DLQ topic instead of blocking the consumer.

### 📋 Commands

**Terminal 2:**

```powershell
# Send a message with invalid JSON
docker exec -it kafka /opt/kafka/bin/kafka-console-producer.sh `
    --bootstrap-server localhost:29092 `
    --topic onboarding-events `
    --property "parse.key=true" `
    --property "key.separator=:"
```

Type:
```
CUST-BAD:{this is not valid JSON}
```

### ✔️ Validation

**Terminal 4 (.NET Consumer):**
```
[ERROR] Failed to process message customer-key: CUST-BAD
[INFO] Forwarding to DLQ: onboarding-events-dlq
[OK] Message forwarded to DLQ successfully
```

**Check DLQ contents:**
```powershell
docker exec -it kafka /opt/kafka/bin/kafka-console-consumer.sh `
    --bootstrap-server localhost:29092 `
    --topic onboarding-events-dlq `
    --from-beginning `
    --property "print.key=true" `
    --property "print.headers=true"
```

You'll see the invalid message there, with **error headers** indicating the failure reason.

### 🧠 What to learn here

- 🛡️ **DLQ is a fundamental pattern** in event-driven architectures
- 🚫 **Without a DLQ**, a bad message **blocks the consumer** (poison pill)
- 📋 **Error headers** help with later debugging (exception, stack trace, timestamp)
- 🔄 **Messages in DLQ** can be **reprocessed** after fixes

---

## 1️⃣1️⃣ Step 11 — Validate Flink

### 🎯 Goal
Confirm that Flink JobManager and TaskManager are active and ready.

### 📋 Steps

1. Open **http://localhost:8081** in your browser
2. Check the **Overview**:
   - ✅ Taskmanagers: 1
   - ✅ Total Task Slots: 1 (or more)
   - ✅ Available Task Slots: ≥ 1
   - ✅ Running Jobs: 0 (we haven't submitted any yet)

### ✔️ Validation via API

```powershell
# Flink cluster status
curl http://localhost:8081/overview

# List of TaskManagers
curl http://localhost:8081/taskmanagers
```

### 🧠 What to learn here

- 🌊 **Flink** is a stream processor that **consumes from Kafka**
- 🎯 **JobManager** = coordinator (receives jobs, distributes tasks)
- ⚙️ **TaskManager** = worker (executes tasks in parallel)
- 🧩 **Task Slots** = available units of parallelism

> 📌 This POC **does not yet submit Flink jobs** — it's a roadmap item.

---

## 1️⃣2️⃣ Step 12 — Clean up the environment

### 🎯 Goal
Stop everything and (optionally) clean data to start fresh.

### 📋 Commands

```powershell
# Stop all .NET processes (Terminals 4 and 5 — Ctrl+C)

# Stop containers, preserving volumes
docker compose down

# OR stop and delete all data
docker compose down -v
```

### ✔️ Validation

```powershell
# Confirm no project containers are running
docker ps --filter "name=kafka"
docker ps --filter "name=flink"

# Expected output: no results
```

### 🧠 What to learn here

- 💾 **`down` without `-v`** preserves volumes → messages persist after restart
- 🗑️ **`down -v`** deletes EVERYTHING → full reset (use when in doubt)
- 🧹 Good practice to **always clean up** after local tests to free resources

---

## 🎓 Extra Didactic Scenarios

### 🔄 Scenario A — Partition rebalance

**Goal:** observe what happens when a new consumer instance joins the group.

```powershell
# Terminal 4: run 1 consumer instance
cd .\src\KafkaOnboarding.Consumer
dotnet run

# Terminal 7: run a SECOND instance
cd .\src\KafkaOnboarding.Consumer
dotnet run

# Terminal 5: fire the producer
cd .\src\KafkaOnboarding.Producer
dotnet run
```

**What to observe:**
- 🔄 **Rebalance** logs when the 2nd instance joins
- 🎯 Partitions are **redistributed** between the 2 instances
- ⚡ Throughput **doubles** (real parallelism)

### 🎯 Scenario B — Ordering by key

**Goal:** prove that messages with the **same key** always go to the **same partition**.

```powershell
# Send 5 messages with the same key
docker exec -it kafka /opt/kafka/bin/kafka-console-producer.sh `
    --bootstrap-server localhost:29092 `
    --topic onboarding-events `
    --property "parse.key=true" `
    --property "key.separator=:"
```

Type (same key 5x):
```
CUST-999:{"event":"step1"}
CUST-999:{"event":"step2"}
CUST-999:{"event":"step3"}
CUST-999:{"event":"step4"}
CUST-999:{"event":"step5"}
```

**What to observe:** in Kafka UI, all 5 messages land on the **same partition** → ordering preserved for that key.

### 🔥 Scenario C — Resilience (kill broker)

**Goal:** see what happens when the broker goes down during processing.

```powershell
# Kill the Kafka container
docker stop kafka

# Watch the .NET consumer try to reconnect
# (error logs in Terminal 4)

# Start the broker again
docker start kafka

# Watch the consumer reconnect automatically
```

**What to learn:** Kafka clients have **automatic retry** and **transparent reconnection**.

### 📈 Scenario D — Message replay

**Goal:** reprocess all historical messages from the topic.

```powershell
# Reset consumer group offset to the beginning
docker exec kafka /opt/kafka/bin/kafka-consumer-groups.sh `
    --bootstrap-server localhost:29092 `
    --group onboarding-processor `
    --topic onboarding-events `
    --reset-offsets `
    --to-earliest `
    --execute

# Restart the .NET consumer
cd .\src\KafkaOnboarding.Consumer
dotnet run
```

**What to learn:** Kafka **retains messages** for a configurable time (default: 7 days) — you can "rewind time."

---

## 🔍 Troubleshooting

### ❌ "Connection refused" when trying .NET producer/consumer

**Cause:** Kafka isn't fully ready yet (health-check pending).

**Fix:**
```powershell
# Wait for the health-check
docker inspect -f '{{.State.Health.Status}}' kafka
# Wait until it returns "healthy"
```

### ❌ `docker exec` fails with "container not running"

**Cause:** Kafka container is not active.

**Fix:**
```powershell
docker ps -a | Select-String kafka
docker start kafka
docker logs kafka --tail 50
```

### ❌ Kafka UI shows "Cluster offline"

**Cause:** Kafka UI started **before** Kafka was ready.

**Fix:**
```powershell
docker restart kafka-ui
```

### ❌ Messages sent but consumer doesn't receive them

**Cause:** consumer with `auto.offset.reset=latest` and messages sent **before** it started.

**Fix:**
```powershell
# Reset offset to the beginning
docker exec kafka /opt/kafka/bin/kafka-consumer-groups.sh `
    --bootstrap-server localhost:29092 `
    --group onboarding-processor `
    --topic onboarding-events `
    --reset-offsets --to-earliest --execute
```

### ❌ `dotnet run` fails with "could not find project"

**Cause:** you're not in the right folder.

**Fix:**
```powershell
cd C:\Projects\POCs\kafka-onboarding-dotnet\KafkaOnboarding\src\KafkaOnboarding.Consumer
Get-ChildItem *.csproj   # confirm the csproj is here
dotnet run
```

> 📌 **More errors?** See the [Troubleshooting section in AUTOMATIC_TEST.md](./AUTOMATIC_TEST.md#-troubleshooting).

---

## ✅ Learning Checklist

Check as you progress:

### 🏗️ Infrastructure
- [ ] Understood the difference between INTERNAL and EXTERNAL listeners
- [ ] Can inspect containers with `docker exec`
- [ ] Can manually start/stop the infra

### 📨 Producer/Consumer
- [ ] Sent messages via CLI (`kafka-console-producer`)
- [ ] Consumed messages via CLI (`kafka-console-consumer`)
- [ ] Ran the .NET producer successfully
- [ ] Ran the .NET consumer successfully
- [ ] Understood the role of the **key** in partitioning

### 📊 Observability
- [ ] Navigated Kafka UI (Brokers, Topics, Messages)
- [ ] Monitored LAG via CLI
- [ ] Can interpret `kafka-consumer-groups.sh` output

### 🛡️ Resilience
- [ ] Tested the DLQ by sending an invalid message
- [ ] Watched the consumer reconnect after broker kill
- [ ] Replayed messages by resetting offsets

### 🎓 Advanced Concepts
- [ ] Observed rebalance when starting a 2nd consumer instance
- [ ] Validated that the key determines the partition (ordering)
- [ ] Understood the relationship between Flink JM and TM (even without submitted jobs)

---

## 📌 Important Notes

- ⚠️ This POC uses **replication-factor = 1** → **NEVER** in production
- 🔒 No **authentication/TLS** configured — localhost only
- 🎓 The manual test takes **3x longer** than automatic, but teaches **10x more**
- 💡 Combine manual testing + source code reading for maximum learning
- 📚 After mastering this guide, read the [official Kafka documentation](https://kafka.apache.org/documentation/)

---

## 🔗 Related Documents

- 📖 [README.md](./README.md) — Project overview
- 🤖 [AUTOMATIC_TEST.md](./AUTOMATIC_TEST.md) — Automated version of this test
- 🤝 [CONTRIBUTING.md](./CONTRIBUTING.md) — How to contribute
- 📜 [LICENSE](./LICENSE) — MIT License

---

## 🆘 Need help?

- 💬 Open a [Discussion](https://github.com/ntitsolutins01/kafka-onboarding-dotnet/discussions) on GitHub
- 🐛 Open an [Issue](https://github.com/ntitsolutins01/kafka-onboarding-dotnet/issues) for bugs
- 📧 Reach out via [LinkedIn](https://www.linkedin.com/in/fabiomunizdeveloper/)

---

**Project:** Kafka Onboarding .NET POC
**Last update:** 2026-05-24
**Maintainer:** Fábio Muniz

---

> *"Tell me and I'll forget. Show me and I may remember. Involve me and I will understand."*
> — **Confucius**
