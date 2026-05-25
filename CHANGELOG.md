# 📋 Changelog

Todas as mudanças notáveis deste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
e este projeto adere ao [Versionamento Semântico](https://semver.org/lang/pt-BR/).

---

## [Não lançado]

### 🚧 Em desenvolvimento
- Submissão automática de job Flink consumindo Kafka
- Integração com Schema Registry + Avro
- Testes de integração com TestContainers
- Pipeline CI/CD com GitHub Actions

---

## [1.0.0] - 2026-05-24

### ✨ Adicionado
- 🚀 Infraestrutura completa via Docker Compose (Kafka 3.8 KRaft + Flink 1.19 + Kafka UI)
- 📦 Producer .NET 8 com `Acks.All` e idempotência habilitada
- 📥 Consumer .NET 8 com commit manual de offset e Dead Letter Queue
- 🤖 Suíte de scripts PowerShell idempotentes:
  - `01-start-infra.ps1` — sobe containers com health check
  - `02-create-topics.ps1` — cria tópicos `onboarding-events` e `onboarding-events-dlq`
  - `03-run-consumer.ps1` — inicia consumer em janela dedicada
  - `04-run-producer.ps1` — envia eventos de teste
  - `05-monitor.ps1` — monitora LAG em tempo real (refresh 2s)
  - `99-stop-all.ps1` — encerra containers com opção de limpar volumes
  - `run-poc.ps1` — orquestrador end-to-end (5 etapas automáticas)
- 🌐 Configuração de listeners INTERNAL/EXTERNAL para Kafka
- 📊 Queries Flink SQL de exemplo em `flink/onboarding_queries.sql`
- 📚 Documentação completa: `README.md`, `README_EN.md`, `AUTOMATIC_TEST.md`, `MANUAL_TEST.md`, `CONTRIBUTING.md`
- 📜 Licença MIT

### 🔧 Configurações
- Tópicos criados com 3 partições por padrão
- Replication factor = 1 (didático)
- Consumer group: `onboarding-processor`
- DLQ com headers de erro (`exception-type`, `original-topic`, `original-offset`, `failed-at`)

### 🛡️ Segurança
- Sem autenticação (POC didática — **não usar em produção**)

---

## [0.2.0] - 2026-05-15

### ✨ Adicionado
- Integração inicial com Apache Flink (JobManager + TaskManager)
- Conector `flink-sql-connector-kafka-3.3.0-1.19.jar`
- Dashboard Flink em http://localhost:8081

### 🔄 Alterado
- Migração de Zookeeper para KRaft mode
- Atualização do Kafka 3.5 → 3.8

---

## [0.1.0] - 2026-05-01

### ✨ Adicionado
- Versão inicial do projeto
- Producer e Consumer .NET básicos
- Docker Compose com Kafka + Zookeeper
- README inicial em português

---

## 📖 Tipos de mudanças

- `✨ Adicionado` — para novas funcionalidades
- `🔄 Alterado` — para mudanças em funcionalidades existentes
- `🗑️ Removido` — para funcionalidades removidas
- `🐛 Corrigido` — para correções de bugs
- `🛡️ Segurança` — para vulnerabilidades corrigidas
- `📚 Documentação` — para mudanças apenas na documentação
- `🚧 Em desenvolvimento` — para features em progresso

---

[Não lançado]: https://github.com/ntitsolutins01/kafka-onboarding-dotnet/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/ntitsolutins01/kafka-onboarding-dotnet/releases/tag/v1.0.0
[0.2.0]: https://github.com/ntitsolutins01/kafka-onboarding-dotnet/releases/tag/v0.2.0
[0.1.0]: https://github.com/ntitsolutins01/kafka-onboarding-dotnet/releases/tag/v0.1.0
