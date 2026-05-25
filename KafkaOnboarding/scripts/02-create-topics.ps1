$ErrorActionPreference = 'Stop'

$topics = @(
    @{ Name = 'onboarding-events';     Partitions = 3; Replication = 1 },
    @{ Name = 'onboarding-events-dlq'; Partitions = 3; Replication = 1 }
)

Write-Host '[TOPICS] Criando/verificando topicos...' -ForegroundColor Cyan

foreach ($t in $topics) {
    Write-Host ''
    Write-Host ('   - ' + $t.Name) -ForegroundColor Yellow

    $listOutput = docker exec kafka /opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:29092 --list 2>$null
    $exists = $listOutput | Where-Object { $_ -eq $t.Name }

    if ($exists) {
        Write-Host '      [OK] Ja existe' -ForegroundColor Green
    } else {
        $partitions = $t.Partitions
        $replication = $t.Replication
        docker exec kafka /opt/kafka/bin/kafka-topics.sh `
            --bootstrap-server localhost:29092 `
            --create `
            --topic $t.Name `
            --partitions $partitions `
            --replication-factor $replication | Out-Null
        Write-Host ('      [CRIADO] ' + $partitions + ' particoes') -ForegroundColor Green
    }
}

Write-Host ''
Write-Host '[TOPICS] Topicos no cluster:' -ForegroundColor Cyan
docker exec kafka /opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:29092 --list

Write-Host ''
Write-Host '[OK] Topicos prontos!' -ForegroundColor Green