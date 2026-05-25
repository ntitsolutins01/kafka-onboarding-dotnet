# 🧑‍🔬 MANUAL_TEST — Kafka Onboarding POC

Guia de **testes manuais passo-a-passo** da POC de Kafka Onboarding em .NET.
Este documento é o **complemento didático** ao [`AUTOMATIC_TEST.md`](./AUTOMATIC_TEST.md):
aqui você executa **cada peça do pipeline manualmente** para entender como
Producer, Consumer, Kafka e Flink se conectam.

![Kafka](https://img.shields.io/badge/Apache%20Kafka-3.8-231F20?style=for-the-badge&logo=apachekafka&logoColor=white)
![.NET](https://img.shields.io/badge/.NET-8.0-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-7+-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Manual Test](https://img.shields.io/badge/Testes-Manuais_Didáticos-orange?style=for-the-badge&logo=bookstack&logoColor=white)
![Status](https://img.shields.io/badge/Status-Para_Aprendizado-blueviolet?style=for-the-badge)

---

## 📑 Sumário

- [Para quem é este guia?](#-para-quem-é-este-guia)
- [Automático vs. Manual](#-automático-vs-manual-qual-usar)
- [Pré-requisitos](#-pré-requisitos)
- [Roteiro Completo](#-roteiro-completo-do-teste-manual)
- [Etapa 1 — Subir Infraestrutura](#1️⃣-etapa-1--subir-a-infraestrutura)
- [Etapa 2 — Validar Kafka via CLI](#2️⃣-etapa-2--validar-kafka-via-cli)
- [Etapa 3 — Criar Tópicos](#3️⃣-etapa-3--criar-os-tópicos)
- [Etapa 4 — Inspecionar via Kafka UI](#4️⃣-etapa-4--inspecionar-via-kafka-ui)
- [Etapa 5 — Producer Manual via CLI](#5️⃣-etapa-5--producer-manual-via-cli)
- [Etapa 6 — Consumer Manual via CLI](#6️⃣-etapa-6--consumer-manual-via-cli)
- [Etapa 7 — Rodar Consumer .NET](#7️⃣-etapa-7--rodar-o-consumer-net)
- [Etapa 8 — Rodar Producer .NET](#8️⃣-etapa-8--rodar-o-producer-net)
- [Etapa 9 — Monitorar Consumer Lag](#9️⃣-etapa-9--monitorar-consumer-lag)
- [Etapa 10 — Testar a DLQ](#-etapa-10--testar-a-dlq-dead-letter-queue)
- [Etapa 11 — Validar Flink](#1️⃣1️⃣-etapa-11--validar-o-flink)
- [Etapa 12 — Limpar Ambiente](#1️⃣2️⃣-etapa-12--limpar-o-ambiente)
- [Cenários Didáticos Extras](#-cenários-didáticos-extras)
- [Troubleshooting](#-troubleshooting)
- [Checklist de Aprendizado](#-checklist-de-aprendizado)

---

## 🎯 Para quem é este guia?

Este documento é ideal se você:

- 🎓 Está **aprendendo Kafka** e quer entender cada conceito na prática
- 🔍 Quer **inspecionar manualmente** mensagens, partições e offsets
- 🐛 Está **debugando** um cenário específico em isolamento
- 👨‍🏫 Está **ensinando** Kafka para alguém e precisa de um roteiro didático
- 🧪 Quer **testar comportamentos específicos** (DLQ, rebalance, lag, etc.)

> 💡 Se você só quer **rodar a POC rapidinho**, use o [`AUTOMATIC_TEST.md`](./AUTOMATIC_TEST.md).

---

## ⚖️ Automático vs. Manual: qual usar?

| Característica            | 🤖 Automático                    | 🧑‍🔬 Manual                          |
|---------------------------|----------------------------------|---------------------------------------|
| **Tempo**                 | ~60 segundos                     | ~30–60 minutos                        |
| **Aprendizado**           | ⭐⭐                              | ⭐⭐⭐⭐⭐                              |
| **Inspeção de detalhes**  | Limitada                         | Total                                 |
| **Ideal para**            | CI/CD, smoke test, demo          | Estudo, debug, ensino                 |
| **Comando principal**     | `.\scripts\run-poc.ps1`          | Múltiplos comandos passo-a-passo      |
| **Documento de referência** | `AUTOMATIC_TEST.md`            | `MANUAL_TEST.md` (este aqui)          |

---

## ✅ Pré-requisitos

Mesmos do `AUTOMATIC_TEST.md`:

| Ferramenta          | Versão mínima | Verificar com                          |
|---------------------|---------------|-----------------------------------------|
| **Docker Desktop**  | 4.x           | `docker --version`                      |
| **Docker Compose**  | v2            | `docker compose version`                |
| **.NET SDK**        | 8.0+          | `dotnet --version`                      |
| **PowerShell**      | 5.1 ou 7+     | `$PSVersionTable.PSVersion`             |

### 🪟 Abra MÚLTIPLOS terminais

Diferente do modo automático, no teste manual você vai precisar de **vários terminais abertos ao mesmo tempo**:

```text
┌────────────────────────────────────────────────────────────┐
│  Terminal 1 — Comandos gerais (você está aqui)             │
├────────────────────────────────────────────────────────────┤
│  Terminal 2 — Console Producer (Kafka CLI)                 │
├────────────────────────────────────────────────────────────┤
│  Terminal 3 — Console Consumer (Kafka CLI)                 │
├────────────────────────────────────────────────────────────┤
│  Terminal 4 — Consumer .NET                                │
├────────────────────────────────────────────────────────────┤
│  Terminal 5 — Producer .NET                                │
├────────────────────────────────────────────────────────────┤
│  Terminal 6 — Monitor de Lag                               │
└────────────────────────────────────────────────────────────┘
```

> 💡 **Dica:** use **Windows Terminal** com abas para organizar melhor.

---

## 🗺️ Roteiro Completo do Teste Manual

```text
   ┌──────────────────────────────┐
   │ 1. Subir infraestrutura       │ docker compose up
   └────────────┬─────────────────┘
                │
   ┌────────────▼─────────────────┐
   │ 2. Validar Kafka via CLI      │ docker exec
   └────────────┬─────────────────┘
                │
   ┌────────────▼─────────────────┐
   │ 3. Criar tópicos              │ kafka-topics.sh
   └────────────┬─────────────────┘
                │
   ┌────────────▼─────────────────┐
   │ 4. Inspecionar via Kafka UI   │ http://localhost:8080
   └────────────┬─────────────────┘
                │
   ┌────────────▼─────────────────┐
   │ 5. Producer manual (CLI)      │ kafka-console-producer
   └────────────┬─────────────────┘
                │
   ┌────────────▼─────────────────┐
   │ 6. Consumer manual (CLI)      │ kafka-console-consumer
   └────────────┬─────────────────┘
                │
   ┌────────────▼─────────────────┐
   │ 7. Rodar consumer .NET        │ dotnet run
   └────────────┬─────────────────┘
                │
   ┌────────────▼─────────────────┐
   │ 8. Rodar producer .NET        │ dotnet run
   └────────────┬─────────────────┘
                │
   ┌────────────▼─────────────────┐
   │ 9. Monitorar consumer lag     │ kafka-consumer-groups.sh
   └────────────┬─────────────────┘
                │
   ┌────────────▼─────────────────┐
   │ 10. Testar DLQ                │ envio de mensagem inválida
   └────────────┬─────────────────┘
                │
   ┌────────────▼─────────────────┐
   │ 11. Validar Flink             │ http://localhost:8081
   └────────────┬─────────────────┘
                │
   ┌────────────▼─────────────────┐
   │ 12. Limpar ambiente           │ docker compose down -v
   └──────────────────────────────┘
```

---

## 1️⃣ Etapa 1 — Subir a infraestrutura

### 🎯 Objetivo
Iniciar Kafka, Kafka UI e Flink sem usar o script automático.

### 📋 Comandos

```powershell
# Navegue para a raiz do projeto
cd C:\Projetos\POCs\kafka-onboarding-dotnet\KafkaOnboarding

# Suba os containers em background
docker compose up -d

# Acompanhe os logs em tempo real (Ctrl+C para sair sem parar containers)
docker compose logs -f kafka
```

### ✔️ Validação

```powershell
# Liste containers — todos devem estar "Up" e Kafka "(healthy)"
docker ps

# Output esperado:
# CONTAINER ID   IMAGE                            STATUS                   PORTS
# abc123         apache/kafka:3.8.0               Up 30s (healthy)         0.0.0.0:9092->9092/tcp
# def456         provectuslabs/kafka-ui:latest    Up 30s                   0.0.0.0:8080->8080/tcp
# ghi789         flink:1.19-scala_2.12            Up 30s                   0.0.0.0:8081->8081/tcp
# jkl012         flink:1.19-scala_2.12            Up 30s
```

### 🧠 O que aprender aqui

- 🔍 **Health-check em ação**: o Kafka só fica "healthy" após inicializar completamente
- 🔌 **Mapeamento de portas**: `9092` (host) → `9092` (container) para clientes externos
- 🌐 **Rede Docker**: containers se comunicam por nome (`kafka:29092`), host usa `localhost:9092`

---

## 2️⃣ Etapa 2 — Validar Kafka via CLI

### 🎯 Objetivo
Confirmar que o broker está respondendo executando comandos **dentro do container**.

### 📋 Comandos

```powershell
# Entrar no container Kafka (shell interativo)
docker exec -it kafka bash

# Dentro do container, validar versão do Kafka
/opt/kafka/bin/kafka-topics.sh --version

# Listar tópicos (deve estar vazio nesta primeira execução)
/opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:29092 --list

# Sair do container
exit
```

### ✔️ Validação

Saída esperada do `--list`:
```
__consumer_offsets   (pode aparecer ou não — é interno)
```

### 🧠 O que aprender aqui

- 🐳 **`docker exec`** permite rodar comandos dentro de containers em execução
- 🔌 **`localhost:29092`** dentro do container = listener INTERNAL
- 📋 **`__consumer_offsets`** é o tópico interno onde Kafka armazena offsets dos consumers

---

## 3️⃣ Etapa 3 — Criar os tópicos

### 🎯 Objetivo
Criar manualmente os tópicos `onboarding-events` e `onboarding-events-dlq` com 3 partições.

### 📋 Comandos

```powershell
# Criar tópico principal
docker exec kafka /opt/kafka/bin/kafka-topics.sh `
    --bootstrap-server localhost:29092 `
    --create `
    --topic onboarding-events `
    --partitions 3 `
    --replication-factor 1

# Criar tópico DLQ (Dead Letter Queue)
docker exec kafka /opt/kafka/bin/kafka-topics.sh `
    --bootstrap-server localhost:29092 `
    --create `
    --topic onboarding-events-dlq `
    --partitions 3 `
    --replication-factor 1
```

### ✔️ Validação

```powershell
# Listar todos os tópicos
docker exec kafka /opt/kafka/bin/kafka-topics.sh `
    --bootstrap-server localhost:29092 `
    --list

# Descrever o tópico em detalhes
docker exec kafka /opt/kafka/bin/kafka-topics.sh `
    --bootstrap-server localhost:29092 `
    --describe `
    --topic onboarding-events
```

Saída esperada do `--describe`:
```
Topic: onboarding-events   PartitionCount: 3   ReplicationFactor: 1
    Topic: onboarding-events   Partition: 0   Leader: 1   Replicas: 1   Isr: 1
    Topic: onboarding-events   Partition: 1   Leader: 1   Replicas: 1   Isr: 1
    Topic: onboarding-events   Partition: 2   Leader: 1   Replicas: 1   Isr: 1
```

### 🧠 O que aprender aqui

- 🔢 **Partições** definem o paralelismo máximo de consumo
- 📋 **Replication factor = 1** = sem tolerância a falhas (POC apenas!)
- 👑 **Leader** = broker responsável por escritas/leituras daquela partição
- 🔄 **ISR (In-Sync Replicas)** = réplicas atualizadas com o leader

---

## 4️⃣ Etapa 4 — Inspecionar via Kafka UI

### 🎯 Objetivo
Visualizar a infraestrutura através de uma interface gráfica.

### 📋 Passos

1. Abra o navegador em **http://localhost:8080**
2. Navegue até **Brokers** → confirme que existe 1 broker (ID = 1, ou similar)
3. Vá para **Topics** → verifique que `onboarding-events` e `onboarding-events-dlq` estão listados
4. Clique em `onboarding-events` → aba **Partitions** → confirme 3 partições

### ✔️ Validação visual

- [ ] 1 broker UP com status verde
- [ ] 2 tópicos listados
- [ ] Cada tópico com 3 partições
- [ ] Cada partição com offset = 0 (nenhuma mensagem ainda)

### 🧠 O que aprender aqui

- 🖥️ **Kafka UI** é uma alternativa gráfica ao CLI — facilita a visualização
- 📊 **Métricas em tempo real** podem ser monitoradas pela interface
- 🎯 É ótimo para **demos** e **onboarding** de novos devs no time

---

## 5️⃣ Etapa 5 — Producer manual via CLI

### 🎯 Objetivo
Enviar mensagens manualmente para o Kafka usando a CLI nativa, sem código .NET.

### 📋 Comandos

**Terminal 2:**

```powershell
# Iniciar producer interativo
docker exec -it kafka /opt/kafka/bin/kafka-console-producer.sh `
    --bootstrap-server localhost:29092 `
    --topic onboarding-events `
    --property "parse.key=true" `
    --property "key.separator=:"
```

O console fica aguardando entrada. Digite mensagens no formato `chave:valor`:

```
CUST-001:{"customerId":"001","status":"PENDING","timestamp":"2026-05-24T22:00:00Z"}
CUST-002:{"customerId":"002","status":"APPROVED","timestamp":"2026-05-24T22:01:00Z"}
CUST-003:{"customerId":"003","status":"REJECTED","timestamp":"2026-05-24T22:02:00Z"}
```

Pressione **Ctrl+C** para sair quando terminar.

### ✔️ Validação

Vá para o Kafka UI → `onboarding-events` → **Messages** → veja as 3 mensagens enviadas.

### 🧠 O que aprender aqui

- 📨 **Mensagens Kafka** têm `key`, `value`, `timestamp` e `headers`
- 🎯 **Chave determina a partição** via hash (key → partition)
- 🔄 Mesma chave **sempre** vai para a mesma partição (garante ordenação por chave)

---

## 6️⃣ Etapa 6 — Consumer manual via CLI

### 🎯 Objetivo
Ler mensagens manualmente do Kafka usando a CLI nativa.

### 📋 Comandos

**Terminal 3:**

```powershell
# Consumir do início (todas as mensagens existentes)
docker exec -it kafka /opt/kafka/bin/kafka-console-consumer.sh `
    --bootstrap-server localhost:29092 `
    --topic onboarding-events `
    --from-beginning `
    --property "print.key=true" `
    --property "key.separator= | "
```

### ✔️ Validação

Você verá as mensagens enviadas na etapa anterior:
```
CUST-001 | {"customerId":"001","status":"PENDING",...}
CUST-002 | {"customerId":"002","status":"APPROVED",...}
CUST-003 | {"customerId":"003","status":"REJECTED",...}
```

### 🧪 Experimento

1. **Deixe o consumer rodando**
2. Volte ao Terminal 2 (producer) e envie **mais mensagens**
3. Observe que o consumer recebe em tempo real ⚡

### 🧠 O que aprender aqui

- 📥 **`--from-beginning`** lê do offset 0 (todas as mensagens históricas)
- 🔄 Sem essa flag, o consumer só lê mensagens **novas** (auto.offset.reset=latest)
- 👥 Sem `--group`, cada consumer recebe **todas** as mensagens (broadcast)

---

## 7️⃣ Etapa 7 — Rodar o consumer .NET

### 🎯 Objetivo
Substituir o consumer CLI pelo consumer .NET deste projeto.

### 📋 Comandos

**Terminal 4:**

```powershell
# Pare o consumer CLI da etapa anterior (Ctrl+C)

# Navegue até o projeto consumer
cd C:\Projetos\POCs\kafka-onboarding-dotnet\KafkaOnboarding\src\KafkaOnboarding.Consumer

# Rode o consumer
dotnet run
```

### ✔️ Validação

Saída esperada:
```
CONSUMER - Processando onboarding-events
[INFO] Conectado ao broker localhost:9092
[INFO] Subscrito ao tópico onboarding-events
[INFO] Consumer group: onboarding-processor
[INFO] Aguardando mensagens...
```

### 🧠 O que aprender aqui

- 👥 **Consumer group** (`onboarding-processor`) permite **paralelismo** entre instâncias
- 💾 **Commit de offsets** é manual (controlado pelo código)
- 🔄 Se você matar o consumer e subir de novo, ele **retoma do último offset commitado**

---

## 8️⃣ Etapa 8 — Rodar o producer .NET

### 🎯 Objetivo
Disparar mensagens via aplicação .NET enquanto observa o consumer processando.

### 📋 Comandos

**Terminal 5:**

```powershell
# Navegue até o projeto producer
cd C:\Projetos\POCs\kafka-onboarding-dotnet\KafkaOnboarding\src\KafkaOnboarding.Producer

# Rode o producer
dotnet run
```

### ✔️ Validação

**Terminal 5 (Producer):**
```
PRODUCER - Enviando eventos
[OK] Enviado: customer-001 -> partition 0, offset 4
[OK] Enviado: customer-002 -> partition 2, offset 3
[OK] Enviado: customer-003 -> partition 1, offset 3
...
```

**Terminal 4 (Consumer) — em tempo real:**
```
[partition 0] Recebido: customer-001
[partition 2] Recebido: customer-002
[partition 1] Recebido: customer-003
...
```

### 🧠 O que aprender aqui

- 🚀 **Producer e Consumer .NET** usam o pacote `Confluent.Kafka`
- 🎯 **Particionamento por chave**: clientes diferentes vão para partições diferentes
- ⚡ **Acks.All + Idempotence** garantem entrega exatamente-uma-vez

---

## 9️⃣ Etapa 9 — Monitorar consumer lag

### 🎯 Objetivo
Acompanhar em tempo real quanto o consumer está "atrasado" em relação ao producer.

### 📋 Comandos

**Terminal 6:**

```powershell
# Descrever o consumer group (snapshot único)
docker exec kafka /opt/kafka/bin/kafka-consumer-groups.sh `
    --bootstrap-server localhost:29092 `
    --group onboarding-processor `
    --describe

# Modo monitor (atualiza a cada 2 segundos)
while ($true) {
    Clear-Host
    docker exec kafka /opt/kafka/bin/kafka-consumer-groups.sh `
        --bootstrap-server localhost:29092 `
        --group onboarding-processor `
        --describe
    Start-Sleep 2
}
```

### ✔️ Validação

Saída esperada:
```
GROUP                  TOPIC               PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG
onboarding-processor   onboarding-events   0          15              15              0
onboarding-processor   onboarding-events   1          12              12              0
onboarding-processor   onboarding-events   2          18              18              0
```

### 🧪 Experimento de lag

1. **Pare o consumer .NET** (Terminal 4 — Ctrl+C)
2. **Envie mais mensagens** pelo producer (Terminal 5)
3. Observe o **LAG aumentando** no Terminal 6
4. **Suba o consumer novamente** → veja o LAG zerar conforme processa

### 🧠 O que aprender aqui

- 📊 **LAG = LOG-END-OFFSET − CURRENT-OFFSET**
- 🔴 **LAG crescente** = consumer não consegue acompanhar o producer
- ✅ **LAG estável próximo de 0** = sistema saudável
- 🎯 É a métrica **mais importante** para monitorar em produção

---

## 🔟 Etapa 10 — Testar a DLQ (Dead Letter Queue)

### 🎯 Objetivo
Validar que mensagens malformadas vão para o tópico DLQ ao invés de travar o consumer.

### 📋 Comandos

**Terminal 2:**

```powershell
# Envie uma mensagem com JSON inválido
docker exec -it kafka /opt/kafka/bin/kafka-console-producer.sh `
    --bootstrap-server localhost:29092 `
    --topic onboarding-events `
    --property "parse.key=true" `
    --property "key.separator=:"
```

Digite:
```
CUST-BAD:{"isso nao eh um JSON valido}
```

### ✔️ Validação

**Terminal 4 (Consumer .NET):**
```
[ERROR] Falha ao processar mensagem customer-key: CUST-BAD
[INFO] Enviando para DLQ: onboarding-events-dlq
[OK] Mensagem encaminhada para DLQ com sucesso
```

**Verificar conteúdo da DLQ:**
```powershell
docker exec -it kafka /opt/kafka/bin/kafka-console-consumer.sh `
    --bootstrap-server localhost:29092 `
    --topic onboarding-events-dlq `
    --from-beginning `
    --property "print.key=true" `
    --property "print.headers=true"
```

Você verá a mensagem inválida lá, com **headers de erro** indicando o motivo da falha.

### 🧠 O que aprender aqui

- 🛡️ **DLQ é um padrão fundamental** em arquiteturas event-driven
- 🚫 **Sem DLQ**, uma mensagem ruim **bloqueia o consumer** (poison pill)
- 📋 **Headers de erro** ajudam no debug posterior (exception, stack trace, timestamp)
- 🔄 **Mensagens em DLQ** podem ser **reprocessadas** após correção

---

## 1️⃣1️⃣ Etapa 11 — Validar o Flink

### 🎯 Objetivo
Confirmar que o Flink JobManager e TaskManager estão ativos e prontos.

### 📋 Passos

1. Abra **http://localhost:8081** no navegador
2. Verifique na **Overview**:
   - ✅ Taskmanagers: 1
   - ✅ Total Task Slots: 1 (ou mais)
   - ✅ Available Task Slots: ≥ 1
   - ✅ Running Jobs: 0 (ainda não submetemos nenhum)

### ✔️ Validação via API

```powershell
# Status do cluster Flink
curl http://localhost:8081/overview

# Lista de TaskManagers
curl http://localhost:8081/taskmanagers
```

### 🧠 O que aprender aqui

- 🌊 **Flink** é um processador de streams que **consome do Kafka**
- 🎯 **JobManager** = coordenador (recebe jobs, distribui tarefas)
- ⚙️ **TaskManager** = worker (executa as tarefas em paralelo)
- 🧩 **Task Slots** = unidades de paralelismo disponíveis

> 📌 Esta POC ainda **não submete jobs Flink** — é um próximo passo do roadmap.

---

## 1️⃣2️⃣ Etapa 12 — Limpar o ambiente

### 🎯 Objetivo
Parar tudo e (opcionalmente) limpar dados para começar do zero.

### 📋 Comandos

```powershell
# Pare todos os processos .NET (Terminais 4 e 5 — Ctrl+C)

# Pare os containers preservando volumes
docker compose down

# OU pare e apague todos os dados
docker compose down -v
```

### ✔️ Validação

```powershell
# Confirme que nenhum container do projeto está rodando
docker ps --filter "name=kafka"
docker ps --filter "name=flink"

# Saída esperada: nenhum resultado
```

### 🧠 O que aprender aqui

- 💾 **`down` sem `-v`** preserva os volumes → mensagens permanecem após restart
- 🗑️ **`down -v`** apaga TUDO → reset completo (use em dúvida)
- 🧹 É boa prática **sempre limpar** após testes locais para liberar recursos

---

## 🎓 Cenários Didáticos Extras

### 🔄 Cenário A — Rebalance de partições

**Objetivo:** observar o que acontece quando uma nova instância do consumer entra no grupo.

```powershell
# Terminal 4: rode 1 instância do consumer
cd .\src\KafkaOnboarding.Consumer
dotnet run

# Terminal 7: rode UMA SEGUNDA instância
cd .\src\KafkaOnboarding.Consumer
dotnet run

# Terminal 5: dispare o producer
cd .\src\KafkaOnboarding.Producer
dotnet run
```

**O que observar:**
- 🔄 Logs de **rebalance** quando a 2ª instância entra
- 🎯 Partições são **redistribuídas** entre as 2 instâncias
- ⚡ Throughput **dobra** (paralelismo real)

### 🎯 Cenário B — Ordenação por chave

**Objetivo:** provar que mensagens com a **mesma chave** vão sempre para a **mesma partição**.

```powershell
# Envie 5 mensagens com a mesma chave
docker exec -it kafka /opt/kafka/bin/kafka-console-producer.sh `
    --bootstrap-server localhost:29092 `
    --topic onboarding-events `
    --property "parse.key=true" `
    --property "key.separator=:"
```

Digite (mesma chave 5x):
```
CUST-999:{"event":"step1"}
CUST-999:{"event":"step2"}
CUST-999:{"event":"step3"}
CUST-999:{"event":"step4"}
CUST-999:{"event":"step5"}
```

**O que observar:** no Kafka UI, todas as 5 mensagens estarão na **mesma partição** → ordenação preservada para essa chave.

### 🔥 Cenário C — Resiliência (kill broker)

**Objetivo:** ver o que acontece quando o broker cai durante o processamento.

```powershell
# Mate o container Kafka
docker stop kafka

# Veja o consumer .NET tentando reconectar
# (logs de erro no Terminal 4)

# Suba o broker novamente
docker start kafka

# Veja o consumer reconectar automaticamente
```

**O que aprender:** clientes Kafka têm **retry automático** e **reconexão transparente**.

### 📈 Cenário D — Replay de mensagens

**Objetivo:** reprocessar todas as mensagens históricas do tópico.

```powershell
# Resete o offset do consumer group para o início
docker exec kafka /opt/kafka/bin/kafka-consumer-groups.sh `
    --bootstrap-server localhost:29092 `
    --group onboarding-processor `
    --topic onboarding-events `
    --reset-offsets `
    --to-earliest `
    --execute

# Suba o consumer .NET novamente
cd .\src\KafkaOnboarding.Consumer
dotnet run
```

**O que aprender:** Kafka **retém mensagens** por tempo configurável (padrão: 7 dias) — você pode "voltar no tempo".

---

## 🔍 Troubleshooting

### ❌ "Connection refused" ao tentar producer/consumer .NET

**Causa:** Kafka ainda não está totalmente pronto (health-check pendente).

**Solução:**
```powershell
# Aguarde o health-check
docker inspect -f '{{.State.Health.Status}}' kafka
# Espere até retornar "healthy"
```

### ❌ Comando `docker exec` falha com "container not running"

**Causa:** container Kafka não está ativo.

**Solução:**
```powershell
docker ps -a | Select-String kafka
docker start kafka
docker logs kafka --tail 50
```

### ❌ Kafka UI mostra "Cluster offline"

**Causa:** Kafka UI subiu **antes** do Kafka estar pronto.

**Solução:**
```powershell
docker restart kafka-ui
```

### ❌ Mensagens enviadas mas consumer não recebe

**Causa:** consumer com `auto.offset.reset=latest` e mensagens enviadas **antes** dele subir.

**Solução:**
```powershell
# Reset do offset para o início
docker exec kafka /opt/kafka/bin/kafka-consumer-groups.sh `
    --bootstrap-server localhost:29092 `
    --group onboarding-processor `
    --topic onboarding-events `
    --reset-offsets --to-earliest --execute
```

### ❌ `dotnet run` falha com "could not find project"

**Causa:** você não está na pasta certa.

**Solução:**
```powershell
cd C:\Projetos\POCs\kafka-onboarding-dotnet\KafkaOnboarding\src\KafkaOnboarding.Consumer
Get-ChildItem *.csproj   # confirma que o csproj está aqui
dotnet run
```

> 📌 **Mais erros?** Veja a seção [Troubleshooting do AUTOMATIC_TEST.md](./AUTOMATIC_TEST.md#-troubleshooting).

---

## ✅ Checklist de Aprendizado

Marque conforme avança:

### 🏗️ Infraestrutura
- [ ] Entendi a diferença entre listeners INTERNAL e EXTERNAL
- [ ] Sei como inspecionar containers com `docker exec`
- [ ] Consigo subir/parar a infra manualmente

### 📨 Producer/Consumer
- [ ] Enviei mensagens via CLI (`kafka-console-producer`)
- [ ] Consumi mensagens via CLI (`kafka-console-consumer`)
- [ ] Rodei o producer .NET com sucesso
- [ ] Rodei o consumer .NET com sucesso
- [ ] Entendi o papel da **chave** no particionamento

### 📊 Observabilidade
- [ ] Naveguei pelo Kafka UI (Brokers, Topics, Messages)
- [ ] Monitorei o LAG via CLI
- [ ] Consegui interpretar o output do `kafka-consumer-groups.sh`

### 🛡️ Resiliência
- [ ] Testei a DLQ enviando mensagem inválida
- [ ] Vi o consumer reconectar após kill do broker
- [ ] Fiz replay de mensagens com reset de offset

### 🎓 Conceitos Avançados
- [ ] Observei rebalance ao subir 2ª instância de consumer
- [ ] Validei que chave determina partição (ordenação)
- [ ] Entendi a relação entre Flink JM e TM (mesmo sem job submetido)

---

## 📌 Notas Importantes

- ⚠️ Esta POC usa **replication-factor = 1** → **NUNCA** em produção
- 🔒 Não há **autenticação/TLS** configurados — apenas para localhost
- 🎓 O teste manual é **3x mais demorado** que o automático, mas ensina **10x mais**
- 💡 Combine teste manual + leitura do código fonte para máximo aprendizado
- 📚 Após dominar este guia, leia a [documentação oficial do Kafka](https://kafka.apache.org/documentation/)

---

## 🔗 Documentos Relacionados

- 📖 [README.md](./README.md) — Visão geral do projeto
- 🤖 [AUTOMATIC_TEST.md](./AUTOMATIC_TEST.md) — Versão automatizada deste teste
- 🤝 [CONTRIBUTING.md](./CONTRIBUTING.md) — Como contribuir
- 📜 [LICENSE](./LICENSE) — Licença MIT

---

## 🆘 Precisa de ajuda?

- 💬 Abra uma [Discussion](https://github.com/ntitsolutins01/kafka-onboarding-dotnet/discussions) no GitHub
- 🐛 Abra uma [Issue](https://github.com/ntitsolutins01/kafka-onboarding-dotnet/issues) se for bug
- 📧 Contate via [LinkedIn](https://www.linkedin.com/in/fabiomunizdeveloper/)

---

**Projeto:** Kafka Onboarding .NET POC
**Última atualização:** 24/05/2026
**Mantenedor:** Fábio Muniz

---

> *"Diga-me e eu esquecerei. Mostre-me e talvez eu lembre. Envolva-me e eu compreenderei."*
> — **Confúcio**
