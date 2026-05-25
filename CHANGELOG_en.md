# 📋 Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

### 🚧 In progress
- Automatic Flink job submission consuming Kafka
- Schema Registry + Avro integration
- Integration tests with TestContainers
- CI/CD pipeline with GitHub Actions

---

## [1.0.0] - 2026-05-24

### ✨ Added
- 🚀 Full infrastructure via Docker Compose (Kafka 3.8 KRaft + Flink 1.19 + Kafka UI)
- 📦 .NET 8 Producer with `Acks.All` and idempotence enabled
- 📥 .NET 8 Consumer with manual offset commit and Dead Letter Queue
- 🤖 Idempotent PowerShell scripts suite:
  - `01-start-infra.ps1` — spins containers with health check
  - `02-create-topics.ps1` — creates topics `onboarding-events` and `onboarding-events-dlq`
  - `03-run-consumer.ps1` — starts consumer in dedicated window
  - `04-run-producer.ps1` — sends test events
  - `05-monitor.ps1` — real-time LAG monitor (2s refresh)
  - `99-stop-all.ps1` — stops containers with optional volume cleanup
  - `run-poc.ps1` — end-to-end orchestrator (5 automatic steps)
- 🌐 INTERNAL/EXTERNAL listeners configuration for Kafka
- 📊 Sample Flink SQL queries in `flink/onboarding_queries.sql`
- 📚 Complete documentation: `README.md`, `README_EN.md`, `AUTOMATIC_TEST.md`, `MANUAL_TEST.md`, `CONTRIBUTING.md`
- 📜 MIT License

### 🔧 Configuration
- Topics created with 3 partitions by default
- Replication factor = 1 (didactic)
- Consumer group: `onboarding-processor`
- DLQ with error headers (`exception-type`, `original-topic`, `original-offset`, `failed-at`)

### 🛡️ Security
- No authentication (didactic POC — **do not use in production**)

---

## [0.2.0] - 2026-05-15

### ✨ Added
- Initial Apache Flink integration (JobManager + TaskManager)
- Connector `flink-sql-connector-kafka-3.3.0-1.19.jar`
- Flink Dashboard at http://localhost:8081

### 🔄 Changed
- Migration from Zookeeper to KRaft mode
- Kafka upgrade 3.5 → 3.8

---

## [0.1.0] - 2026-05-01

### ✨ Added
- Initial project version
- Basic .NET Producer and Consumer
- Docker Compose with Kafka + Zookeeper
- Initial README in Portuguese

---

## 📖 Types of changes

- `✨ Added` — for new features
- `🔄 Changed` — for changes in existing functionality
- `🗑️ Removed` — for removed features
- `🐛 Fixed` — for bug fixes
- `🛡️ Security` — for vulnerability fixes
- `📚 Documentation` — for documentation-only changes
- `🚧 In progress` — for features in development

---

[Unreleased]: https://github.com/ntitsolutins01/kafka-onboarding-dotnet/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/ntitsolutins01/kafka-onboarding-dotnet/releases/tag/v1.0.0
[0.2.0]: https://github.com/ntitsolutins01/kafka-onboarding-dotnet/releases/tag/v0.2.0
[0.1.0]: https://github.com/ntitsolutins01/kafka-onboarding-dotnet/releases/tag/v0.1.0
