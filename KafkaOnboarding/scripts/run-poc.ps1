$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$scriptsDir  = $PSScriptRoot
Set-Location $projectRoot

$shell = if (Get-Command pwsh -ErrorAction SilentlyContinue) { 'pwsh' } else { 'powershell' }

Write-Host ''
Write-Host '===========================================================' -ForegroundColor Magenta
Write-Host '  KAFKA ONBOARDING - POC END-TO-END' -ForegroundColor Magenta
Write-Host ('  Orquestrador completo (shell: ' + $shell + ')') -ForegroundColor Magenta
Write-Host '===========================================================' -ForegroundColor Magenta
Write-Host ''

Write-Host '[1/5] Subindo infraestrutura...' -ForegroundColor Cyan
& (Join-Path $scriptsDir '01-start-infra.ps1')

Write-Host ''
Write-Host '[2/5] Garantindo topicos...' -ForegroundColor Cyan
& (Join-Path $scriptsDir '02-create-topics.ps1')

Write-Host ''
Write-Host '[3/5] Abrindo CONSUMER em nova janela...' -ForegroundColor Cyan
$consumerScript = Join-Path $scriptsDir '03-run-consumer.ps1'
Start-Process $shell -ArgumentList '-NoExit', '-ExecutionPolicy', 'Bypass', '-File', $consumerScript

Write-Host '   Aguardando 15s para consumer subir e se inscrever...' -ForegroundColor Gray
Start-Sleep -Seconds 15

Write-Host ''
Write-Host '[4/5] Abrindo MONITOR em nova janela...' -ForegroundColor Cyan
$monitorScript = Join-Path $scriptsDir '05-monitor.ps1'
Start-Process $shell -ArgumentList '-NoExit', '-ExecutionPolicy', 'Bypass', '-File', $monitorScript

Start-Sleep -Seconds 2

Write-Host ''
Write-Host '[5/5] Abrindo PRODUCER em nova janela...' -ForegroundColor Cyan
$producerScript = Join-Path $scriptsDir '04-run-producer.ps1'
Start-Process $shell -ArgumentList '-NoExit', '-ExecutionPolicy', 'Bypass', '-File', $producerScript

Write-Host ''
Write-Host '===========================================================' -ForegroundColor Green
Write-Host '  POC RODANDO!' -ForegroundColor Green
Write-Host '===========================================================' -ForegroundColor Green
Write-Host '  Consumer  -> janela CONSUMER' -ForegroundColor White
Write-Host '  Monitor   -> janela MONITOR (LAG em tempo real)' -ForegroundColor White
Write-Host '  Producer  -> janela PRODUCER (enviando msgs)' -ForegroundColor White
Write-Host ''
Write-Host '  Kafka UI  -> http://localhost:8080' -ForegroundColor White
Write-Host '  Flink UI  -> http://localhost:8081' -ForegroundColor White
Write-Host ''
Write-Host '  Para parar tudo: .\scripts\99-stop-all.ps1' -ForegroundColor Yellow
Write-Host '===========================================================' -ForegroundColor Green
Write-Host ''