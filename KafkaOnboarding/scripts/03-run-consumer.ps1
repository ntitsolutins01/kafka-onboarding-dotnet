$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

$Host.UI.RawUI.WindowTitle = 'CONSUMER - KafkaOnboarding'

Write-Host '===========================================' -ForegroundColor Green
Write-Host '  CONSUMER - Processando onboarding-events' -ForegroundColor Green
Write-Host '===========================================' -ForegroundColor Green
Write-Host 'Ctrl+C para shutdown gracioso' -ForegroundColor Gray
Write-Host ''

dotnet run --project KafkaOnboarding.csproj -- consumer