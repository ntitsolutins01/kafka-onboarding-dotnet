<#
.SYNOPSIS
    Executa o producer com parâmetros configuráveis.

.EXAMPLE
    .\scripts\producer.ps1
    .\scripts\producer.ps1 -Rate 50 -Total 1000
#>

[CmdletBinding()]
param(
    [int]$Rate  = 10,
    [int]$Total = 500
)

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

$env:EVENTS_PER_SECOND = "$Rate"
$env:TOTAL_EVENTS      = "$Total"

Write-Host "🚀 Producer: $Rate eventos/s × $Total totais" -ForegroundColor Cyan
dotnet run -- producer
