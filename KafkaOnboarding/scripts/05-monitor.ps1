$ErrorActionPreference = 'Stop'
$Host.UI.RawUI.WindowTitle = 'MONITOR - Consumer Group LAG'

$group = 'onboarding-processor'
$intervalSeconds = 2

while ($true) {
    Clear-Host
    Write-Host '===========================================================' -ForegroundColor Cyan
    Write-Host ('  MONITOR - Consumer Group: ' + $group) -ForegroundColor Cyan
    $timestamp = Get-Date -Format 'HH:mm:ss'
    Write-Host ('  ' + $timestamp + '   (refresh ' + $intervalSeconds + 's - Ctrl+C para sair)') -ForegroundColor Gray
    Write-Host '===========================================================' -ForegroundColor Cyan
    Write-Host ''

    docker exec kafka /opt/kafka/bin/kafka-consumer-groups.sh `
        --bootstrap-server localhost:29092 `
        --group $group `
        --describe 2>&1

    Write-Host ''
    Write-Host '-----------------------------------------------------------' -ForegroundColor DarkGray
    Write-Host 'Todos os grupos ativos:' -ForegroundColor Yellow

    docker exec kafka /opt/kafka/bin/kafka-consumer-groups.sh `
        --bootstrap-server localhost:29092 `
        --list 2>&1

    Start-Sleep -Seconds $intervalSeconds
}