# 🎬 POC Kafka Onboarding — Roteiro de Teste End-to-End

> Guia completo para validar a POC de onboarding com **Kafka + .NET**, do zero ao "funcionou lindo". 🚀

[![.NET](https://img.shields.io/badge/.NET-8.0-512BD4?logo=dotnet)](https://dotnet.microsoft.com/)
[![Kafka](https://img.shields.io/badge/Apache%20Kafka-3.x-231F20?logo=apachekafka)](https://kafka.apache.org/)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker)](https://docs.docker.com/compose/)

---

## 📑 Sumário

- [Pré-requisitos](#-pré-requisitos)
- [Arquitetura do Teste](#-arquitetura-do-teste)
- [Roteiro End-to-End](#-roteiro-end-to-end)
- [Kafka UI](#-kafka-ui-no-navegador)
- [Cenários de Teste](#-cenários-de-teste)
- [Checklist de Validação](#-checklist-de-validação)
- [TL;DR](#-tldr--roteiro-resumido)

---

## ✅ Pré-requisitos

Antes de começar, garanta que o ambiente esteja pronto.

### 1. Verificar containers Docker

```powershell
docker ps
```

Você deve ver os containers **`kafka`** e **`kafka-ui`** (ou similares) com status `Up`.

Se **não estiverem rodando**:

```powershell
# Sobe toda a infra
docker compose up -d

# Aguarda ~15s para o Kafka estabilizar
Start-Sleep -Seconds 15

# Confirma
docker ps
```

### 2. Verificar tópicos

```powershell
ktopics --list
```

**Saída esperada:**

```
__consumer_offsets
onboarding-events
onboarding-events-dlq
```

✅ Tudo OK? Bora pro teste!

---

## 🏗️ Arquitetura do Teste

A ideia é abrir **3 terminais** simultâneos para observar o fluxo em tempo real:

```
┌─────────────────┬─────────────────┬─────────────────┐
│   TERMINAL 1    │   TERMINAL 2    │   TERMINAL 3    │
│   (Consumer)    │   (Producer)    │   (Monitor)     │
│                 │                 │                 │
│ Processa msgs   │ Envia msgs      │ Observa LAG     │
└─────────────────┴─────────────────┴─────────────────┘
```

---

## 🎯 Roteiro End-to-End

### 🖥️ Terminal 1 — Subir o Consumer (.NET)

```powershell
cd C:\Projetos\POCs\kafka-onboarding-dotnet\KafkaOnboarding

# Roda o projeto Consumer
dotnet run --project src/OnboardingConsumer
```

> 📌 **Ajuste o caminho** conforme o nome do seu projeto (pode ser `KafkaOnboarding.Consumer`, `Consumer`, etc.).

**Saída esperada:**

```
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: ...
info: OnboardingConsumer[0]
      Consumer subscribed to topic 'onboarding-events'
      Waiting for messages...
```

🟢 **Deixe esse terminal aberto rodando.**

---

### 🖥️ Terminal 2 — Rodar o Producer (.NET)

Abra **outra janela** do PowerShell:

```powershell
cd C:\Projetos\POCs\kafka-onboarding-dotnet\KafkaOnboarding

# Roda o Producer
dotnet run --project src/OnboardingProducer
```

**Saída esperada:**

```
Producing 50 onboarding events...
✅ Sent: user-001 → partition 1, offset 17
✅ Sent: user-002 → partition 0, offset 14
...
✅ Done! 50 messages sent.
```

🔄 Volte ao **Terminal 1** — as mensagens serão processadas em tempo real:

```
[Consumer] Processing user-001 from partition 1, offset 17
[Consumer] ✅ Onboarding completed for user-001
[Consumer] Processing user-002 from partition 0, offset 14
...
```

---

### 🖥️ Terminal 3 — Monitorar o LAG *(opcional)*

Abra uma **terceira janela** e rode em loop:

```powershell
# Monitora o LAG a cada 2 segundos
while ($true) {
    Clear-Host
    Write-Host "=== Consumer Group Status ===" -ForegroundColor Cyan
    kgroups --group onboarding-processor --describe
    Start-Sleep -Seconds 2
}
```

**O que observar:**

| Momento | LAG |
|---|---|
| 🔴 Durante o envio | Sobe (ex: 23 → 15 → 8…) |
| 🟢 Após processamento | Volta a `0` |

> Para parar: **`Ctrl+C`** nesse terminal.

---

## 🌐 Kafka UI no navegador

Acesse: **[http://localhost:8080](http://localhost:8080)** (ou a porta definida no seu `docker-compose.yml`).

**Funcionalidades:**

- 📊 Visualizar tópicos, partições e mensagens
- 🔍 Inspecionar o payload de cada mensagem
- 👥 Acompanhar consumer groups e LAG visualmente
- 📝 Produzir mensagens manualmente (ótimo para testes!)

---

## 🧪 Cenários de Teste

### ✅ Teste 1 — Happy Path (fluxo normal)

```powershell
# Terminal 1: consumer rodando
# Terminal 2:
dotnet run --project src/OnboardingProducer
```

**Esperado:** todas as mensagens processadas, `LAG = 0`, DLQ vazia.

```powershell
# Verifica se a DLQ está vazia
kconsume --topic onboarding-events-dlq --from-beginning --timeout-ms 5000
```

---

### ❌ Teste 2 — Falha → DLQ

Se o producer enviar **eventos com erro proposital** (ex.: email inválido):

```powershell
# Verifica o que foi parar na DLQ
kconsume --topic onboarding-events-dlq --from-beginning --timeout-ms 5000
```

**Esperado:** mensagens "ruins" aparecem na DLQ.

---

### 🔍 Teste 3 — Inspecionar mensagens manualmente

```powershell
# Vê TODAS as mensagens já enviadas (desde o início)
kconsume --topic onboarding-events --from-beginning --timeout-ms 5000

# Vê com a chave (key) destacada
kconsume --topic onboarding-events --from-beginning --property print.key=true --property key.separator=" => " --timeout-ms 5000
```

---

### 💪 Teste 4 — Produzir manualmente

```powershell
# Modo interativo — você digita, ele envia
kproduce --topic onboarding-events
```

Digite uma mensagem JSON e pressione **Enter**:

```json
{"userId":"manual-001","email":"teste@teste.com","name":"Teste Manual"}
```

🔄 Olhe o Terminal 1 — o consumer processa na hora!

> Para sair: **`Ctrl+C`**

---

### 🔥 Teste 5 — Resiliência (derrubar e subir consumer)

Esse é o teste que **prova o poder do Kafka**:

1. No **Terminal 1**, dê `Ctrl+C` (mata o consumer)
2. No **Terminal 2**, envie mais mensagens:
   ```powershell
   dotnet run --project src/OnboardingProducer
   ```
3. No **Terminal 3**, observe: **LAG sobe** 📈 (mensagens acumulam)
4. **Suba o consumer novamente:**
   ```powershell
   dotnet run --project src/OnboardingConsumer
   ```
5. 🪄 **Mágica:** ele continua de onde parou e zera o LAG!

> 💡 **Conclusão:** mensagens ficam persistidas no Kafka, e o consumer retoma do último offset commitado.

---

## 📊 Checklist de Validação

Após os testes, valide o ambiente:

```powershell
# 1. Mensagens estão no tópico principal?
ktopics --describe --topic onboarding-events

# 2. Consumer está processando (LAG = 0)?
kgroups --group onboarding-processor --describe

# 3. DLQ está como esperado?
ktopics --describe --topic onboarding-events-dlq
kconsume --topic onboarding-events-dlq --from-beginning --timeout-ms 5000

# 4. Sem grupos zumbis?
kgroups --list
```

| Item | Status esperado |
|---|---|
| Tópico `onboarding-events` | Ativo, com mensagens |
| Consumer group `onboarding-processor` | `LAG = 0` |
| DLQ `onboarding-events-dlq` | Apenas mensagens com falha (ou vazia no happy path) |
| Grupos ativos | Apenas os esperados |

---

## 🎯 TL;DR — Roteiro Resumido

```powershell
# 1. Subir infra (se não estiver de pé)
docker compose up -d

# 2. Terminal 1 — Consumer
dotnet run --project src/OnboardingConsumer

# 3. Terminal 2 — Producer
dotnet run --project src/OnboardingProducer

# 4. Terminal 3 — Monitor (opcional)
kgroups --group onboarding-processor --describe

# 5. Browser
# http://localhost:8080
```

---

## 📝 Notas

- Os aliases `ktopics`, `kgroups`, `kconsume` e `kproduce` referem-se a comandos customizados do PowerShell que encapsulam os scripts do Kafka (`kafka-topics.sh`, `kafka-consumer-groups.sh` etc.). Ajuste conforme seu ambiente.
- Toda a stack Kafka é orquestrada via `docker-compose.yml` na raiz do projeto.

---

## 📝 Licença

Distribuído sob a licença **MIT**. Veja o arquivo [`LICENSE`](./LICENSE) para mais detalhes.

---

## 👤 Autor

Feito com 💙 e muito ☕ por **Fábio Muniz**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=flat&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/fabiomunizdeveloper/)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white)](https://github.com/ntitsolutins01?tab=repositories)

