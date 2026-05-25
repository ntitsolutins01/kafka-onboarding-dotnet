# 🤝 Contribution Guide — Kafka Onboarding .NET

> Thank you for considering contributing to this project! 🎉
> This guide describes **how to contribute** effectively while maintaining quality,
> consistency, and the didactic spirit of the repository.

![Contributions](https://img.shields.io/badge/Contributions-Welcome-success?style=for-the-badge&logo=github&logoColor=white)
![PRs](https://img.shields.io/badge/PRs-Open-blue?style=for-the-badge&logo=git&logoColor=white)
![Code Style](https://img.shields.io/badge/Code_Style-EditorConfig-orange?style=for-the-badge&logo=editorconfig&logoColor=white)
![Conventional Commits](https://img.shields.io/badge/Commits-Conventional-FE5196?style=for-the-badge&logo=conventionalcommits&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

---

## 📑 Table of Contents

- [Code of Conduct](#-code-of-conduct)
- [How can I contribute?](#-how-can-i-contribute)
- [Setting up the environment](#️-setting-up-the-development-environment)
- [Git Workflow](#-git-workflow)
- [Commit Standards](#-commit-standards-conventional-commits)
- [C# Code Standards](#-c-code-standards)
- [PowerShell Script Standards](#-powershell-script-standards)
- [Documentation Standards](#-documentation-standards)
- [Pull Request Checklist](#-pull-request-checklist)
- [Reporting Bugs](#-reporting-bugs)
- [Suggesting Improvements](#-suggesting-improvements)
- [Project-specific best practices](#-project-specific-best-practices)
- [Questions?](#-questions)

---

## 📜 Code of Conduct

This project follows a simple code of conduct based on **mutual respect**:

- ✅ Be **respectful** and **constructive** in comments, issues, and PRs
- ✅ Accept technical criticism with professionalism
- ✅ Focus on the **technical problem**, not on people
- ✅ Use inclusive and welcoming language
- ❌ Do not tolerate harassment, discrimination, or hostile behavior
- ❌ Do not share third-party private information

Inappropriate behavior can be reported to the maintainers and will result in the contributor being **removed** from the project.

---

## 🎯 How can I contribute?

There are many ways to contribute, **all equally valuable**:

| Contribution type           | Examples                                                      |
|-----------------------------|---------------------------------------------------------------|
| 🐛 **Report bugs**          | Open an issue describing a reproducible problem               |
| ✨ **Suggest features**     | Propose new didactic examples (e.g., Schema Registry)         |
| 📝 **Improve docs**         | Fix typos, clarify explanations, translate                    |
| 🧪 **Add tests**            | New scenarios in `AUTOMATIC_TEST.md`                          |
| 🤖 **Automation**           | New idempotent PowerShell scripts                             |
| 🎨 **Refactor code**        | Improve readability without changing behavior                 |
| 🔧 **Fix scripts**          | Resolve encoding, escaping, compatibility bugs                |
| 🌐 **Translate**            | README and docs in other languages                            |

---

## 🛠️ Setting up the development environment

### 1️⃣ Fork and clone

```powershell
# Fork on GitHub (click "Fork" in the top right corner)
# Then clone your fork:
git clone https://github.com/YOUR-USERNAME/kafka-onboarding-dotnet.git
Set-Location kafka-onboarding-dotnet

# Add the original repository as "upstream"
git remote add upstream https://github.com/ntitsolutins01/kafka-onboarding-dotnet.git
git remote -v
```

### 2️⃣ Validate the environment

```powershell
# Check prerequisites
docker --version            # >= 4.x
docker compose version      # v2
dotnet --version            # >= 8.0
$PSVersionTable.PSVersion   # 5.1 or 7+

# Run the POC to make sure everything works
.\scripts\run-poc.ps1
```

### 3️⃣ Keep your fork in sync

```powershell
# Before creating a new branch, sync with upstream
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

---

## 🔀 Git Workflow

### Strategy: **GitHub Flow** (simple and direct)

```text
main ────────────────────────────────────────▶
   │
   └── feature/feature-name ──── PR ──▶ main
   │
   └── fix/bug-description ──── PR ──▶ main
   │
   └── docs/readme-update ──── PR ──▶ main
```

### 1️⃣ Create a descriptive branch

```powershell
# Pattern: <type>/<short-description-in-kebab-case>
git checkout -b feature/schema-registry-avro
git checkout -b fix/consumer-encoding-utf8
git checkout -b docs/troubleshooting-windows
```

### Valid branch prefixes

| Prefix       | When to use                                |
|--------------|--------------------------------------------|
| `feature/`   | New functionality or didactic example      |
| `fix/`       | Bug fix                                    |
| `docs/`      | Documentation update                       |
| `refactor/`  | Refactor without behavior change           |
| `test/`      | Add/improve tests                          |
| `chore/`     | Maintenance tasks (deps, configs)          |
| `ci/`        | CI/CD pipeline changes                     |

### 2️⃣ Make small atomic commits

> 💡 **Golden rule:** one commit = one idea. If you need "and" in the commit message, you probably have 2 commits.

### 3️⃣ Push and open the Pull Request

```powershell
git push origin feature/schema-registry-avro
# Then open the PR on GitHub targeting `main`
```

---

## 💬 Commit Standards (Conventional Commits)

We follow the [**Conventional Commits**](https://www.conventionalcommits.org/) specification.

### 📐 Format

```text
<type>(<optional scope>): <short description>

[optional body explaining the "why"]

[optional footer with breaking changes or refs]
```

### 🏷️ Allowed types

| Type        | When to use                                                |
|-------------|------------------------------------------------------------|
| `feat`      | New functionality                                          |
| `fix`       | Bug fix                                                    |
| `docs`      | Documentation only                                         |
| `style`     | Formatting (no logic change)                               |
| `refactor`  | Code refactoring                                           |
| `test`      | Add/improve tests                                          |
| `chore`     | Build tasks, deps, configs                                 |
| `ci`        | CI/CD changes                                              |
| `perf`      | Performance improvement                                    |
| `revert`    | Revert a previous commit                                   |

### ✅ Good examples

```text
feat(producer): add Schema Registry support with Avro

Implements Avro serialization using Confluent.SchemaRegistry.Serdes.Avro.
Includes example in README and test in AUTOMATIC_TEST.md.

Closes #42
```

```text
fix(scripts): correct UTF-8 BOM encoding in 02-create-topics.ps1

The script was producing corrupted characters when saved via
Set-Content. Switched to [System.IO.File]::WriteAllText with UTF8Encoding($true).
```

```text
docs(readme): update scripts table with new 05-monitor.ps1
```

```text
refactor(consumer): extract DLQ logic into separate method
```

### ❌ Bad examples

```text
update stuff               ❌ too vague
fixed bug                  ❌ which bug?
WIP                        ❌ don't commit WIP to main
asdfgh                     ❌ no comment...
"fixed multiple things"    ❌ one commit per change!
```

---

## 💻 C# Code Standards

### 📐 General style

We follow the [**Microsoft .NET Coding Conventions**](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions) + a few project-specific rules:

| Rule                                   | Example                                  |
|----------------------------------------|------------------------------------------|
| **PascalCase** for types/methods       | `OnboardingProducer`, `ProduceAsync`     |
| **camelCase** for local variables      | `var customerId = ...`                   |
| **_camelCase** for private fields      | `private readonly ILogger _logger;`      |
| **UPPER_CASE** for constants           | `const string TOPIC_NAME = "...";`       |
| **Async** suffix on async methods      | `Task<int> SaveAsync()`                  |
| **Records** for immutable DTOs         | `public record OnboardingEvent(...)`     |
| **`var`** when the type is obvious     | `var list = new List<string>();`         |
| **Explicit type** when it helps        | `int count = repo.GetCount();`           |

### 🎯 Principles

1. **Clarity > Cleverness** — code that teaches is better than code that impresses
2. **Comments explain the "why"**, not the "what"
3. **Small methods** (ideally < 20 lines)
4. **Single Responsibility** — one class = one responsibility
5. **Dispose properly** — `using` for `IDisposable`

### ✅ Good example

```csharp
/// <summary>
/// Producer with idempotence and Acks.All to ensure
/// exactly-once delivery in single-broker environments.
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
            Acks = Acks.All,              // wait for ack from all replicas
            EnableIdempotence = true,     // avoid duplicates on retries
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
            "Event sent → partition: {Partition}, offset: {Offset}",
            result.Partition.Value, result.Offset.Value);
    }

    public void Dispose() => _producer?.Dispose();
}
```

### ❌ Anti-patterns to avoid

```csharp
// ❌ Bad name, no documentation, no dispose
public class P
{
    IProducer<string,string> p;
    public void Send(string s) { p.Produce("t", new Message<string,string>{Value=s}, null); }
}

// ❌ Generic catch swallowing errors
try { ... }
catch (Exception) { } // 💀 NEVER do this

// ❌ Magic strings scattered everywhere
producer.Produce("onboarding-events", ...);  // use const or config
producer.Produce("onboarding-events", ...);
producer.Produce("onboarding-events", ...);
```

---

## 🤖 PowerShell Script Standards

### 📐 Naming

```text
NN-action-object.ps1
│  │      └── What it affects (e.g., infra, topics, consumer)
│  └────────── Verb in infinitive (e.g., start, create, run, stop)
└───────────── Execution order (01, 02, 03... or 99 for "last")
```

✅ Examples: `01-start-infra.ps1`, `02-create-topics.ps1`, `99-stop-all.ps1`
❌ Avoid: `script1.ps1`, `myScript.ps1`, `start.ps1` (no prefix)

### 🛡️ Mandatory rules

#### 1️⃣ Always UTF-8 with BOM

```powershell
# ❌ WRONG (Set-Content loses BOM and breaks accents)
Set-Content -Path "script.ps1" -Value $content

# ✅ RIGHT
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText("script.ps1", $content, $utf8Bom)
```

#### 2️⃣ Heredoc with single quotes (literal)

```powershell
# ✅ Single quotes → literal, no interpolation, no headaches
$content = @'
Hello $variable — this will NOT be interpolated
'@

# ⚠️ Double quotes → interpolates and requires complex escaping
$content = @"
Hello $variable — this WILL be interpolated, careful!
"@
```

#### 3️⃣ Idempotency

Scripts must run **N times with no side effects**:

```powershell
# ✅ RIGHT — check before creating
$exists = docker exec kafka kafka-topics.sh --list --bootstrap-server localhost:29092 |
          Where-Object { $_ -eq "onboarding-events" }

if (-not $exists) {
    Write-Host "[CREATING] onboarding-events"
    # create...
} else {
    Write-Host "[OK] onboarding-events already exists"
}

# ❌ WRONG — breaks on second run
docker exec kafka kafka-topics.sh --create --topic onboarding-events ...
```

#### 4️⃣ Consistent visual messages

```powershell
Write-Host "[OK] Something worked" -ForegroundColor Green
Write-Host "[INFO] Neutral information" -ForegroundColor Cyan
Write-Host "[WARN] Be careful!" -ForegroundColor Yellow
Write-Host "[ERROR] Failed" -ForegroundColor Red
```

#### 5️⃣ Validate before proceeding

```powershell
# ✅ Fail fast with a clear message
if (-not (Test-Path "docker-compose.yml")) {
    Write-Host "[ERROR] docker-compose.yml not found" -ForegroundColor Red
    Write-Host "        Run this script from the project root." -ForegroundColor Yellow
    exit 1
}

# ✅ Validate health-check
$retries = 0
while ($retries -lt 30) {
    $status = docker inspect -f '{{.State.Health.Status}}' kafka 2>$null
    if ($status -eq 'healthy') { break }
    Start-Sleep 1
    $retries++
}

if ($status -ne 'healthy') {
    Write-Host "[ERROR] Kafka did not become healthy in 30s" -ForegroundColor Red
    exit 1
}
```

### 📋 Template for new scripts

```powershell
# ============================================================
# Script: NN-action-object.ps1
# Purpose: <one-line description>
# Idempotent: YES
# Prerequisites: <which scripts must run first>
# ============================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = 'Stop'

Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "  <SCRIPT TITLE>" -ForegroundColor Cyan
Write-Host "===========================================================" -ForegroundColor Cyan

# Initial validations
# ...

# Main logic
# ...

# Final message
Write-Host "[OK] Done!" -ForegroundColor Green
```

---

## 📚 Documentation Standards

### 📐 Markdown structure

| Element               | Standard                                            |
|-----------------------|-----------------------------------------------------|
| **Heading 1 (`#`)**   | Only once at the top of the document               |
| **Emojis in headings**| Use consistent icons (🚀, 📌, ✅, ❌)              |
| **Tables**            | Use when comparing 3+ items                         |
| **Code fences**       | Always with language (` ```powershell `, ` ```csharp `) |
| **ASCII diagrams**    | In `text` blocks for architecture flows             |
| **Internal links**    | Use kebab-case anchors `[text](#my-heading)`        |
| **Callouts**          | `> 💡`, `> ⚠️`, `> 📌` for highlights              |

### ✅ Best practices

- 📝 **Show executable examples** — code that can be copied and run
- 🎯 **Be concise** — short paragraphs, lists when possible
- 🔗 **Cross-link docs** — README ↔ AUTOMATIC_TEST ↔ CONTRIBUTING
- 🇺🇸 **English** — keep technical terms in English (Kafka, Producer, Consumer, etc.)
- 📸 **ASCII diagrams > Images** — versionable and searchable
- 🔁 **Keep things in sync** — if you change a script, update README + AUTOMATIC_TEST

### ❌ Avoid

```markdown
❌ # Title 1
   # Another Title 1            ← only one H1 per doc!

❌ ```                          ← always specify the language
   code
   ```

❌ "See the documentation"      ← link directly: [documentation](./docs/x.md)

❌ Huge paragraphs with no line breaks that make reading difficult because nobody can follow the reasoning when everything is stacked into a single block without visual pauses.
```

---

## ✅ Pull Request Checklist

Before opening a PR, make sure:

### 🧪 Tests
- [ ] `.\scripts\run-poc.ps1` runs without errors
- [ ] `.\scripts\99-stop-all.ps1` works (with and without volumes)
- [ ] New scenarios documented in `AUTOMATIC_TEST.md`
- [ ] No existing script broken

### 📝 Code
- [ ] Follows the [C# standards](#-c-code-standards) in this guide
- [ ] Follows the [PowerShell standards](#-powershell-script-standards) (if applicable)
- [ ] No leftover `Console.WriteLine` or `Write-Host` debug calls
- [ ] No commented-out code (use git history!)
- [ ] No new dependencies without justification

### 📚 Documentation
- [ ] README updated if public behavior changed
- [ ] AUTOMATIC_TEST updated if test flow changed
- [ ] XML comments on new public methods
- [ ] CHANGELOG updated (if applicable)

### 💬 Commits
- [ ] Messages follow [Conventional Commits](#-commit-standards-conventional-commits)
- [ ] Commits are atomic (one purpose per commit)
- [ ] Branch has a descriptive name (`feature/...`, `fix/...`)
- [ ] Synced with `upstream/main` before pushing

### 🔍 Self-review
- [ ] Re-read the full diff before opening the PR
- [ ] Described **what** and **why** of the change in the PR
- [ ] Linked related issues (`Closes #N`)
- [ ] Added screenshots if visual UI/output changed

---

## 🐛 Reporting Bugs

### 📋 Bug Issue Template

```markdown
## 🐛 Bug Description

<clear and concise description of the problem>

## 🔁 How to Reproduce

Steps to reproduce:
1. Run `.\scripts\...`
2. Wait X seconds
3. See error Y

## ✅ Expected Behavior

<what you expected to happen>

## ❌ Actual Behavior

<what actually happened>

## 📸 Logs / Screenshots

```
<paste logs here>
```

## 🖥️ Environment

- OS: Windows 11 23H2
- PowerShell: 7.4.0
- Docker Desktop: 4.27.0
- .NET SDK: 8.0.100

## 📌 Additional Context

<anything else relevant>
```

### 💡 Tips

- 🔍 **Search first** — your issue may already exist
- 📦 **Include versions** — OS, Docker, .NET, PowerShell
- 🎯 **Isolate the problem** — reproduce in the smallest scenario possible
- 📋 **Paste complete logs** — don't truncate error messages

---

## ✨ Suggesting Improvements

### 📋 Feature Issue Template

```markdown
## 🎯 Problem / Need

<what problem does this feature solve?>

## 💡 Proposed Solution

<describe your idea>

## 🔄 Alternatives Considered

<other approaches you thought of>

## 📚 Educational Value

<why does this help people learning Kafka?>

## 📌 Examples / References

<links, screenshots, related docs>
```

### 🎓 Remember the project's purpose

This is a **didactic repository**. Every feature should:

- ✅ **Teach a concept** of Kafka or .NET
- ✅ **Be easily reproducible** on a local machine
- ✅ **Have clear code** that prioritizes teaching over cleverness
- ✅ **Fit the roadmap** defined in the README

---

## 🎯 Project-specific best practices

### 🚦 About Kafka

1. **Always use `Acks.All`** in producer examples (durability)
2. **Manual commit** in the consumer (offset control)
3. **Partition by key** when ordering matters
4. **DLQ for errors** — don't swallow problematic messages
5. **INTERNAL/EXTERNAL listeners** correctly configured

### 🐳 About Docker

1. **Use health-checks** on all critical services
2. **Specific images** (`apache/kafka:3.8.0`, not `latest`)
3. **Named volumes** for persistence
4. **Dedicated network** (`kafka-flink-net`)
5. **`depends_on` with health-check** when necessary

### ⚙️ About PowerShell

1. **Always idempotent** — running twice shouldn't break anything
2. **UTF-8 BOM** when generating files
3. **`Where-Object`** > `Select-String` for exact matching
4. **Consistent colored messages** (`-ForegroundColor`)
5. **`docker compose`** (v2, no hyphen)

### 📝 About Documentation

1. **English** as the primary language for code/docs
2. **Executable examples** whenever possible
3. **ASCII diagrams** for flows
4. **Cross-links** between README ↔ AUTOMATIC_TEST ↔ CONTRIBUTING
5. **Consistent emojis** for visual scanning

---

## 🚀 Full workflow: from fork to merge

```text
1. 🍴 Fork on GitHub
        │
2. 📥 git clone <your-fork>
        │
3. 🔄 git remote add upstream <original-repo>
        │
4. 🌿 git checkout -b feature/my-feature
        │
5. 💻 Develop + test locally
        │  └── .\scripts\run-poc.ps1
        │
6. 📝 git commit -m "feat(scope): description"
        │
7. ⬆️ git push origin feature/my-feature
        │
8. 🔀 Open PR on GitHub
        │  ├── Clear description
        │  ├── Mark checklist
        │  └── Link issues
        │
9. 👀 Wait for maintainer review
        │
10. ✅ Adjust if needed
        │
11. 🎉 Merge!
```

---

## 🆘 Questions?

- 💬 Open a [Discussion](https://github.com/ntitsolutins01/kafka-onboarding-dotnet/discussions) on GitHub
- 🐛 Open an [Issue](https://github.com/ntitsolutins01/kafka-onboarding-dotnet/issues) if it's a bug
- 📧 Reach out to the maintainer on [LinkedIn](https://www.linkedin.com/in/fabiomunizdeveloper/)

---

## 🙏 Acknowledgment

Every contribution — no matter how small — is **very welcome** and will be recorded in the project's history. Contributors will be listed in the [Contributors](https://github.com/ntitsolutins01/kafka-onboarding-dotnet/graphs/contributors) section on GitHub.

**Thanks for making this project better!** 💙

---

## 📝 License

By contributing, you agree that your contributions will be licensed under the same **MIT** license as the project. See [`LICENSE`](./LICENSE) for details.

---

> *"Alone we can do so little; together we can do so much."*
> — **Helen Keller**

---

## 📌 Quick links

- 📖 [README](./README.md)
- 🧪 [AUTOMATIC_TEST](./AUTOMATIC_TEST.md)
- 📜 [LICENSE](./LICENSE)
- 🐛 [Issues](https://github.com/ntitsolutins01/kafka-onboarding-dotnet/issues)
- 🔀 [Pull Requests](https://github.com/ntitsolutins01/kafka-onboarding-dotnet/pulls)
- 💬 [Discussions](https://github.com/ntitsolutins01/kafka-onboarding-dotnet/discussions)
