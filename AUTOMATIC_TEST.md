# 🧪 AUTOMATIC_TEST — Kafka Onboarding POC

Guia completo de **testes end-to-end automatizados** da POC de Kafka Onboarding em .NET.
Este documento descreve **como rodar**, **o que esperar** e **como validar** o pipeline
completo (Producer → Kafka → Consumer + DLQ + Monitor).

![Kafka](https://img.shields.io/badge/Apache%20Kafka-3.8-231F20?style=for-the-badge&logo=apachekafka&logoColor=white)
![.NET](https://img.shields.io/badge/.NET-8.0-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-7+-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Tests](https://img.shields.io/badge/Testes-E2E_Automatizados-success?style=for-the-badge&logo=testinglibrary&logoColor=white)
![Status](https://img.shields.io/badge/Status-Pronto_para_Uso-green?style=for-the-badge)

---

## 📑 Sumário

- [Pré-requisitos](#-pré-requisitos)
- [Arquitetura](#️-arquitetura)
- [Quick Start](#-quick-start-tldr)
- [Scripts Disponíveis](#-scripts-disponíveis)
- [Fluxo Automatizado de Testes](#-fluxo-automatizado-de-testes)
- [Validações Esperadas](#️-validações-esperadas)
- [Checklist de Critérios de Sucesso](#-checklist-de-critérios-de-sucesso)
- [Troubleshooting](#-troubleshooting)
- [Teardown (Desligar Tudo)](#-teardown-desligar-tudo)
- [Métricas e Observabilidade](#-métricas-e-observabilidade)
- [Reset Completo (Smoke Test Limpo)](#-reset-completo-smoke-test-limpo)
- [Exemplo de Execução Bem-Sucedida](#-exemplo-de-execução-bem-sucedida)
- [Contribuindo com Novos Cenários](#-contribuindo-com-novos-cenários-de-teste)

---

## ✅ Pré-requisitos

| Ferramenta          | Versão mínima | Como verificar                          |
|---------------------|---------------|------------------------------------------|
| **Docker Desktop**  | 4.x           | `docker --version`                       |
| **Docker Compose**  | v2            | `docker compose version`                 |
| **.NET SDK**        | 8.0+          | `dotnet --version`                       |
| **PowerShell**      | 5.1 ou 7+     | `$PSVersionTable.PSVersion`              |
| **Portas livres**   | 8080, 8081, 9092 | `Test-NetConnection localhost -Port 9092` |

> 💡 **PowerShell 7+ (pwsh) é recomendado** — o orquestrador detecta automaticamente.

### 🔓 Liberar execução de scripts (1ª vez)

Por padrão o Windows bloqueia scripts `.ps1`. Rode **uma única vez**:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

Confirme com `S`. Isso libera scripts locais apenas para o seu usuário.

---

## 🏗️ Arquitetura

```text
┌───────────────┐      ┌──────────────────┐      ┌───────────────┐
│   PRODUCER    │─────▶│  onboarding-     │─────▶│   CONSUMER    │
│   (.NET)      │      │  events (3 part) │      │   (.NET)      │
└───────────────┘      └──────────────────┘      └───────┬───────┘
                                                         │ erro?
                                                         ▼
                              ┌──────────────────────────────────┐
                              │  onboarding-events-dlq (3 part)  │
                              └──────────────────────────────────┘

┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│   Kafka      │   │   Kafka UI   │   │   Flink JM   │   │   Flink TM   │
│ :9092 / :29092│  │    :8080     │   │    :8081     │   │  (worker)    │
└──────────────┘   └──────────────┘   └──────────────┘   └──────────────┘
```

### 🔌 Listeners explicados

| Listener | Endereço | Usado por |
|----------|----------|-----------|
| **INTERNAL** | `kafka:29092` | Containers (Flink, Kafka UI) |
| **EXTERNAL** | `localhost:9092` | App .NET rodando no host |

---

## ⚡ Quick Start (TL;DR)

```powershell
# 1. Clone ou navegue até a pasta do projeto
cd C:\Projetos\POCs\kafka-onboarding-dotnet\KafkaOnboarding

# 2. Rode o teste end-to-end completo
.\scripts\run-poc.ps1

# 3. Quando terminar de validar
.\scripts\99-stop-all.ps1
```

O orquestrador `run-poc.ps1` faz **tudo automaticamente**:
1. Sobe a infraestrutura Docker
2. Valida health-check do Kafka
3. Cria os tópicos
4. Abre 3 janelas (Consumer, Monitor, Producer)

---

## 📂 Scripts Disponíveis

Todos os scripts ficam em `.\scripts\` e são **idempotentes** (podem rodar várias vezes sem efeito colateral).

| Script                       | Função                                          | Tempo médio |
|------------------------------|--------------------------------------------------|-------------|
| `01-start-infra.ps1`         | Sobe containers + valida health Kafka + porta 9092 | ~30s      |
| `02-create-topics.ps1`       | Cria/verifica `onboarding-events` e DLQ         | ~3s         |
| `03-run-consumer.ps1`        | Inicia o consumer .NET                          | contínuo    |
| `04-run-producer.ps1`        | Envia eventos de teste                          | ~10–30s     |
| `05-monitor.ps1`             | Monitora LAG do consumer group (refresh 2s)     | contínuo    |
| `99-stop-all.ps1`            | Para containers (opcional: limpa volumes)       | ~5s         |
| `run-poc.ps1`                | **Orquestrador end-to-end**                     | ~60s        |

### 🔁 Execução manual (modo passo-a-passo)

Quer entender cada etapa? Rode separadamente em terminais diferentes:

```powershell
# Terminal 1 — Infraestrutura
.\scripts\01-start-infra.ps1
.\scripts\02-create-topics.ps1

# Terminal 2 — Consumer (deixa rodando)
.\scripts\03-run-consumer.ps1

# Terminal 3 — Monitor (deixa rodando)
.\scripts\05-monitor.ps1

# Terminal 4 — Producer (dispara o teste)
.\scripts\04-run-producer.ps1
```

---

## 🔄 Fluxo Automatizado de Testes

```
   ┌──────────────────────────┐
   │ [1/5] 01-start-infra     │  Docker compose up
   │       └─ healthcheck     │  Aguarda kafka healthy + porta 9092
   └────────────┬─────────────┘
                │
   ┌────────────▼─────────────┐
   │ [2/5] 02-create-topics   │  kafka-topics.sh --create
   │       ├─ onboarding-events     (3 partições)
   │       └─ onboarding-events-dlq (3 partições)
   └────────────┬─────────────┘
                │
   ┌────────────▼─────────────┐
   │ [3/5] Abre CONSUMER      │  Start-Process pwsh -NoExit
   │       (aguarda 15s)      │  Tempo de subscribe + rebalance
   └────────────┬─────────────┘
                │
   ┌────────────▼─────────────┐
   │ [4/5] Abre MONITOR       │  Refresh 2s do consumer-groups
   └────────────┬─────────────┘
                │
   ┌────────────▼─────────────┐
   │ [5/5] Abre PRODUCER      │  Envia N eventos
   │       └─ mantém aberto   │  ReadKey para inspeção visual
   └──────────────────────────┘
```

---

## ✔️ Validações Esperadas

### 🟢 Janela CONSUMER

```
CONSUMER - Processando onboarding-events
[partition X] Recebido: { customerId: ..., status: ... }
[partition Y] Processado com sucesso
```

### 🟡 Janela MONITOR (refresh a cada 2s)

```
GROUP                  TOPIC               PARTITION  CURRENT-OFFSET  LAG
onboarding-processor   onboarding-events   0          XX              0
onboarding-processor   onboarding-events   1          XX              0
onboarding-processor   onboarding-events   2          XX              0
```

> 📌 **LAG = 0** em todas as partições = consumer processando em tempo real.

### 🚦 Interpretação do Consumer Lag

| LAG observado    | Significado                            |
|------------------|----------------------------------------|
| `0`              | ✅ Consumer caught up — saudável        |
| `< 100`          | ✅ Processamento normal                 |
| `100 — 1.000`    | ⚠️ Investigar throughput               |
| `> 1.000` crescendo | 🔴 Consumer não consegue acompanhar |

### 🔵 Janela PRODUCER

```
PRODUCER - Enviando eventos
[OK] Enviado: customer-001 -> partition 0, offset 0
[OK] Enviado: customer-002 -> partition 2, offset 0
[OK] Enviado: customer-003 -> partition 1, offset 0
...
[OK] Producer finalizado. Pressione qualquer tecla para fechar...
```

### 🌐 Kafka UI — http://localhost:8080

Validar manualmente:
- [ ] **Brokers** → 1 broker UP
- [ ] **Topics** → `onboarding-events` e `onboarding-events-dlq` listados
- [ ] **Topics → onboarding-events → Messages** → mensagens visíveis
- [ ] **Consumers** → `onboarding-processor` ativo com LAG baixo/zero
- [ ] **Topics → onboarding-events → Partitions** → 3 partições com offsets > 0

### 🌐 Flink UI — http://localhost:8081

- [ ] **Overview** → 1 TaskManager registrado
- [ ] **Available Task Slots** ≥ 1

---

## 🧪 Checklist de Critérios de Sucesso

Marque conforme valida:

- [ ] ✅ `01-start-infra.ps1` finalizou sem erros
- [ ] ✅ Container Kafka com status `healthy`
- [ ] ✅ Porta 9092 acessível do host (`Test-NetConnection`)
- [ ] ✅ Tópicos `onboarding-events` e `onboarding-events-dlq` criados
- [ ] ✅ Consumer iniciou e fez subscribe no grupo `onboarding-processor`
- [ ] ✅ Producer enviou pelo menos 1 evento para cada partição (0, 1, 2)
- [ ] ✅ Consumer processou todas as mensagens enviadas
- [ ] ✅ Monitor mostra `LAG = 0` após producer finalizar
- [ ] ✅ Kafka UI mostra mensagens nas partições
- [ ] ✅ `99-stop-all.ps1` removeu containers sem erro

---

## 🔍 Troubleshooting

### ❌ "Cannot find path" ao rodar scripts

**Causa:** PowerShell sem permissão de execução.

**Solução:**
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### ❌ "Porta 9092 não responde"

**Causa:** Outro processo ocupando a porta.

**Solução:**
```powershell
# Descobre quem está usando a porta
Get-NetTCPConnection -LocalPort 9092 | Select-Object OwningProcess
Get-Process -Id <PID>
```

### ❌ "Container Kafka unhealthy"

**Causa:** Memória insuficiente no Docker ou conflito de rede.

**Solução:**
```powershell
docker logs kafka --tail 50
docker compose down -v
docker compose up -d
```

### ❌ Consumer não recebe mensagens

**Causa:** Consumer subiu **depois** do producer com `auto.offset.reset=latest`.

**Solução:** Garanta que o consumer suba **antes** do producer (o `run-poc.ps1` cuida disso com `Start-Sleep 15`).

### ❌ Caracteres estranhos no terminal (`\`, `\"`, `²`)

**Causa:** Encoding do PowerShell não está em UTF-8.

**Solução:** No início da sessão:
```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
```

### ❌ LAG crescendo continuamente

**Causa:** Consumer lento ou travado.

**Diagnóstico:**
```powershell
# Inspeciona consumer group
docker exec kafka /opt/kafka/bin/kafka-consumer-groups.sh `
    --bootstrap-server localhost:29092 `
    --group onboarding-processor `
    --describe
```

Veja também throughput no Kafka UI → Topics → `onboarding-events` → Messages.

### ❌ `Conflict. The container name "/kafka" is already in use`

**Causa:** Container órfão de execução anterior.

**Solução:**
```powershell
.\scripts\99-stop-all.ps1   # responda "S" para apagar volumes
.\scripts\run-poc.ps1
```

Ou manualmente:
```powershell
docker rm -f kafka kafka-ui flink-jobmanager flink-taskmanager
.\scripts\01-start-infra.ps1
```

### ❌ `Failed to resolve 'kafka:9092'`

**Causa:** Cliente .NET tentando resolver hostname `kafka`, que só existe na rede Docker.

**Solução:** Confira se `KAFKA_ADVERTISED_LISTENERS` no `docker-compose.yml` tem `EXTERNAL://localhost:9092`. Se mudou recentemente:
```powershell
.\scripts\99-stop-all.ps1   # responda "S"
.\scripts\run-poc.ps1
```

---

## 🛑 Teardown (Desligar Tudo)

### Parar preservando dados (volumes mantidos)

```powershell
.\scripts\99-stop-all.ps1
# Responda "N" quando perguntar sobre volumes
```

### Parar apagando TUDO (reset completo)

```powershell
.\scripts\99-stop-all.ps1
# Responda "S" quando perguntar sobre volumes
```

### Parar manualmente (sem script)

```powershell
docker compose down          # mantém volumes
docker compose down -v       # remove volumes também
```

---

## 📊 Métricas e Observabilidade

| Métrica                 | Onde ver                                  |
|-------------------------|-------------------------------------------|
| **Consumer Lag**        | `.\scripts\05-monitor.ps1` ou Kafka UI    |
| **Throughput (msg/s)**  | Kafka UI → Topic → Overview               |
| **Partição balance**    | Kafka UI → Topic → Partitions             |
| **Mensagens em DLQ**    | Kafka UI → `onboarding-events-dlq`        |
| **Flink Slots**         | http://localhost:8081 → Overview          |
| **Saúde dos containers**| `docker ps --filter "name=kafka"`         |
| **Uso de recursos**     | `docker stats`                            |

---

## 🔁 Reset Completo (Smoke Test Limpo)

Para garantir um teste 100% limpo:

```powershell
# 1. Apaga tudo
.\scripts\99-stop-all.ps1   # responda "S" para apagar volumes

# 2. Remove imagens (opcional, limpa mais fundo)
docker rmi apache/kafka:3.8.0 provectuslabs/kafka-ui:latest flink:1.19-scala_2.12

# 3. Roda do zero
.\scripts\run-poc.ps1
```

---

## 📝 Exemplo de Execução Bem-Sucedida

```
===========================================================
  KAFKA ONBOARDING - POC END-TO-END
  Orquestrador completo (shell: pwsh)
===========================================================

[1/5] Subindo infraestrutura...
[OK] Kafka esta healthy!
[OK] Porta 9092 respondendo!
[OK] Infra pronta!

[2/5] Garantindo topicos...
   - onboarding-events
      [CRIADO] 3 particoes
   - onboarding-events-dlq
      [CRIADO] 3 particoes
[OK] Topicos prontos!

[3/5] Subindo CONSUMER em nova janela...
   Aguardando 15s para consumer iniciar e fazer subscribe...

[4/5] Subindo MONITOR em nova janela...

[5/5] Subindo PRODUCER em nova janela...

===========================================================
  POC RODANDO!
===========================================================
  Consumer  -> janela CONSUMER
  Monitor   -> janela MONITOR (LAG em tempo real)
  Producer  -> janela PRODUCER (enviando msgs)

  Kafka UI  -> http://localhost:8080
  Flink UI  -> http://localhost:8081
```

---

## 🤝 Contribuindo com Novos Cenários de Teste

Se quiser adicionar **novos casos de teste**:

1. Crie um novo script em `scripts/` seguindo o padrão `NN-acao-objeto.ps1`
2. Use **aspas simples** em heredocs (`@'...'@`) para evitar bugs de escape
3. Documente o cenário neste README (na seção [Fluxo de Testes](#-fluxo-automatizado-de-testes))
4. Sempre escreva arquivos com **UTF-8 BOM** via `[System.IO.File]::WriteAllText`

### 📋 Cenários sugeridos para adicionar

- 🔥 **Teste de chaos** — matar o broker durante o fluxo e verificar recuperação
- 📈 **Teste de carga** — medir throughput com k6 ou ferramentas similares
- 🎯 **Validação de schema** — produzir mensagens malformadas e verificar DLQ
- 🔄 **Múltiplos consumer groups** — mesmo tópico consumido por 2 grupos independentes
- ⏱️ **Teste de latência** — medir delay end-to-end do produce ao consume
- 🌐 **Partição de rede** — simular desconexão do broker
- 💾 **Teste de persistência** — reiniciar broker e verificar durabilidade

### 🧪 Template para novos scripts de teste

```powershell
# ============================================================
# Script: NN-test-<cenario>.ps1
# Função: <descrição em uma linha do que este teste valida>
# Idempotente: SIM
# Pré-requisitos: <quais scripts precisam ter rodado antes>
# Resultado esperado: <como é o sucesso>
# ============================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = 'Stop'

Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "  TESTE: <NOME DO CENÁRIO>" -ForegroundColor Cyan
Write-Host "===========================================================" -ForegroundColor Cyan

# 1. Setup
# ...

# 2. Executa cenário de teste
# ...

# 3. Asserções
# ...

# 4. Reporta resultado
Write-Host "[OK] Teste passou!" -ForegroundColor Green
```

---

## 📌 Notas Importantes

- ⚠️ Esta é uma **POC** — **NÃO** use essas configurações em produção sem revisão (replication factor = 1, sem auth, sem TLS).
- 🔒 As portas são expostas apenas em `localhost` — nunca exponha em rede pública.
- 💾 Os volumes Docker persistem entre execuções, a menos que você responda "S" no `99-stop-all.ps1`.
- 🕒 O `Start-Sleep 15s` dentro do `run-poc.ps1` existe para o consumer fazer subscribe antes do producer disparar — não remova.
- 🌐 Tanto `localhost:9092` (host) quanto `kafka:29092` (containers) apontam para o mesmo broker — escolha o correto baseado em **onde o código
