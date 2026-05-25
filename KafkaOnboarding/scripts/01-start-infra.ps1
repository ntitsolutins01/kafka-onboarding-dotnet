$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

Write-Host '[INFRA] Subindo containers Docker...' -ForegroundColor Cyan
docker compose up -d

Write-Host ''
Write-Host '[INFRA] Aguardando Kafka ficar healthy...' -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0
while ($attempt -lt $maxAttempts) {
    $health = docker inspect --format='{{.State.Health.Status}}' kafka 2>$null
    if ($health -eq 'healthy') {
        Write-Host '[OK] Kafka esta healthy!' -ForegroundColor Green
        break
    }
    $attempt++
    Write-Host ("   Tentativa " + $attempt + "/" + $maxAttempts + " (status: " + $health + ")...") -ForegroundColor Gray
    Start-Sleep -Seconds 2
}
if ($attempt -eq $maxAttempts) {
    Write-Host '[ERRO] Kafka nao ficou healthy a tempo!' -ForegroundColor Red
    docker logs kafka --tail 30
    exit 1
}

Write-Host ''
Write-Host '[INFRA] Validando porta 9092 no host...' -ForegroundColor Yellow
$portOk = $false
for ($i = 1; $i -le 15; $i++) {
    $test = Test-NetConnection -ComputerName localhost -Port 9092 -WarningAction SilentlyContinue
    if ($test.TcpTestSucceeded) {
        Write-Host '[OK] Porta 9092 respondendo!' -ForegroundColor Green
        $portOk = $true
        break
    }
    Write-Host ("   (" + $i + "/15) porta 9092 ainda nao responde...") -ForegroundColor Gray
    Start-Sleep -Seconds 2
}
if (-not $portOk) {
    Write-Host '[ERRO] Porta 9092 nao acessivel do host!' -ForegroundColor Red
    exit 1
}

Write-Host ''
Write-Host '[INFRA] Status dos containers:' -ForegroundColor Cyan
docker compose ps

Write-Host ''
Write-Host '[URLs]' -ForegroundColor Cyan
Write-Host '   Kafka UI : http://localhost:8080' -ForegroundColor White
Write-Host '   Flink UI : http://localhost:8081' -ForegroundColor White
Write-Host '   Kafka    : localhost:9092' -ForegroundColor White
Write-Host ''
Write-Host '[OK] Infra pronta!' -ForegroundColor Green