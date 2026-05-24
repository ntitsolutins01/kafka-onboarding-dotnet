<#
.SYNOPSIS
    Inicia a infraestrutura completa do projeto Kafka Onboarding.

.DESCRIPTION
    - Verifica pré-requisitos (Docker)
    - Sobe Kafka (KRaft), Kafka UI, Flink JobManager e TaskManager
    - Aguarda Kafka ficar healthy
    - Cria os tópicos necessários
    - Valida conectividade do host

.EXAMPLE
    .\scripts\start.ps1
#>

[CmdletBinding()]
param(
    [int]$HealthTimeoutSeconds = 60
)

$ErrorActionPreference = "Stop"

# ─────────────────────────────────────────
# Helpers de log
# ─────────────────────────────────────────
function Write-Step    { param($msg) Write-Host "`n🔷 $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "✅ $msg" -ForegroundColor Green }
function Write-Info    { param($msg) Write-Host "ℹ️  $msg" -ForegroundColor Gray }
function Write-Warn    { param($msg) Write-Host "⚠️  $msg" -ForegroundColor Yellow }
function Write-Err     { param($msg) Write-Host "❌ $msg" -ForegroundColor Red }

# ─────────────────────────────────────────
# Vai pra raiz do projeto (pasta acima do script)
# ─────────────────────────────────────────
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot
Write-Info "Diretório do projeto: $projectRoot"

# ─────────────────────────────────────────
# 1) Verificar Docker
# ─────────────────────────────────────────
Write-Step "Verificando Docker..."
try {
    docker info | Out-Null
    Write-Success "Docker está rodando"
}
catch {
    Write-Err "Docker não está rodando. Inicie o Docker Desktop e tente de novo."
    exit 1
}

# ─────────────────────────────────────────
# 2) Remover containers órfãos (se existirem)
# ─────────────────────────────────────────
Write-Step "Removendo containers órfãos (se existirem)..."
$containers = @("kafka", "kafka-ui", "flink-jobmanager", "flink-taskmanager")
foreach ($c in $containers) {
    $exists = docker ps -a --filter "name=^$c$" --format "{{.Names}}" 2>$null
    if ($exists) {
        docker rm -f $c | Out-Null
        Write-Info "Container órfão removido: $c"
    }
}
Write-Success "Limpeza de órfãos concluída"

# ─────────────────────────────────────────
# 3) Subir o compose
# ─────────────────────────────────────────
Write-Step "Subindo a infraestrutura (docker compose up -d)..."
docker compose up -d --remove-orphans
if ($LASTEXITCODE -ne 0) {
    Write-Err "Falha ao subir o docker compose"
    exit 1
}
Write-Success "Containers iniciados"

# ─────────────────────────────────────────
# 4) Aguardar Kafka healthy
# ─────────────────────────────────────────
Write-Step "Aguardando Kafka ficar healthy (timeout: ${HealthTimeoutSeconds}s)..."
$elapsed = 0
$interval = 3
$healthy = $false
while ($elapsed -lt $HealthTimeoutSeconds) {
    $status = docker inspect --format='{{.State.Health.Status}}' kafka 2>$null
    if ($status -eq "healthy") {
        $healthy = $true
        break
    }
    Write-Host "   ⏳ Status atual: $status (${elapsed}s)" -ForegroundColor DarkGray
    Start-Sleep -Seconds $interval
    $elapsed += $interval
}

if (-not $healthy) {
    Write-Err "Kafka não ficou healthy em ${HealthTimeoutSeconds}s"
    Write-Info "Verifique os logs com: docker logs kafka"
    exit 1
}
Write-Success "Kafka está healthy 🎉"

# ─────────────────────────────────────────
# 5) Criar tópicos
# ─────────────────────────────────────────
Write-Step "Criando tópicos..."
$topics = @(
    @{ Name = "onboarding-events";  Partitions = 3 },
    @{ Name = "onboarding-summary"; Partitions = 3 }
)

foreach ($t in $topics) {
    docker exec kafka /opt/kafka/bin/kafka-topics.sh `
        --bootstrap-server localhost:29092 `
        --create `
        --topic $t.Name `
        --partitions $t.Partitions `
        --replication-factor 1 `
        --if-not-exists | Out-Null
    Write-Success "Tópico pronto: $($t.Name) (partições: $($t.Partitions))"
}

# ─────────────────────────────────────────
# 6) Listar tópicos pra confirmar
# ─────────────────────────────────────────
Write-Step "Tópicos disponíveis:"
docker exec kafka /opt/kafka/bin/kafka-topics.sh `
    --bootstrap-server localhost:29092 --list | ForEach-Object {
    Write-Host "   📬 $_" -ForegroundColor White
}

# ─────────────────────────────────────────
# 7) Validar conectividade do host
# ─────────────────────────────────────────
Write-Step "Validando conectividade localhost:9092..."
$conn = Test-NetConnection -ComputerName localhost -Port 9092 -WarningAction SilentlyContinue
if ($conn.TcpTestSucceeded) {
    Write-Success "Porta 9092 acessível do host"
}
else {
    Write-Warn "Não foi possível conectar em localhost:9092 (pode ser firewall)"
}

# ─────────────────────────────────────────
# 8) Status final
# ─────────────────────────────────────────
Write-Step "Status dos containers:"
docker compose ps

Write-Host "`n════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  🚀 Ambiente pronto!" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  📊 Kafka UI:        " -NoNewline; Write-Host "http://localhost:8080" -ForegroundColor Cyan
Write-Host "  ⚙️  Flink Dashboard: " -NoNewline; Write-Host "http://localhost:8081" -ForegroundColor Cyan
Write-Host "  📡 Bootstrap:       " -NoNewline; Write-Host "localhost:9092" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════`n" -ForegroundColor Green

Write-Host "👉 Próximo passo: rodar o producer" -ForegroundColor Yellow
Write-Host '   $env:EVENTS_PER_SECOND="10"' -ForegroundColor Gray
Write-Host '   $env:TOTAL_EVENTS="500"'      -ForegroundColor Gray
Write-Host "   dotnet run -- producer`n"     -ForegroundColor Gray