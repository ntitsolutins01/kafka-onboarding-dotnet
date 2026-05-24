# 🚀 Apache Kafka Onboarding — .NET (C#)

> Onboarding prático e objetivo para desenvolvedores .NET que querem dominar
> Apache Kafka do zero: desde a teoria de eventos até stream processing com Flink SQL.

![Kafka](https://img.shields.io/badge/Apache%20Kafka-3.7+-231F20?style=for-the-badge&logo=apachekafka&logoColor=white)
![.NET](https://img.shields.io/badge/.NET-8.0-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Flink](https://img.shields.io/badge/Apache%20Flink-SQL-E6526F?style=for-the-badge&logo=apacheflink&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

---

## 📌 Sobre o Projeto

Este repositório é um **guia de onboarding completo** para Apache Kafka utilizando **.NET 8 (C#)** como linguagem principal. O projeto foi construído com base no curso oficial da Confluent *"Getting Started with Apache Kafka® and Real-Time Data Streaming"* e traduz cada conceito teórico em código funcional, pronto para rodar localmente em minutos.

A proposta é simples: **aprender fazendo**. Cada arquivo deste repositório representa um conceito real do ecossistema Kafka — sem abstrações desnecessárias, sem boilerplate excessivo, com foco total em clareza e aplicabilidade.

---

## 🎯 O que você vai aprender

| Conceito                | Descrição                                                       |
|-------------------------|-----------------------------------------------------------------|
| **Tópicos e Partições** | Como o Kafka organiza e distribui eventos em logs imutáveis     |
| **Brokers e Clusters**  | A infraestrutura distribuída que sustenta o Kafka               |
| **Replicação**          | Tolerância a falhas com líderes e seguidores                    |
| **KRaft**               | Modo moderno sem Zookeeper (Apache Kafka 4.0+)                  |
| **Producer .NET**       | Publicar eventos com idempotência e durabilidade garantida      |
| **Consumer .NET**       | Consumir eventos com commit manual de offset e consumer groups  |
| **Schema Registry**     | Governança de esquemas com Avro, JSON Schema e Protobuf         |
| **Kafka Connect**       | Integração com sistemas externos sem escrever código            |
| **Flink SQL**           | Stream processing com janelas de tempo e alertas em tempo real  |

---

## 🏗️ Arquitetura do Projeto

```text
                ┌─────────────────────────────────────────┐
                │           Apache Kafka Cluster          │
                │                                         │
                │  ┌─────────┐  ┌─────────┐  ┌─────────┐  │
                │  │ Broker 1│  │ Broker 2│  │ Broker 3│  │
                │  └────┬────┘  └────┬────┘  └────┬────┘  │
                │       │            │            │       │
                │  ┌────▼────────────▼────────────▼─────┐ │
                │  │     Topic: thermostat-readings     │ │
                │  │  Partition 0 | Partition 1 | P2    │ │
                │  └────────────────────────────────────┘ │
                └────────────┬──────────────┬─────────────┘
                             │              │
                ┌────────────▼──┐    ┌──────▼──────────────┐
                │ .NET Producer │    │    .NET Consumer    │
                │   (C# App)    │    │   (Consumer Group)  │
                └───────────────┘    └─────────────────────┘
                                              │
                                  ┌───────────▼──────────┐
                                  │   Apache Flink SQL   │
                                  │  (Stream Processing) │
                                  └──────────────────────┘
```

---

## 📁 Estrutura do Repositório

```text
kafka-onboarding-dotnet/
│
├── 📄 docker-compose.yml          # Ambiente Kafka local com KRaft (sem Zookeeper)
├── 📄 KafkaOnboarding.csproj      # Projeto .NET 8 com dependência Confluent.Kafka
├── 📄 Program.cs                  # Ponto de entrada — modo producer ou consumer
├── 📄 README.md                   # Você está aqui 😊
│
├── 📁 Models/
│   └── ThermostatReading.cs       # Record C# que representa um evento de sensor
│
├── 📁 Producer/
│   └── ThermostatProducer.cs      # Producer com Acks.All e idempotência habilitada
│
├── 📁 Consumer/
│   └── ThermostatConsumer.cs      # Consumer com commit manual e alerta de temperatura
│
└── 📁 flink/
    └── thermostat_queries.sql     # Queries Flink SQL: agregação, janelas e alertas
```

---

## 🔧 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Git para Windows](https://git-scm.com/download/win)
- **PowerShell 7+** (recomendado) ou Windows PowerShell 5.1

---

## ▶️ Como Executar

> 💡 Todos os comandos abaixo devem ser executados no **PowerShell** (Windows).

### 1️⃣ Clone o repositório

```powershell
git clone https://github.com/seu-usuario/kafka-onboarding-dotnet.git
Set-Location kafka-onboarding-dotnet
```

### 2️⃣ Suba o ambiente Kafka

```powershell
docker compose up -d
```

✅ Aguarde alguns segundos para o broker inicializar completamente.

### 3️⃣ Verifique se o Kafka está rodando

```powershell
docker ps
# kafka   Up X seconds   0.0.0.0:9092->9092/tcp
```

### 4️⃣ Crie o tópico

```powershell
docker exec -it kafka /opt/kafka/bin/kafka-topics.sh `
  --create `
  --topic thermostat-readings `
  --bootstrap-server localhost:9092 `
  --partitions 3 `
  --replication-factor 1
```

> ℹ️ No PowerShell, o caractere de continuação de linha é o **backtick** (`` ` ``), e não a barra invertida (`\`) usada no Bash.

### 5️⃣ Instale as dependências .NET

```powershell
dotnet restore
```

### 6️⃣ Execute o Producer

```powershell
dotnet run -- producer
```

**Saída esperada:**

```text
✅ Enviado | Sensor: 1  | Partição: 0 | Offset: 0  | Temp: 22.5°C
✅ Enviado | Sensor: 2  | Partição: 2 | Offset: 0  | Temp: 21.0°C
✅ Enviado | Sensor: 42 | Partição: 1 | Offset: 0  | Temp: 24.0°C
✅ Enviado | Sensor: 42 | Partição: 1 | Offset: 1  | Temp: 26.3°C
🏁 Producer finalizado.
```

### 7️⃣ Execute o Consumer (em outra janela do PowerShell)

```powershell
dotnet run -- consumer
```

**Saída esperada:**

```text
🎧 Aguardando mensagens... (Ctrl+C para sair)

📩 Key: sensor-1  | Local: kitchen | Temp: 22.5°C | Partição: 0 | Offset: 0
📩 Key: sensor-42 | Local: kitchen | Temp: 26.3°C | Partição: 1 | Offset: 1
🔥 ALERTA: Temperatura alta em kitchen!
```

---

## 💡 Conceitos-Chave Ilustrados no Código

### 🔑 Particionamento por Chave

```csharp
// Sensor 42 sempre vai para a mesma partição
// Kafka faz: hash("sensor-42") % num_partitions
var key = $"sensor-{reading.SensorId}";
```

### 🛡️ Durabilidade Garantida no Producer

```csharp
Acks = Acks.All,           // aguarda confirmação de todos os brokers
EnableIdempotence = true   // garante exatamente uma entrega (exactly-once)
```

### 📍 Commit Manual de Offset no Consumer

```csharp
// Só confirma o offset APÓS processar com sucesso
// Evita perda de mensagens em caso de falha
consumer.Commit(result);
```

### 🔄 Leituras Não-Destrutivas

No Kafka, consumir uma mensagem **não a remove** do tópico. Múltiplos consumers (ou grupos diferentes) podem ler os mesmos eventos de forma independente. As mensagens só expiram pelo tempo de retenção configurado no tópico (padrão: **7 dias**).

---

## 📊 Stream Processing com Flink SQL

O arquivo `flink/thermostat_queries.sql` contém exemplos de:

- ✅ Criação de tabela sobre tópico Kafka
- ✅ Agregação com média e máximo por janela de 5 minutos
- ✅ Filtro de eventos críticos (temperatura > 25°C)
- ✅ Geração automática do novo tópico `high-temp-alerts`

---

## 🗺️ Roadmap de Estudos

```text
✅ Fase 1 — Fundamentos
   ├── Eventos vs. Tabelas
   ├── Tópicos, Partições e Offsets
   ├── Brokers, Clusters e KRaft
   └── Replicação e Tolerância a Falhas

✅ Fase 2 — Desenvolvimento .NET
   ├── Producer com idempotência
   ├── Consumer com commit manual
   └── Consumer Groups e escalabilidade

🔜 Fase 3 — Ecossistema Avançado
   ├── Schema Registry com Avro em .NET
   ├── Kafka Connect com CDC (Change Data Capture)
   ├── Deploy no Confluent Cloud
   └── Monitoramento e tuning de performance
```

---

## 📚 Referências e Recursos

| Recurso                       | Link                                                                     |
|-------------------------------|--------------------------------------------------------------------------|
| Documentação Apache Kafka     | [kafka.apache.org](https://kafka.apache.org/documentation/)              |
| Confluent Developer           | [developer.confluent.io](https://developer.confluent.io/)                |
| Confluent Hub (Connectors)    | [confluent.io/hub](https://www.confluent.io/hub/)                        |
| Lib Confluent.Kafka (.NET)    | [NuGet — Confluent.Kafka](https://www.nuget.org/packages/Confluent.Kafka) |
| Apache Flink SQL              | [flink.apache.org](https://flink.apache.org/)                            |
| Confluent Cloud (Free Tier)   | [confluent.io/get-started](https://www.confluent.io/get-started/)        |

---

## 🤝 Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para:

1. Fazer um **fork** do repositório
2. Criar uma branch: `git checkout -b feature/minha-feature`
3. Fazer o commit: `git commit -m "feat: adiciona exemplo de Schema Registry"`
4. Fazer o push: `git push origin feature/minha-feature`
5. Abrir um **Pull Request** 🚀

---

## 📝 Licença

Distribuído sob a licença **MIT**. Veja o arquivo [`LICENSE`](./LICENSE) para mais detalhes.

---

## 👤 Autor

Feito com 💙 e muito ☕ por **Fábio Muniz**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=flat&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/fabiomunizdeveloper/)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white)](https://github.com/ntitsolutins01?tab=repositories)

---

> *"Um evento acontece e você faz o trabalho agora mesmo. Não amanhã, não em batch — agora."*
> — **Tim Berglund**, Confluent

---

## 📌 Como atualizar no GitHub (PowerShell)

```powershell
# Substitua o README.md existente e faça o push
Copy-Item -Path .\README.md -Destination .\kafka-onboarding-dotnet\README.md -Force

Set-Location .\kafka-onboarding-dotnet
git add README.md
git commit -m "docs: adiciona README completo do onboarding Kafka .NET"
git push origin main
```
