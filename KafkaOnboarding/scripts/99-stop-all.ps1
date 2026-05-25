$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

Write-Host '[STOP] Parando containers...' -ForegroundColor Yellow
docker compose down

Write-Host ''
Write-Host 'Quer apagar TAMBEM os dados (volumes)? [s/N]: ' -ForegroundColor Red -NoNewline
$resp = Read-Host

if ($resp -eq 's' -or $resp -eq 'S') {
    Write-Host '[STOP] Removendo volumes...' -ForegroundColor Yellow
    docker compose down -v
    Write-Host '[OK] Tudo limpo (containers + volumes)!' -ForegroundColor Green
} else {
    Write-Host '[OK] Containers parados (volumes preservados).' -ForegroundColor Green
}