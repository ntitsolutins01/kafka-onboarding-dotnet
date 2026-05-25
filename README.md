<div align="center">

[![🇧🇷 Português](https://img.shields.io/badge/lang-Portugu%C3%AAs-009C3B?style=for-the-badge&logo=googletranslate&logoColor=white)](./README.md)
[![🇺🇸 English](https://img.shields.io/badge/lang-English-B22234?style=for-the-badge&logo=googletranslate&logoColor=white)](./README_EN.md)

**🌐 Idioma atual: Português 🇧🇷** • [Switch to English 🇺🇸](./README_EN.md)

</div>

---

# 🚀 Apache Kafka Onboarding — .NET (C#) + Flink SQL

> **Onboarding prático e didático** para desenvolvedores .NET que querem dominar
> Apache Kafka do zero: desde a teoria de eventos até stream processing com Flink SQL.
> Tudo orquestrado por scripts **PowerShell idempotentes**.

![Apache Kafka](https://img.shields.io/badge/Apache%20Kafka-3.8-231F20?style=for-the-badge&logo=apachekafka&logoColor=white)
![.NET](https://img.shields.io/badge/.NET-8.0-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)
![Apache Flink](https://img.shields.io/badge/Apache%20Flink-1.19-E6526F?style=for-the-badge&logo=apacheflink&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-7+-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Testes](https://img.shields.io/badge/Testes-E2E_Automatizados-success?style=for-the-badge&logo=testinglibrary&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-POC_Ready-blueviolet?style=for-the-badge)

---

## 📑 Sumário

- [Sobre o Projeto](#-sobre-o-projeto)
- [O que você vai aprender](#-o-que-você-vai-aprender)
- [Arquitetura do Projeto](#️-arquitetura-do-projeto)
- [Stack Tecnológica](#-stack-tecnológica)
- [Estrutura do Repositório](#-estrutura-do-repositório)
- [Pré-requisitos](#-pré-requisitos)
- [Quick Start (1 comando)](#️-quick-start-1-comando)
- [Como Funciona](#-como-funciona)
- [Scripts Disponíveis](#️-scripts-disponíveis)
- [🧪 Testes End-to-End Automáticos](#-testes-end-to-end-automáticos)
- [Dashboards e Ferramentas](#-dashboards-e-ferramentas)
- [Conceitos-Chave Ilustrados no Código](#-conceitos-chave-ilustrados-no-código)
- [Stream Processing com Flink SQL](#-stream-processing-com-flink-sql)
- [Configuração](#️-configuração)
- [Roadmap de Estudos](#️-roadmap-de-estudos)
- [Troubleshooting](#️-troubleshooting)
- [FAQ](#-faq)
- [Contribuições](#-contribuições)
- [Referências e Recursos](#-referências-e-recursos)
- [Licença](#-licença)
- [Autor](#-autor)

---

## 📌 Sobre o Projeto

Este repositório é um **guia de onboarding completo** para Apache Kafka utilizando **.NET 8 (C#)** como linguagem principal, com stream processing via **Apache Flink SQL**. O projeto foi construído com base no curso oficial da Confluent *"Getting Started with Apache Kafka® and Real-Time Data Streaming"* e traduz cada conceito teórico em **código funcional**, pronto para rodar localmente em minutos.

### 💡 Por que este projeto?

- 🎓 **Aprenda Kafka na prática** — cada conceito (partições, consumer groups, DLQ, lag) é demonstrado com código funcional
- 🚀 **Quick start em 60 segundos** — `.\scripts\run-poc.ps1` e está tudo no ar
- 📚 **Real e reproduzível** — baseado em padrões reais de produção, não em exemplos de brinquedo
- 🇧🇷 **Documentação em PT-BR e EN** — acessível à comunidade global
- 🛠️ **Stack moderna** — .NET 8, Kafka 3.8 (KRaft), Flink 1.19, Docker Compose v2
- 🤖 **Automação completa via PowerShell** — um único comando sobe a infra, valida health-checks, cria tópicos, abre Consumer, Monitor de LAG e Producer em janelas separadas

A proposta é simples: **aprender fazendo**. Cada arquivo deste repositório representa um conceito real do ecossistema Kafka — sem abstrações desnecessárias, sem boilerplate excessivo, com foco total em clareza e aplicabilidade.

### 🎯 Para quem é este projeto?

- 👨‍💻 **Desenvolvedores .NET** que querem aprender Kafka
- 🎓 **Estudantes** de arquiteturas distribuídas e event-driven
- 🏗️ **Arquitetos** prototipando soluções orientadas a eventos
- 👨‍🏫 **Instrutores** procurando material didático com código real
- 🔍 **SREs** querendo entender o ecossistema Kafka end-to-end

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
| **Consumer Lag**        | Monitoramento em tempo real do atraso de processamento          |
| **Dead Letter Queue**   | Tratamento de mensagens com erro via tópico `*-dlq`             |
| **Listeners Internos/Externos** | Como expor o Kafka para apps no host e em containers    |
| **Schema Registry**     | Governança de esquemas com Avro, JSON Schema e Protobuf         |
| **Kafka Connect**       | Integração com sistemas externos sem escrever código            |
| **Flink SQL**           | Stream processing com janelas de tempo e alertas em tempo real  |

---

## 🏗️ Arquitetura do Projeto

```text
                ┌─────────────────────────────────────────────┐
                │      Apache Kafka (KRaft - sem Zookeeper)   │
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
              │   (host Windows)    │   │   TaskManager)    │
              └─────────────────────┘   └───────────────────┘

              ┌──────────────────────┐  ┌─────────────────────┐
              │  Kafka UI :8080      │  │  Flink Dashboard    │
              │  (Provectus)         │  │  :8081              │
              └──────────────────────┘  └─────────────────────┘
```

### 🔌 Listeners de rede

| Listener     | Endpoint            | Usado por                              |
|--------------|---------------------|----------------------------------------|
| **INTERNAL** | `kafka:29092`       | Containers (Flink, Kafka UI)           |
| **EXTERNAL** | `localhost:9092`    | Apps .NET rodando no host              |

---

## 🛠️ Stack Tecnológica

| Camada                 | Tecnologia                         | Versão   | Finalidade                                  |
|------------------------|------------------------------------|----------|---------------------------------------------|
| **Messaging**          | Apache Kafka                       | 3.8.0    | Plataforma de streaming distribuída         |
| **Stream Processing**  | Apache Flink                       | 1.19     | Processamento de streams em tempo real      |
| **Aplicação**          | .NET                               | 8.0      | Apps Producer & Consumer                    |
| **Cliente Kafka**      | Confluent.Kafka                    | 2.x      | Cliente oficial .NET para Kafka             |
| **Containerização**    | Docker + Docker Compose            | v2       | Orquestração de infra local                 |
| **Monitoring UI**      | Kafka UI (Provectus)               | latest   | Visualização gráfica do cluster             |
| **Automação**          | PowerShell                         | 5.1 / 7+ | Scripts idempotentes de orquestração        |
| **Serialização**       | System.Text.Json                   | nativo   | Serialização JSON de eventos                |

---

## 📁 Estrutura do Repositório

```text
kafka-onboarding-dotnet/
│
├── 📄 docker-compose.yml          # Kafka (KRaft) + Kafka UI + Flink (JM + TM)
├── 📄 KafkaOnboarding.csproj      # Projeto .NET 8
├── 📄 Program.cs                  # Ponto de entrada — producer / consumer
├── 📄 README.md                   # Você está aqui 😊
├── 📄 README_EN.md                # Versão em inglês
├── 📄 AUTOMATIC_TEST.md           # 🧪 Guia completo de testes E2E automatizados
├── 📄 MANUAL_TEST.md              # 🧑‍🔬 Guia de testes manuais didáticos
├── 📄 CONTRIBUTING.md             # 🤝 Como contribuir
├── 📄 LICENSE                     # 📜 Licença MIT
│
├── 📁 scripts/                    # 🤖 Automação PowerShell completa
│   ├── 01-start-infra.ps1         # Sobe containers + valida health Kafka + porta 9092
│   ├── 02-create-topics.ps1       # Cria tópicos onboarding-events e DLQ (idempotente)
│   ├── 03-run-consumer.ps1        # Inicia consumer .NET (janela dedicada)
│   ├── 04-run-producer.ps1        # Envia eventos de teste (janela dedicada)
│   ├── 05-monitor.ps1             # Monitora LAG do consumer group (refresh 2s)
│   ├── 99-stop-all.ps1            # Para containers (opcional: limpa volumes)
│   └── run-poc.ps1                # ⭐ Orquestrador end-to-end (um comando faz tudo)
│
├── 📁 Models/
│   └── OnboardingEvent.cs         # Record C# que representa um evento
│
├── 📁 Producer/
│   └── OnboardingProducer.cs      # Producer com Acks.All e idempotência
│
├── 📁 Consumer/
│   ├── OnboardingConsumer.cs      # Consumer com commit manual + DLQ
│   └── DlqHandler.cs              # Handler de Dead Letter Queue
│
└── 📁 flink/
    ├── lib/
    │   └── flink-sql-connector-kafka-3.3.0-1.19.jar
    └── onboarding_queries.sql     # Queries Flink SQL: janelas e alertas
```

---

## 🔧 Pré-requisitos

| Ferramenta         | Versão mínima | Como verificar               |
|--------------------|---------------|------------------------------|
| **Docker Desktop** | 4.x           | `docker --version`           |
| **Docker Compose** | v2            | `docker compose version`     |
| **.NET SDK**       | 8.0+          | `dotnet --version`           |
| **PowerShell**     | 5.1 ou 7+     | `$PSVersionTable.PSVersion`  |
| **Portas livres**  | 8080, 8081, 9092 | `Test-NetConnection localhost -Port 9092` |

> 💡 Recomendado **PowerShell 7+ (pwsh)** — o orquestrador detecta automaticamente.

### 🔓 Liberar execução de scripts (1ª vez)

Por padrão o Windows bloqueia scripts `.ps1`. Rode **uma única vez**:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

Confirme com `S`. Isso libera scripts locais apenas para o seu usuário.

---

## ▶️ Quick Start (1 comando)

> 💡 Todos os comandos abaixo são executados no **PowerShell**.

### 1️⃣ Clone o repositório

```powershell
git clone https://github.com/ntitsolutins01/kafka-onboarding-dotnet.git
Set-Location kafka-onboarding-dotnet\KafkaOnboarding
```

### 2️⃣ Rode o orquestrador end-to-end 🚀

```powershell
.\scripts\run-poc.ps1
```

O script faz **tudo automaticamente em 5 etapas**:

```text
[1/5] Sobe infraestrutura Docker
      └─ aguarda Kafka healthy + valida porta 9092
[2/5] Cria/verifica tópicos (idempotente)
      ├─ onboarding-events       (3 partições)
      └─ onboarding-events-dlq   (3 partições)
[3/5] Abre janela CONSUMER  → processa onboarding-events
      └─ aguarda 15s para subscribe + rebalance
[4/5] Abre janela MONITOR   → LAG em tempo real (refresh 2s)
[5/5] Abre janela PRODUCER  → envia eventos de teste
```

**Resultado:** 3 janelas separadas + Kafka UI + Flink UI rodando, prontos para inspeção visual.

```text
===========================================================
  KAFKA ONBOARDING - POC END-TO-END
  Orquestrador completo (shell: pwsh)
===========================================================

[OK] Kafka esta healthy!
[OK] Porta 9092 respondendo!
[OK] Infra pronta!

   - onboarding-events       [CRIADO] 3 particoes
   - onboarding-events-dlq   [CRIADO] 3 particoes
[OK] Topicos prontos!

===========================================================
  POC RODANDO!
===========================================================
  Consumer  -> janela CONSUMER
  Monitor   -> janela MONITOR (LAG em tempo real)
  Producer  -> janela PRODUCER (enviando msgs)

  Kafka UI  -> http://localhost:8080
  Flink UI  -> http://localhost:8081
```

### 3️⃣ Quando terminar, derrube tudo

```powershell
.\scripts\99-stop-all.ps1
```

O script pergunta se você quer **preservar** ou **apagar** os volumes (dados do Kafka).

### 🌐 Pontos de acesso

Após `run-poc.ps1` finalizar:

- 🖥️ **Kafka UI**: http://localhost:8080
- 🌊 **Flink Dashboard**: http://localhost:8081
- 🔌 **Kafka Broker**: `localhost:9092`

---

## 🧠 Como Funciona

### 1️⃣ O Producer

Envia eventos de onboarding de clientes para o tópico `onboarding-events`:

```csharp
var evt = new OnboardingEvent(
    CustomerId: "CUST-001",
    Name: "João da Silva",
    Status: "PENDING",
    Timestamp: DateTime.UtcNow
);

await producer.ProduceAsync(evt);
// → vai para a partição baseada em hash(CustomerId)
```

**Características principais:**
- ✅ `Acks.All` → aguarda confirmação de todas as réplicas
- ✅ `EnableIdempotence = true` → evita duplicatas em retries
- ✅ Particionamento por `CustomerId` → garante ordem por cliente

### 2️⃣ O Consumer

Lê eventos de `onboarding-events` e os processa:

```csharp
while (!ct.IsCancellationRequested)
{
    var result = consumer.Consume(ct);

    try
    {
        var evt = JsonSerializer.Deserialize<OnboardingEvent>(result.Message.Value);
        await ProcessAsync(evt);
        consumer.Commit(result);  // ✅ commit manual após sucesso
    }
    catch (Exception ex)
    {
        await dlqHandler.SendAsync(result, ex);  // 🛡️ vai para DLQ
        consumer.Commit(result);  // evita reprocessar a poison pill
    }
}
```

**Características principais:**
- ✅ Consumer group: `onboarding-processor`
- ✅ Commit manual de offset (controle fino)
- ✅ DLQ automática em caso de falha
- ✅ Resiliente a mensagens malformadas

### 3️⃣ A DLQ (Dead Letter Queue)

Mensagens que falham no processamento vão para `onboarding-events-dlq` com **headers de erro**:

```text
Headers:
  - exception-type: System.Text.Json.JsonException
  - exception-message: "The input is not valid JSON"
  - original-topic: onboarding-events
  - original-partition: 1
  - original-offset: 42
  - failed-at: 2026-05-24T22:00:00Z
```

Isso permite **reprocessar** mensagens depois de corrigir o bug.

---

## 🎛️ Scripts Disponíveis

Todos os scripts ficam em `.\scripts\` e são **idempotentes** (podem rodar várias vezes sem efeito colateral).

| Script                       | Função                                          | Tempo médio |
|------------------------------|--------------------------------------------------|-------------|
| `01-start-infra.ps1`         | Sobe containers + valida health Kafka + porta   | ~30s        |
| `02-create-topics.ps1`       | Cria/verifica `onboarding-events` e DLQ         | ~3s         |
| `03-run-consumer.ps1`        | Inicia consumer .NET                            | contínuo    |
| `04-run-producer.ps1`        | Envia eventos de teste                          | ~10–30s     |
| `05-monitor.ps1`             | Monitora LAG do consumer group (refresh 2s)     | contínuo    |
| `99-stop-all.ps1`            | Para containers (opcional: limpa volumes)       | ~5s         |
| `run-poc.ps1`                | **Orquestrador end-to-end**                     | ~60s        |

### 🔁 Execução manual (modo passo-a-passo)

Quer entender cada etapa? Rode separadamente em terminais diferentes:

```powershell
# Terminal 1 — Infra
.\scripts\01-start-infra.ps1
.\scripts\02-create-topics.ps1

# Terminal 2 — Consumer (deixa rodando)
.\scripts\03-run-consumer.ps1

# Terminal 3 — Monitor de LAG (deixa rodando)
.\scripts\05-monitor.ps1

# Terminal 4 — Producer (dispara o teste)
.\scripts\04-run-producer.ps1
```

### 🆘 Algo deu errado?

Se o ambiente ficar inconsistente (containers órfãos, conflito de nomes, volume corrompido):

```powershell
.\scripts\99-stop-all.ps1   # responda "S" para apagar volumes
.\scripts\run-poc.ps1       # sobe do zero
```

Isso resolve **99% dos problemas** voltando a um estado limpo.

---

## 🧪 Testes End-to-End Automáticos

Quer validar se tudo está funcionando lindo? Preparei **dois guias completos de testes**:

### 🤖 [AUTOMATIC_TEST.md](./AUTOMATIC_TEST.md)
Testes E2E automatizados — ideal para **CI/CD**, **demos** e **smoke tests**.
- ⏱️ **Tempo:** ~60 segundos
- 🎯 **Foco:** Funciona?

**O que você vai encontrar lá:**

- ✅ Diagrama do fluxo automatizado em 5 etapas
- ✅ Tabela com tempo médio de cada script
- ✅ Checklist marcável de critérios de sucesso
- ✅ Validações esperadas em cada janela (Consumer / Monitor / Producer)
- ✅ Interpretação dos níveis de **Consumer Lag**
- ✅ Troubleshooting dos erros mais comuns (encoding, porta ocupada, container unhealthy)
- ✅ Procedimento de reset completo (smoke test do zero)
- ✅ Métricas e observabilidade (onde ver throughput, LAG, DLQ)

### 🧑‍🔬 [MANUAL_TEST.md](./MANUAL_TEST.md)
Testes manuais passo a passo — ideal para **aprendizado**, **debug** e **ensino**.
- ⏱️ **Tempo:** ~30–60 minutos
- 🎯 **Foco:** Por que funciona?
- 🎓 Inclui **4 cenários didáticos extras** (rebalance, ordering, resiliência, replay)

### ⚡ Quick test em 1 comando

```powershell
.\scripts\run-poc.ps1
```

E depois observe:
- 🟢 **Janela CONSUMER** — mensagens sendo processadas
- 🟡 **Janela MONITOR** — LAG zerando em tempo real
- 🔵 **Janela PRODUCER** — eventos sendo enviados
- 🌐 **Kafka UI** ([http://localhost:8080](http://localhost:8080)) — inspeção visual

---

## 🌐 Dashboards e Ferramentas

| Ferramenta | URL | O que faz |
|---|---|---|
| **Kafka UI** | http://localhost:8080 | Visualiza tópicos, partições, mensagens, consumer groups |
| **Flink Dashboard** | http://localhost:8081 | Gerencia jobs Flink, vê métricas e flame graphs |

### 📊 Métricas e Observabilidade

| Métrica                | Onde ver                                  |
|------------------------|-------------------------------------------|
| **Consumer Lag**       | `.\scripts\05-monitor.ps1` ou Kafka UI    |
| **Throughput (msg/s)** | Kafka UI → Topic → Overview               |
| **Partição balance**   | Kafka UI → Topic → Partitions             |
| **Mensagens em DLQ**   | Kafka UI → `onboarding-events-dlq`        |
| **Flink Slots**        | http://localhost:8081 → Overview          |

### 🚦 Interpretação do Consumer Lag

| LAG observado    | Significado                            |
|------------------|----------------------------------------|
| `0`              | ✅ Consumer caught up — saudável        |
| `< 100`          | ✅ Processamento normal                 |
| `100 — 1000`     | ⚠️ Investigar throughput               |
| `> 1000` crescendo | 🔴 Consumer não consegue acompanhar   |

---

## 💡 Conceitos-Chave Ilustrados no Código

Este POC cobre, na prática, os seguintes **conceitos fundamentais do Kafka**:

| Conceito                       | Onde ver no código                              |
|--------------------------------|--------------------------------------------------|
| 🎯 **Tópicos e Partições**     | `02-create-topics.ps1` cria 3 partições         |
| 🔑 **Particionamento por chave** | Producer usa `CustomerId` como key             |
| 👥 **Consumer Groups**         | Grupo `onboarding-processor`                     |
| 💾 **Commit manual de offset** | `consumer.Commit()` após sucesso                 |
| 🛡️ **Dead Letter Queue (DLQ)** | Tópico `onboarding-events-dlq` + headers de erro|
| 📊 **Monitoramento de Lag**    | `05-monitor.ps1` mostra LAG em tempo real       |
| ⚡ **Idempotent Producer**     | `EnableIdempotence = true`                       |
| 🔄 **Replay a partir de offset** | `--reset-offsets --to-earliest` manual         |
| 🌐 **Config multi-listener**   | Listeners INTERNAL + EXTERNAL                    |
| 🚦 **Acks e durabilidade**     | `Acks.All` aguarda todas as réplicas             |
| 🔁 **Rebalance**               | Veja Cenário A no `MANUAL_TEST.md`              |
| 🔥 **Resiliência do cliente**  | Auto-reconexão após queda do broker              |

### 🔑 Particionamento por Chave

```csharp
// Eventos do mesmo cliente vão sempre para a mesma partição
// Garante ordenação por cliente
var key = $"CUST-{customerId}";
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

### ☠️ Dead Letter Queue (DLQ)

```csharp
// Mensagens com erro de deserialização ou validação
// são redirecionadas para onboarding-events-dlq
await producer.ProduceAsync("onboarding-events-dlq", failedMessage);
```

### 🔌 Listeners Internos vs. Externos

```yaml
KAFKA_ADVERTISED_LISTENERS: INTERNAL://kafka:29092,EXTERNAL://localhost:9092
```

- **INTERNAL (`kafka:29092`)** → usado pelos containers (Flink, Kafka UI)
- **EXTERNAL (`localhost:9092`)** → usado pelo app .NET rodando no host

Sem essa separação, ou o host não conecta, ou os containers não conectam. 🎯

### 🔄 Leituras Não-Destrutivas

No Kafka, consumir uma mensagem **não a remove** do tópico. Múltiplos consumers (ou grupos diferentes) podem ler os mesmos eventos de forma independente. As mensagens só expiram pelo tempo de retenção configurado no tópico (padrão: **7 dias**).

---

## 📊 Stream Processing com Flink SQL

O arquivo `flink/onboarding_queries.sql` contém exemplos de:

- ✅ Criação de tabela sobre tópico Kafka
- ✅ Agregação por janela de tempo (tumbling/sliding windows)
- ✅ Filtro de eventos críticos (ex: falhas de KYC)
- ✅ Sink em novo tópico de resumo

### Como submeter um job Flink

```powershell
# Abrir o SQL Client dentro do container
docker exec -it flink-jobmanager /opt/flink/bin/sql-client.sh

# Dentro do prompt, cole/execute as queries do arquivo
```

### Exemplo de query

```sql
-- Criar tabela sobre o tópico Kafka
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

-- Contagem de eventos por status em janelas de 1 minuto
SELECT
    status,
    TUMBLE_START(event_time, INTERVAL '1' MINUTE) AS window_start,
    COUNT(*) AS event_count
FROM onboarding_events
GROUP BY status, TUMBLE(event_time, INTERVAL '1' MINUTE);
```

---

## ⚙️ Configuração

### 🐳 docker-compose.yml

Principais serviços:

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

### 🔧 Configuração do Producer

```csharp
var config = new ProducerConfig
{
    BootstrapServers = "localhost:9092",
    Acks = Acks.All,                    // aguarda todas as réplicas
    EnableIdempotence = true,           // evita duplicatas
    MessageSendMaxRetries = 3,          // retry até 3 vezes
    CompressionType = CompressionType.Snappy
};
```

### 🔧 Configuração do Consumer

```csharp
var config = new ConsumerConfig
{
    BootstrapServers = "localhost:9092",
    GroupId = "onboarding-processor",
    AutoOffsetReset = AutoOffsetReset.Earliest,
    EnableAutoCommit = false,           // commit manual
    SessionTimeoutMs = 30_000
};
```

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
   ├── Consumer Groups e escalabilidade
   ├── Dead Letter Queue (DLQ)
   └── Listeners internos vs. externos

✅ Fase 3 — Automação e Observabilidade
   ├── Scripts PowerShell idempotentes
   ├── Health-checks de containers
   ├── Monitoramento de LAG em tempo real
   └── Testes E2E automatizados

✅ Fase 4 — Stream Processing
   ├── Flink JobManager + TaskManager
   ├── Flink SQL Client
   └── Janelas de tempo e agregações

🚧 Fase 5 — Em andamento
   ├── Submeter job Flink consumindo do Kafka
   ├── Schema Registry + serialização Avro
   ├── CI/CD com GitHub Actions
   └── Testes de integração com TestContainers

🔮 Fase 6 — Planejado
   ├── Setup multi-broker (3 brokers + replication-factor 3)
   ├── Autenticação OAuth/TLS
   ├── Métricas Prometheus + Grafana
   ├── Distributed tracing com OpenTelemetry
   ├── Exemplo de Kafka Streams em .NET
   ├── Producer/Consumer em Kotlin para comparação
   └── Deploy Kubernetes (Strimzi)
```

---

## 🛠️ Troubleshooting

### ❌ `Failed to resolve 'kafka:9092'`

O cliente .NET está tentando resolver o hostname `kafka`, que só existe na rede Docker.

**Solução:** confira se `KAFKA_ADVERTISED_LISTENERS` no `docker-compose.yml` tem o listener `EXTERNAL://localhost:9092`. Se mudou recentemente:

```powershell
.\scripts\99-stop-all.ps1   # responda "S"
.\scripts\run-poc.ps1
```

### ❌ `Conflict. The container name "/kafka" is already in use`

Container órfão de um projeto anterior travando o restart.

**Solução:**

```powershell
.\scripts\99-stop-all.ps1   # responda "S"
.\scripts\run-poc.ps1
```

Ou manualmente:

```powershell
docker rm -f kafka kafka-ui flink-jobmanager flink-taskmanager
.\scripts\01-start-infra.ps1
```

### ❌ Kafka não fica `healthy`

Verifique os logs:

```powershell
docker logs kafka --tail 50
```

Se houver erro de **metadados corrompidos no volume**, faça reset:

```powershell
.\scripts\99-stop-all.ps1   # responda "S"
.\scripts\run-poc.ps1
```

### ❌ Porta 9092 não responde

Algum outro processo está ocupando a porta.

```powershell
# Descobre quem está usando a porta
Get-NetTCPConnection -LocalPort 9092 | Select-Object OwningProcess
Get-Process -Id <PID>
```

### ❌ Caracteres estranhos no terminal (`\`, `\"`, `²`)

Encoding do PowerShell não está em UTF-8.

```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
```

### ❌ Consumer não recebe mensagens

Consumer subiu **depois** do producer com `auto.offset.reset=latest`.

**Solução:** O `run-poc.ps1` já cuida disso com `Start-Sleep 15` entre subir o consumer e o producer. Se rodar manual, garanta a ordem:
1. Consumer primeiro
2. Aguarde rebalance (10–15s)
3. Producer depois

### ❌ LAG crescendo continuamente

```powershell
docker exec kafka /opt/kafka/bin/kafka-consumer-groups.sh `
    --bootstrap-server localhost:29092 `
    --group onboarding-processor `
    --describe
```

Veja throughput no Kafka UI → Topics → onboarding-events → Messages.

> 📌 Mais cenários detalhados no [**AUTOMATIC_TEST.md**](./AUTOMATIC_TEST.md#-troubleshooting).

---

## ❓ FAQ

<details>
<summary><strong>🤔 Por que Kafka 3.8 em modo KRaft (sem Zookeeper)?</strong></summary>

Desde o Kafka 3.3+, o modo KRaft é **production-ready** e **elimina a dependência do Zookeeper**.
Isso simplifica a arquitetura, reduz overhead operacional e é o **futuro oficial do Kafka**.
O Zookeeper está deprecated e será removido no Kafka 4.0.
</details>

<details>
<summary><strong>🤔 Por que PowerShell em vez de Bash?</strong></summary>

O projeto foi desenvolvido no **Windows**, onde PowerShell é nativo. Com o PowerShell 7+ sendo
**cross-platform** (Windows, Linux, macOS), os scripts também rodam em sistemas Unix. Se você
prefere Bash, contribuições com versões equivalentes são bem-vindas (veja [CONTRIBUTING.md](./CONTRIBUTING.md)).
</details>

<details>
<summary><strong>🤔 Posso usar isso em produção?</strong></summary>

**NÃO**. Este é um **POC didático** com configurações simplificadas:
- ❌ `replication-factor = 1` (sem tolerância a falhas)
- ❌ Sem autenticação/TLS
- ❌ Sem monitoramento real (Prometheus, alertas)
- ❌ Sem estratégia de backup/disaster recovery

Para produção, veja o [Roadmap](#️-roadmap-de-estudos) e adapte adequadamente.
</details>

<details>
<summary><strong>🤔 Por que .NET 8 e não 9?</strong></summary>

.NET 8 é uma versão **LTS (Long-Term Support)**, suportada até **novembro de 2026**.
.NET 9 é STS (Standard-Term Support) e expira mais rápido. Para projetos didáticos,
LTS oferece mais longevidade.
</details>

<details>
<summary><strong>🤔 Como adiciono um novo tipo de evento?</strong></summary>

1. Crie um novo record em `Models/`
2. Atualize o producer para enviar o novo tipo
3. Atualize o consumer para tratar o novo tipo
4. Documente neste README (em [Como Funciona](#-como-funciona))
5. Adicione um cenário de teste em [MANUAL_TEST.md](./MANUAL_TEST.md)
</details>

<details>
<summary><strong>🤔 Posso usar isso com Confluent Cloud?</strong></summary>

Sim! Basta mudar o `BootstrapServers` e adicionar credenciais SASL:

```csharp
var config = new ProducerConfig
{
    BootstrapServers = "seu-cluster.confluent.cloud:9092",
    SecurityProtocol = SecurityProtocol.SaslSsl,
    SaslMechanism = SaslMechanism.Plain,
    SaslUsername = "SUA_API_KEY",
    SaslPassword = "SEU_API_SECRET"
};
```
</details>

<details>
<summary><strong>🤔 Cadê o job Flink?</strong></summary>

O job Flink está no [Roadmap](#️-roadmap-de-estudos) e ainda não foi implementado.
O Flink neste POC está **preparado** (JobManager + TaskManager rodando) mas **ainda não executa jobs**.
Essa será a **próxima major feature** do projeto.
</details>

<details>
<summary><strong>🤔 Posso rodar isso no Linux/macOS?</strong></summary>

Sim, com **PowerShell 7+** instalado. O Docker e o .NET SDK são cross-platform.
Os scripts `.ps1` rodam normalmente via `pwsh` em Linux e macOS.

```bash
# Linux/macOS
pwsh ./scripts/run-poc.ps1
```
</details>

---

## 🤝 Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para:

1. Fazer um **fork** do repositório
2. Criar uma branch: `git checkout -b feature/minha-feature`
3. Fazer o commit: `git commit -m "feat: adiciona exemplo de Schema Registry"`
4. Fazer o push: `git push origin feature/minha-feature`
5. Abrir um **Pull Request** 🚀

### 📝 Padrões para novos scripts

Ao adicionar scripts em `.\scripts\`:

1. Siga o padrão de nomenclatura `NN-acao-objeto.ps1`
2. Use **aspas simples** em heredocs (`@'...'@`) para evitar bugs de escape
3. Sempre escreva os arquivos com **UTF-8 BOM** via `[System.IO.File]::WriteAllText`
4. Documente o cenário no [`AUTOMATIC_TEST.md`](./AUTOMATIC_TEST.md)

> 📖 Veja o guia completo em [**CONTRIBUTING.md**](./CONTRIBUTING.md).

---

## 📚 Referências e Recursos

| Recurso                       | Link                                                                     |
|-------------------------------|--------------------------------------------------------------------------|
| Documentação Apache Kafka     | [kafka.apache.org](https://kafka.apache.org/documentation/)              |
| Confluent Developer           | [developer.confluent.io](https://developer.confluent.io/)                |
| Confluent Hub (Connectors)    | [confluent.io/hub](https://www.confluent.io/hub/)                        |
| Lib Confluent.Kafka (.NET)    | [NuGet — Confluent.Kafka](https://www.nuget.org/packages/Confluent.Kafka) |
| Apache Flink SQL              | [flink.apache.org](https://flink.apache.org/)                            |
| Kafka UI (Provectus)          | [github.com/provectus/kafka-ui](https://github.com/provectus/kafka-ui)   |
| Confluent Cloud (Free Tier)   | [confluent.io/get-started](https://www.confluent.io/get-started/)        |

---

## 📜 Licença

Distribuído sob a licença **MIT**. Veja o arquivo [`LICENSE`](./LICENSE) para mais detalhes.

```text
MIT License

Copyright (c) 2026 Fábio Muniz

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

---

## 👤 Autor

Feito com 💙 e muito ☕ por **Fábio Muniz**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=flat&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/fabiomunizdeveloper/)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white)](https://github.com/ntitsolutins01?tab=repositories)

---

## 🙏 Agradecimentos

- 🚀 [Confluent](https://www.confluent.io/) — pelo `Confluent.Kafka` e pela ótima documentação
- 🐳 [Provectus](https://provectus.com/) — pelo maravilhoso Kafka UI
- 📚 [Apache Kafka Community](https://kafka.apache.org/) — pela plataforma incrível
- ❤️ Todos os [contribuidores](https://github.com/ntitsolutins01/kafka-onboarding-dotnet/graphs/contributors)

---

## 🔗 Documentos relacionados

- 🌐 [README_EN.md](./README_EN.md) — English version
- 🤖 [AUTOMATIC_TEST.md](./AUTOMATIC_TEST.md) — Guia de testes automatizados
- 🧑‍🔬 [MANUAL_TEST.md](./MANUAL_TEST.md) — Guia de testes manuais didáticos
- 🤝 [CONTRIBUTING.md](./CONTRIBUTING.md) — Como contribuir
- 📜 [LICENSE](./LICENSE) — Licença MIT

---

## ⭐ Gostou do projeto?

Se este POC te ajudou de alguma forma, considere:

- ⭐ Dar uma **estrela** no repositório do GitHub
- 🐛 Reportar **bugs** através de Issues
- 💡 Sugerir **melhorias** através de Discussions
- 🤝 **Contribuir** com código ou documentação
- 📢 **Compartilhar** com amigos e colegas

---

## 📌 Como publicar atualizações no GitHub (PowerShell)

```powershell
git add README.md AUTOMATIC_TEST.md MANUAL_TEST.md scripts/
git commit -m "docs: atualiza README + adiciona guia E2E automatizado"
git push origin main
```

---

**Projeto:** Kafka Onboarding .NET POC
**Versão:** 1.0.0
**Última atualização:** 24/05/2026
**Status:** ✅ Pronto para uso

---

> *"Um evento acontece e você faz o trabalho agora mesmo. Não amanhã, não em batch — agora."*
> — **Tim Berglund**, Confluent

> *"A melhor forma de aprender um sistema distribuído é quebrá-lo de propósito."*
> — **Fábio Muniz**
