$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

$Host.UI.RawUI.WindowTitle = 'PRODUCER - KafkaOnboarding'

Write-Host '===========================================' -ForegroundColor Blue
Write-Host '  PRODUCER - Enviando eventos' -ForegroundColor Blue
Write-Host '===========================================' -ForegroundColor Blue

dotnet run --project KafkaOnboarding.csproj -- producer

Write-Host ''
Write-Host '[OK] Producer finalizou. Pressione qualquer tecla para fechar...' -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')