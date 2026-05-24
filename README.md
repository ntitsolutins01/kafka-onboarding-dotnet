# 🚀 Apache Kafka Onboarding — .NET (C#) + Flink SQL

> Onboarding prático e objetivo para desenvolvedores .NET que querem dominar
> Apache Kafka do zero: desde a teoria de eventos até stream processing com Flink SQL.

![Kafka](https://img.shields.io/badge/Apache%20Kafka-3.8-231F20?style=for-the-badge&logo=apachekafka&logoColor=white)
![.NET](https://img.shields.io/badge/.NET-8.0-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Flink](https://img.shields.io/badge/Apache%20Flink-1.19-E6526F?style=for-the-badge&logo=apacheflink&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-7+-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

---

## 📌 Sobre o Projeto

Este repositório é um **guia de onboarding completo** para Apache Kafka utilizando **.NET 8 (C#)** como linguagem principal, com stream processing via **Apache Flink SQL**. O projeto foi construído com base no curso oficial da Confluent *"Getting Started with Apache Kafka® and Real-Time Data Streaming"* e traduz cada conceito teórico em código funcional, pronto para rodar localmente em minutos.

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
                │     │   Topic: onboarding-summary      │    │
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

---

## 📁 Estrutura do Repositório

```text
kafka-onboarding-dotnet/
│
├── 📄 docker-compose.yml          # Kafka (KRaft) + Kafka UI + Flink (JM + TM)
├── 📄 KafkaOnboarding.csproj      # Projeto .NET 8
├── 📄 Program.cs                  # Ponto de entrada — producer / consumer
├── 📄 README.md                   # Você está aqui 😊
│
├── 📁 scripts/                    # 🆕 Automação PowerShell
│   ├── start.ps1                  # Sobe infra + valida + cria tópicos
│   ├── stop.ps1                   # Para containers (-RemoveVolumes opcional)
│   ├── reset.ps1                  # Reset completo (limpa órfãos + sobe do zero)
│   └── producer.ps1               # Atalho para rodar o producer
│
├── 📁 Models/
│   └── OnboardingEvent.cs         # Record C# que representa um evento
│
├── 📁 Producer/
│   └── OnboardingProducer.cs      # Producer com Acks.All e idempotência
│
├── 📁 Consumer/
│   └── OnboardingConsumer.cs      # Consumer com commit manual
│
└── 📁 flink/
    ├── lib/
    │   └── flink-sql-connector-kafka-3.3.0-1.19.jar
    └── onboarding_queries.sql     # Queries Flink SQL: janelas e alertas
```

---

## 🔧 Pré-requisitos

- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (com Docker Compose)
- [Git para Windows](https://git-scm.com/download/win)
- **PowerShell 7+** (recomendado) ou Windows PowerShell 5.1

### 🔓 Liberar execução de scripts (1ª vez)

Por padrão o Windows bloqueia scripts `.ps1`. Rode **uma única vez**:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

Confirme com `S`. Isso libera scripts locais apenas para o seu usuário.

---

## ▶️ Quick Start (3 passos)

> 💡 Todos os comandos abaixo são executados no **PowerShell**.

### 1️⃣ Clone o repositório

```powershell
git clone https://github.com/seu-usuario/kafka-onboarding-dotnet.git
Set-Location kafka-onboarding-dotnet
```

### 2️⃣ Suba toda a infraestrutura com um comando 🚀

```powershell
.\scripts\start.ps1
```

O script faz **tudo automaticamente**:

- ✅ Verifica se o Docker está rodando
- ✅ Remove containers órfãos (de execuções anteriores)
- ✅ Sobe Kafka, Kafka UI, Flink JobManager e TaskManager
- ✅ Aguarda o Kafka ficar **healthy**
- ✅ Cria os tópicos `onboarding-events` e `onboarding-summary`
- ✅ Valida conectividade em `localhost:9092`
- ✅ Mostra os links dos dashboards

**Saída esperada:**

```text
🔷 Verificando Docker...
✅ Docker está rodando
🔷 Subindo a infraestrutura...
✅ Containers iniciados
🔷 Aguardando Kafka ficar healthy...
✅ Kafka está healthy 🎉
🔷 Criando tópicos...
✅ Tópico pronto: onboarding-events (partições: 3)
✅ Tópico pronto: onboarding-summary (partições: 3)

════════════════════════════════════════════════════
  🚀 Ambiente pronto!
════════════════════════════════════════════════════
  📊 Kafka UI:        http://localhost:8080
  ⚙️  Flink Dashboard: http://localhost:8081
  📡 Bootstrap:       localhost:9092
════════════════════════════════════════════════════
```

### 3️⃣ Rode o producer

```powershell
.\scripts\producer.ps1 -Rate 10 -Total 500
```

Ou manualmente:

```powershell
$env:EVENTS_PER_SECOND="10"
$env:TOTAL_EVENTS="500"
dotnet run -- producer
```

**Saída esperada:**

```text
🚀 Starting Onboarding Producer
✅ [1/500] KYC/SUCCESS → CUST-3847 (p:0, o:0)
✅ [2/500] REGISTRATION/SUCCESS → CUST-1234 (p:1, o:0)
✅ [3/500] DOCUMENT/PENDING → CUST-5123 (p:2, o:0)
...
```

### 4️⃣ (Opcional) Rode o consumer em outro terminal

```powershell
dotnet run -- consumer
```

---

## 🎛️ Comandos disponíveis

| Script | O que faz |
|---|---|
| `.\scripts\start.ps1` | Sobe infraestrutura completa + valida + cria tópicos |
| `.\scripts\stop.ps1` | Para os containers (preserva dados) |
| `.\scripts\stop.ps1 -RemoveVolumes` | Para e **apaga** dados do Kafka |
| `.\scripts\reset.ps1` | Reset total: limpa órfãos, apaga volumes, sobe do zero |
| `.\scripts\producer.ps1 -Rate 20 -Total 1000` | Roda o producer com parâmetros |

### 🆘 Algo deu errado?

Se o ambiente ficar inconsistente (containers órfãos, conflito de nomes, volume corrompido):

```powershell
.\scripts\reset.ps1
```

Isso resolve **99% dos problemas** voltando a um estado limpo.

---

## 🌐 Dashboards e Ferramentas

| Ferramenta | URL | O que faz |
|---|---|---|
| **Kafka UI** | http://localhost:8080 | Visualiza tópicos, partições, mensagens, consumer groups |
| **Flink Dashboard** | http://localhost:8081 | Gerencia jobs Flink, vê métricas e flame graphs |

---

## 💡 Conceitos-Chave Ilustrados no Código

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
- ✅ Sink em novo tópico (`onboarding-summary`)

### Como submeter um job Flink

```powershell
# Abrir o SQL Client dentro do container
docker exec -it flink-jobmanager /opt/flink/bin/sql-client.sh

# Dentro do prompt, cole/execute as queries do arquivo
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
   └── Listeners internos vs. externos

✅ Fase 3 — Stream Processing
   ├── Flink JobManager + TaskManager
   ├── Flink SQL Client
   └── Janelas de tempo e agregações

🔜 Fase 4 — Ecossistema Avançado
   ├── Schema Registry com Avro em .NET
   ├── Kafka Connect com CDC (Change Data Capture)
   ├── Deploy no Confluent Cloud
   └── Monitoramento e tuning de performance
```

---

## 🛠️ Troubleshooting

### ❌ `Failed to resolve 'kafka:9092'`

O cliente .NET está tentando resolver o hostname `kafka`, que só existe na rede Docker.

**Solução:** confira se `KAFKA_ADVERTISED_LISTENERS` no `docker-compose.yml` tem o listener `EXTERNAL://localhost:9092`. Se mudou recentemente, rode:

```powershell
.\scripts\reset.ps1
```

### ❌ `Conflict. The container name "/kafka" is already in use`

Container órfão de um projeto anterior travando o restart.

**Solução:**

```powershell
.\scripts\reset.ps1
```

Ou manualmente:

```powershell
docker rm -f kafka kafka-ui flink-jobmanager flink-taskmanager
docker compose up -d
```

### ❌ Kafka não fica `healthy`

Verifique os logs:

```powershell
docker logs kafka --tail 50
```

Se houver erro de **metadados corrompidos no volume**, faça reset:

```powershell
.\scripts\stop.ps1 -RemoveVolumes
.\scripts\start.ps1
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
| Kafka UI (Provectus)          | [github.com/provectus/kafka-ui](https://github.com/provectus/kafka-ui)   |
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

## 📌 Como publicar atualizações no GitHub (PowerShell)

```powershell
git add README.md scripts/
git commit -m "docs: README com scripts PowerShell e Flink"
git push origin main
```
