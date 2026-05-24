<#
.SYNOPSIS
    Reset completo: derruba tudo, apaga volumes, sobe do zero.

.DESCRIPTION
    Use este script quando o ambiente estiver inconsistente
    (containers órfãos, volumes corrompidos, configuração antiga, etc.)

.EXAMPLE
    .\scripts\reset.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Write-Step    { param($msg) Write-Host "`n🔷 $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "✅ $msg" -ForegroundColor Green }
function Write-Warn    { param($msg) Write-Host "⚠️  $msg" -ForegroundColor Yellow }

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

Write-Warn "Este comando vai APAGAR todos os dados do Kafka deste projeto!"
$confirm = Read-Host "Confirma? (s/N)"
if ($confirm -ne 's' -and $confirm -ne 'S') {
    Write-Host "Operação cancelada." -ForegroundColor Yellow
    exit 0
}

Write-Step "1/3 - Derrubando compose e removendo volumes..."
docker compose down -v --remove-orphans 2>$null

Write-Step "2/3 - Removendo containers órfãos com nomes do projeto..."
$containers = @("kafka", "kafka-ui", "flink-jobmanager", "flink-taskmanager")
foreach ($c in $containers) {
    docker rm -f $c 2>$null | Out-Null
}
Write-Success "Limpeza concluída"

Write-Step "3/3 - Subindo do zero via start.ps1..."
& "$PSScriptRoot\start.ps1"
