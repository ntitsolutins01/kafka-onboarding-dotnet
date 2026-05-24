<#
.SYNOPSIS
    Para a infraestrutura do projeto Kafka Onboarding.

.PARAMETER RemoveVolumes
    Se informado, também remove os volumes (apaga dados do Kafka).

.EXAMPLE
    .\scripts\stop.ps1
    .\scripts\stop.ps1 -RemoveVolumes
#>

[CmdletBinding()]
param(
    [switch]$RemoveVolumes
)

$ErrorActionPreference = "Stop"

function Write-Step    { param($msg) Write-Host "`n🔷 $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "✅ $msg" -ForegroundColor Green }
function Write-Warn    { param($msg) Write-Host "⚠️  $msg" -ForegroundColor Yellow }

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

Write-Step "Parando containers..."

if ($RemoveVolumes) {
    Write-Warn "Removendo volumes também (dados do Kafka serão apagados!)"
    docker compose down -v --remove-orphans
    Write-Success "Containers e volumes removidos"
}
else {
    docker compose down --remove-orphans
    Write-Success "Containers removidos (volumes preservados)"
    Write-Host "💡 Use -RemoveVolumes para apagar também os dados do Kafka" -ForegroundColor Gray
}
