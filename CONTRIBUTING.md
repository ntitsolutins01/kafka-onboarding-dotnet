# 🤝 Guia de Contribuição — Kafka Onboarding .NET

> Obrigado por considerar contribuir com este projeto! 🎉
> Este guia descreve **como contribuir** de forma efetiva, mantendo a qualidade,
> consistência e o espírito didático do repositório.

![Contributions](https://img.shields.io/badge/Contributions-Welcome-success?style=for-the-badge&logo=github&logoColor=white)
![PRs](https://img.shields.io/badge/PRs-Open-blue?style=for-the-badge&logo=git&logoColor=white)
![Code Style](https://img.shields.io/badge/Code_Style-EditorConfig-orange?style=for-the-badge&logo=editorconfig&logoColor=white)
![Conventional Commits](https://img.shields.io/badge/Commits-Conventional-FE5196?style=for-the-badge&logo=conventionalcommits&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

---

## 📑 Sumário

- [Código de Conduta](#-código-de-conduta)
- [Como posso contribuir?](#-como-posso-contribuir)
- [Configurando o ambiente](#️-configurando-o-ambiente-de-desenvolvimento)
- [Fluxo de trabalho com Git](#-fluxo-de-trabalho-com-git)
- [Padrões de Commit](#-padrões-de-commit-conventional-commits)
- [Padrões de Código C#](#-padrões-de-código-c)
- [Padrões para Scripts PowerShell](#-padrões-para-scripts-powershell)
- [Padrões de Documentação](#-padrões-de-documentação)
- [Checklist do Pull Request](#-checklist-do-pull-request)
- [Reportando Bugs](#-reportando-bugs)
- [Sugerindo Melhorias](#-sugerindo-melhorias)
- [Boas práticas específicas do projeto](#-boas-práticas-específicas-do-projeto)
- [Dúvidas?](#-dúvidas)

---

## 📜 Código de Conduta

Este projeto adota um código de conduta simples baseado em **respeito mútuo**:

- ✅ Seja **respeitoso** e **construtivo** em comentários, issues e PRs
- ✅ Aceite críticas técnicas com profissionalismo
- ✅ Foque no **problema técnico**, não em pessoas
- ✅ Use linguagem inclusiva e acolhedora
- ❌ Não tolere assédio, discriminação ou comportamento hostil
- ❌ Não publique informações privadas de terceiros

Comportamentos inadequados podem ser reportados aos mantenedores e resultarão em **remoção do contribuidor** do projeto.

---

## 🎯 Como posso contribuir?

Existem várias formas de contribuir, **todas igualmente valiosas**:

| Tipo de contribuição        | Exemplos                                                      |
|-----------------------------|---------------------------------------------------------------|
| 🐛 **Reportar bugs**        | Abrir issue descrevendo problema reproduzível                 |
| ✨ **Sugerir features**     | Propor novos exemplos didáticos (ex: Schema Registry)         |
| 📝 **Melhorar docs**        | Corrigir typos, clarificar explicações, traduzir              |
| 🧪 **Adicionar testes**     | Novos cenários no `AUTOMATIC_TEST.md`                         |
| 🤖 **Automação**            | Novos scripts PowerShell idempotentes                         |
| 🎨 **Refatorar código**     | Melhorar legibilidade sem mudar comportamento                 |
| 🔧 **Fix de scripts**       | Resolver bugs de encoding, escape, compatibilidade            |
| 🌐 **Tradução**             | README e docs em outros idiomas                               |

---

## 🛠️ Configurando o ambiente de desenvolvimento

### 1️⃣ Fork e clone

```powershell
# Faça fork no GitHub (botão "Fork" no canto superior direito)
# Depois clone seu fork:
git clone https://github.com/SEU-USUARIO/kafka-onboarding-dotnet.git
Set-Location kafka-onboarding-dotnet

# Adicione o repositório original como "upstream"
git remote add upstream https://github.com/ntitsolutins01/kafka-onboarding-dotnet.git
git remote -v
```

### 2️⃣ Valide o ambiente

```powershell
# Verifique pré-requisitos
docker --version            # >= 4.x
docker compose version      # v2
dotnet --version            # >= 8.0
$PSVersionTable.PSVersion   # 5.1 ou 7+

# Suba a POC pra garantir que tudo está OK
.\scripts\run-poc.ps1
```

### 3️⃣ Mantenha seu fork atualizado

```powershell
# Antes de criar uma branch nova, sincronize com upstream
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

---

## 🔀 Fluxo de trabalho com Git

### Estratégia: **GitHub Flow** (simples e direto)

```text
main ────────────────────────────────────────▶
   │
   └── feature/nome-da-feature ──── PR ──▶ main
   │
   └── fix/descricao-do-bug    ──── PR ──▶ main
   │
   └── docs/atualizacao-readme ──── PR ──▶ main
```

### 1️⃣ Crie uma branch descritiva

```powershell
# Padrão: <tipo>/<descricao-curta-em-kebab-case>
git checkout -b feature/schema-registry-avro
git checkout -b fix/consumer-encoding-utf8
git checkout -b docs/troubleshooting-windows
```

### Prefixos válidos para branches

| Prefixo      | Quando usar                                |
|--------------|--------------------------------------------|
| `feature/`   | Nova funcionalidade ou exemplo didático    |
| `fix/`       | Correção de bug                            |
| `docs/`      | Atualização de documentação                |
| `refactor/`  | Refatoração sem mudança de comportamento   |
| `test/`      | Adição/melhoria de testes                  |
| `chore/`     | Tarefas de manutenção (deps, configs)      |
| `ci/`        | Mudanças em pipelines/CI                   |

### 2️⃣ Faça commits pequenos e atômicos

> 💡 **Regra de ouro:** um commit = uma ideia. Se você precisa de "e" no commit message, provavelmente são 2 commits.

### 3️⃣ Push e abra o Pull Request

```powershell
git push origin feature/schema-registry-avro
# Depois, abra o PR no GitHub apontando para `main`
```

---

## 💬 Padrões de Commit (Conventional Commits)

Seguimos a especificação [**Conventional Commits**](https://www.conventionalcommits.org/).

### 📐 Formato

```text
<tipo>(<escopo opcional>): <descrição curta>

[corpo opcional explicando o "porquê"]

[rodapé opcional com breaking changes ou refs]
```

### 🏷️ Tipos permitidos

| Tipo        | Quando usar                                                |
|-------------|------------------------------------------------------------|
| `feat`      | Nova funcionalidade                                        |
| `fix`       | Correção de bug                                            |
| `docs`      | Apenas documentação                                        |
| `style`     | Formatação (sem mudança de lógica)                         |
| `refactor`  | Refatoração de código                                      |
| `test`      | Adição/melhoria de testes                                  |
| `chore`     | Tarefas de build, deps, configs                            |
| `ci`        | Mudanças em CI/CD                                          |
| `perf`      | Melhoria de performance                                    |
| `revert`    | Reverter commit anterior                                   |

### ✅ Exemplos bons

```text
feat(producer): adiciona suporte a Schema Registry com Avro

Implementa serialização Avro usando Confluent.SchemaRegistry.Serdes.Avro.
Inclui exemplo no README e teste no AUTOMATIC_TEST.md.

Closes #42
```

```text
fix(scripts): corrige encoding UTF-8 BOM no 02-create-topics.ps1

O script estava gerando caracteres corrompidos quando salvo via
Set-Content. Trocado para [System.IO.File]::WriteAllText com UTF8Encoding($true).
```

```text
docs(readme): atualiza tabela de scripts com novo 05-monitor.ps1
```

```text
refactor(consumer): extrai lógica de DLQ para método separado
```

### ❌ Exemplos ruins

```text
update stuff               ❌ vago demais
fixed bug                  ❌ qual bug?
WIP                        ❌ não faça commit de WIP em main
asdfgh                     ❌ sem comentários...
"corrigi várias coisas"    ❌ um commit por mudança!
```

---

## 💻 Padrões de Código C#

### 📐 Estilo geral

Seguimos as [**Microsoft .NET Coding Conventions**](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions) + algumas regras do projeto:

| Regra                                  | Exemplo                                  |
|----------------------------------------|------------------------------------------|
| **PascalCase** para tipos/métodos      | `OnboardingProducer`, `ProduceAsync`     |
| **camelCase** para variáveis locais    | `var customerId = ...`                   |
| **_camelCase** para campos privados    | `private readonly ILogger _logger;`      |
| **UPPER_CASE** para constantes         | `const string TOPIC_NAME = "...";`       |
| **Async** sufixo em métodos async      | `Task<int> SaveAsync()`                  |
| **Records** para DTOs imutáveis        | `public record OnboardingEvent(...)`     |
| **`var`** quando o tipo é óbvio        | `var list = new List<string>();`         |
| **Tipo explícito** quando ajuda        | `int count = repo.GetCount();`           |

### 🎯 Princípios

1. **Clareza > Esperteza** — código que ensina é melhor que código que impressiona
2. **Comentários explicam o "porquê"**, não o "o quê"
3. **Métodos pequenos** (idealmente < 20 linhas)
4. **Single Responsibility** — uma classe = uma responsabilidade
5. **Dispose corretamente** — `using` para `IDisposable`

### ✅ Exemplo bom

```csharp
/// <summary>
/// Producer com idempotência e Acks.All para garantir
/// entrega exactly-once em ambiente single-broker.
/// </summary>
public sealed class OnboardingProducer : IDisposable
{
    private readonly IProducer<string, string> _producer;
    private readonly ILogger<OnboardingProducer> _logger;

    public OnboardingProducer(ILogger<OnboardingProducer> logger)
    {
        var config = new ProducerConfig
        {
            BootstrapServers = "localhost:9092",
            Acks = Acks.All,              // espera ack de todas as réplicas
            EnableIdempotence = true,     // evita duplicatas em retries
            MessageSendMaxRetries = 3
        };

        _producer = new ProducerBuilder<string, string>(config).Build();
        _logger = logger;
    }

    public async Task ProduceAsync(OnboardingEvent evt, CancellationToken ct = default)
    {
        var key = $"CUST-{evt.CustomerId}";
        var value = JsonSerializer.Serialize(evt);

        var result = await _producer.ProduceAsync(
            "onboarding-events",
            new Message<string, string> { Key = key, Value = value },
            ct);

        _logger.LogInformation(
            "Evento enviado → partition: {Partition}, offset: {Offset}",
            result.Partition.Value, result.Offset.Value);
    }

    public void Dispose() => _producer?.Dispose();
}
```

### ❌ Anti-padrões a evitar

```csharp
// ❌ Nome ruim, sem documentação, sem dispose
public class P
{
    IProducer<string,string> p;
    public void Send(string s) { p.Produce("t", new Message<string,string>{Value=s}, null); }
}

// ❌ Catch genérico engolindo erro
try { ... }
catch (Exception) { } // 💀 NUNCA faça isso

// ❌ Magic strings espalhadas
producer.Produce("onboarding-events", ...);  // use const ou config
producer.Produce("onboarding-events", ...);
producer.Produce("onboarding-events", ...);
```

---

## 🤖 Padrões para Scripts PowerShell

### 📐 Nomenclatura

```text
NN-acao-objeto.ps1
│  │     └── O que afeta (ex: infra, topics, consumer)
│  └──────── Verbo no infinitivo (ex: start, create, run, stop)
└─────────── Ordem de execução (01, 02, 03... ou 99 para "último")
```

✅ Exemplos: `01-start-infra.ps1`, `02-create-topics.ps1`, `99-stop-all.ps1`
❌ Evite: `script1.ps1`, `myScript.ps1`, `start.ps1` (sem prefixo)

### 🛡️ Regras obrigatórias

#### 1️⃣ Sempre UTF-8 com BOM

```powershell
# ❌ ERRADO (Set-Content perde BOM e quebra acentos)
Set-Content -Path "script.ps1" -Value $content

# ✅ CERTO
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText("script.ps1", $content, $utf8Bom)
```

#### 2️⃣ Heredoc com aspas simples (literal)

```powershell
# ✅ Aspas simples → literal, não interpola, sem dor de cabeça
$content = @'
Olá $variavel — isto NÃO será interpolado
'@

# ⚠️ Aspas duplas → interpola e precisa de escape complexo
$content = @"
Olá $variavel — isto SERÁ interpolado, cuidado!
"@
```

#### 3️⃣ Idempotência

Scripts devem rodar **N vezes sem efeito colateral**:

```powershell
# ✅ CERTO — verifica antes de criar
$exists = docker exec kafka kafka-topics.sh --list --bootstrap-server localhost:29092 |
          Where-Object { $_ -eq "onboarding-events" }

if (-not $exists) {
    Write-Host "[CRIANDO] onboarding-events"
    # cria...
} else {
    Write-Host "[OK] onboarding-events já existe"
}

# ❌ ERRADO — quebra na segunda execução
docker exec kafka kafka-topics.sh --create --topic onboarding-events ...
```

#### 4️⃣ Mensagens visuais consistentes

```powershell
Write-Host "[OK] Algo deu certo" -ForegroundColor Green
Write-Host "[INFO] Informação neutra" -ForegroundColor Cyan
Write-Host "[AVISO] Cuidado!" -ForegroundColor Yellow
Write-Host "[ERRO] Falhou" -ForegroundColor Red
```

#### 5️⃣ Validações antes de seguir

```powershell
# ✅ Falhe rápido com mensagem clara
if (-not (Test-Path "docker-compose.yml")) {
    Write-Host "[ERRO] docker-compose.yml não encontrado" -ForegroundColor Red
    Write-Host "       Execute este script da raiz do projeto." -ForegroundColor Yellow
    exit 1
}

# ✅ Valide health-check
$retries = 0
while ($retries -lt 30) {
    $status = docker inspect -f '{{.State.Health.Status}}' kafka 2>$null
    if ($status -eq 'healthy') { break }
    Start-Sleep 1
    $retries++
}

if ($status -ne 'healthy') {
    Write-Host "[ERRO] Kafka não ficou healthy em 30s" -ForegroundColor Red
    exit 1
}
```

### 📋 Template para novos scripts

```powershell
# ============================================================
# Script: NN-acao-objeto.ps1
# Função: <descrição em uma linha>
# Idempotente: SIM
# Pré-req: <quais scripts precisam ter rodado antes>
# ============================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = 'Stop'

Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "  <TITULO DO SCRIPT>" -ForegroundColor Cyan
Write-Host "===========================================================" -ForegroundColor Cyan

# Validações iniciais
# ...

# Lógica principal
# ...

# Mensagem final
Write-Host "[OK] Concluído!" -ForegroundColor Green
```

---

## 📚 Padrões de Documentação

### 📐 Estrutura de Markdown

| Elemento              | Padrão                                              |
|-----------------------|-----------------------------------------------------|
| **Heading 1 (`#`)**   | Só uma vez no topo do documento                     |
| **Emojis nas headings** | Use ícones consistentes (🚀, 📌, ✅, ❌)            |
| **Tabelas**           | Sempre que comparar 3+ itens                        |
| **Code fences**       | Sempre com linguagem (` ```powershell `, ` ```csharp `) |
| **Diagramas ASCII**   | Em blocos `text` para fluxos arquiteturais          |
| **Links internos**    | Use ancoragem em kebab-case `[texto](#meu-titulo)`  |
| **Callouts**          | `> 💡`, `> ⚠️`, `> 📌` para destaques               |

### ✅ Boas práticas

- 📝 **Mostre exemplos executáveis** — código que dá pra copiar e rodar
- 🎯 **Seja conciso** — parágrafos curtos, listas quando possível
- 🔗 **Linke entre docs** — README ↔ AUTOMATIC_TEST ↔ CONTRIBUTING
- 🇧🇷 **Português brasileiro** — sem misturar com inglês desnecessariamente
- 📸 **Diagramas ASCII > Imagens** — versionáveis e pesquisáveis
- 🔁 **Mantenha sincronizado** — se mudou script, atualize README + AUTOMATIC_TEST

### ❌ Evite

```markdown
❌ # Título 1
   # Outro Título 1            ← só um H1 por doc!

❌ ```                         ← sempre indique a linguagem
   código
   ```

❌ "Veja a documentação"       ← linke direto: [documentação](./docs/x.md)

❌ Parágrafos gigantes sem quebra de linha que dificultam a leitura porque ninguém consegue acompanhar o raciocínio quando tudo está empilhado num único bloco sem pausa visual.
```

---

## ✅ Checklist do Pull Request

Antes de abrir um PR, garanta que:

### 🧪 Testes
- [ ] `.\scripts\run-poc.ps1` roda sem erros
- [ ] `.\scripts\99-stop-all.ps1` funciona (com e sem volumes)
- [ ] Cenários novos foram documentados no `AUTOMATIC_TEST.md`
- [ ] Não quebrei nenhum script existente

### 📝 Código
- [ ] Segue os [padrões de C#](#-padrões-de-código-c) deste guia
- [ ] Segue os [padrões PowerShell](#-padrões-para-scripts-powershell) (se aplicável)
- [ ] Sem `Console.WriteLine` ou `Write-Host` esquecidos de debug
- [ ] Sem código comentado (use git history!)
- [ ] Sem dependências novas sem justificativa

### 📚 Documentação
- [ ] README atualizado se mudou comportamento público
- [ ] AUTOMATIC_TEST atualizado se mudou fluxo de teste
- [ ] Comentários XML em métodos públicos novos
- [ ] CHANGELOG atualizado (se houver)

### 💬 Commits
- [ ] Mensagens seguem [Conventional Commits](#-padrões-de-commit-conventional-commits)
- [ ] Commits são atômicos (um propósito por commit)
- [ ] Branch tem nome descritivo (`feature/...`, `fix/...`)
- [ ] Sincronizei com `upstream/main` antes do push

### 🔍 Revisão própria
- [ ] Reli o diff completo antes de abrir o PR
- [ ] Descrevi **o quê** e **o porquê** da mudança no PR
- [ ] Linkei issues relacionadas (`Closes #N`)
- [ ] Adicionei screenshots se mudou UI/output visual

---

## 🐛 Reportando Bugs

### 📋 Template de Issue para Bug

```markdown
## 🐛 Descrição do Bug

<descrição clara e objetiva do problema>

## 🔁 Como Reproduzir

Passos para reproduzir:
1. Execute `.\scripts\...`
2. Aguarde X segundos
3. Veja o erro Y

## ✅ Comportamento Esperado

<o que você esperava que acontecesse>

## ❌ Comportamento Atual

<o que aconteceu de fato>

## 📸 Logs / Screenshots

```
<cole logs aqui>
```

## 🖥️ Ambiente

- SO: Windows 11 23H2
- PowerShell: 7.4.0
- Docker Desktop: 4.27.0
- .NET SDK: 8.0.100

## 📌 Contexto Adicional

<qualquer coisa relevante>
```

### 💡 Dicas

- 🔍 **Pesquise primeiro** — sua issue pode já existir
- 📦 **Inclua versões** — SO, Docker, .NET, PowerShell
- 🎯 **Isole o problema** — reproduza no menor cenário possível
- 📋 **Cole logs completos** — não corte mensagens de erro

---

## ✨ Sugerindo Melhorias

### 📋 Template de Issue para Feature

```markdown
## 🎯 Problema / Necessidade

<que problema essa feature resolve?>

## 💡 Solução Proposta

<descreva sua ideia>

## 🔄 Alternativas Consideradas

<outras abordagens que você pensou>

## 📚 Valor Didático

<por que isso ajuda quem está aprendendo Kafka?>

## 📌 Exemplos / Referências

<links, prints, docs relacionadas>
```

### 🎓 Lembre-se do propósito do projeto

Este é um **repositório didático**. Toda feature deve:

- ✅ **Ensinar um conceito** de Kafka ou .NET
- ✅ **Ser facilmente reproduzível** em uma máquina local
- ✅ **Ter código claro** que prioriza didática sobre cleverness
- ✅ **Caber no roadmap** definido no README

---

## 🎯 Boas práticas específicas do projeto

### 🚦 Sobre Kafka

1. **Sempre use `Acks.All`** em exemplos de producer (durabilidade)
2. **Commit manual** no consumer (controle de offset)
3. **Particionamento por chave** quando ordenação importa
4. **DLQ para erros** — não engula mensagens problemáticas
5. **Listeners INTERNAL/EXTERNAL** corretamente configurados

### 🐳 Sobre Docker

1. **Use health-checks** em todos os serviços críticos
2. **Imagens específicas** (`apache/kafka:3.8.0`, não `latest`)
3. **Volumes nomeados** para persistência
4. **Rede dedicada** (`kafka-flink-net`)
5. **`depends_on` com health-check** quando necessário

### ⚙️ Sobre PowerShell

1. **Idempotência sempre** — rodar 2x não deve quebrar nada
2. **UTF-8 BOM** ao gerar arquivos
3. **`Where-Object`** > `Select-String` para comparações exatas
4. **Mensagens coloridas** consistentes (`-ForegroundColor`)
5. **`docker compose`** (v2, sem hífen)

### 📝 Sobre Documentação

1. **Português brasileiro** como idioma principal
2. **Exemplos executáveis** sempre que possível
3. **Diagramas ASCII** para fluxos
4. **Links cruzados** entre README ↔ AUTOMATIC_TEST ↔ CONTRIBUTING
5. **Emojis consistentes** para visual scanning

---

## 🚀 Fluxo completo: do fork ao merge

```text
1. 🍴 Fork no GitHub
        │
2. 📥 git clone <seu-fork>
        │
3. 🔄 git remote add upstream <repo-original>
        │
4. 🌿 git checkout -b feature/minha-feature
        │
5. 💻 Desenvolva + teste localmente
        │  └── .\scripts\run-poc.ps1
        │
6. 📝 git commit -m "feat(scope): descrição"
        │
7. ⬆️ git push origin feature/minha-feature
        │
8. 🔀 Abra PR no GitHub
        │  ├── Descrição clara
        │  ├── Marque checklist
        │  └── Linke issues
        │
9. 👀 Aguarde revisão dos mantenedores
        │
10. ✅ Ajuste se necessário
        │
11. 🎉 Merge!
```

---

## 🆘 Dúvidas?

- 💬 Abra uma [Discussion](https://github.com/ntitsolutins01/kafka-onboarding-dotnet/discussions) no GitHub
- 🐛 Abra uma [Issue](https://github.com/ntitsolutins01/kafka-onboarding-dotnet/issues) se for bug
- 📧 Contate o mantenedor via [LinkedIn](https://www.linkedin.com/in/fabiomunizdeveloper/)

---

## 🙏 Reconhecimento

Toda contribuição — por menor que seja — é **muito bem-vinda** e ficará registrada no histórico do projeto. Contribuidores serão listados na seção [Contributors](https://github.com/ntitsolutins01/kafka-onboarding-dotnet/graphs/contributors) do GitHub.

**Obrigado por fazer este projeto melhor!** 💙

---

## 📝 Licença

Ao contribuir, você concorda que suas contribuições serão licenciadas sob a mesma licença **MIT** do projeto. Veja [`LICENSE`](./LICENSE) para detalhes.

---

> *"Alone we can do so little; together we can do so much."*
> — **Helen Keller**

---

## 📌 Links rápidos

- 📖 [README](./README.md)
- 🧪 [AUTOMATIC_TEST](./AUTOMATIC_TEST.md)
- 📜 [LICENSE](./LICENSE)
- 🐛 [Issues](https://github.com/ntitsolutins01/kafka-onboarding-dotnet/issues)
- 🔀 [Pull Requests](https://github.com/ntitsolutins01/kafka-onboarding-dotnet/pulls)
- 💬 [Discussions](https://github.com/ntitsolutins01/kafka-onboarding-dotnet/discussions)
