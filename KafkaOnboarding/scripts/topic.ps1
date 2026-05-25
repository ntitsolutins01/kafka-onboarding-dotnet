<#
 .SYNOPSIS
     Gerencia topicos Kafka: list, create, describe, delete.

 .EXAMPLE
     .\scripts\topic.ps1 list
     .\scripts\topic.ps1 create -Name eventos -Partitions 6
     .\scripts\topic.ps1 describe -Name thermostat-readings
     .\scripts\topic.ps1 delete -Name eventos
 #>

 [CmdletBinding()]
 param(
     [Parameter(Position=0, Mandatory=$true)]
     [ValidateSet("list","create","describe","delete")]
     [string]$Action,

     [string]$Name,
     [int]$Partitions        = 3,
     [int]$ReplicationFactor = 1,
     [string]$Container      = "kafka"
 )

 [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

 # Detecta automaticamente o container se o padrao nao existir
 $exists = docker ps --filter "name=^$Container$" --format "{{.Names}}" 2>$null
 if (-not $exists) {
     $auto = docker ps --filter "ancestor=apache/kafka" --format "{{.Names}}" | Select-Object -First 1
     if ($auto) {
         Write-Host "[i] Usando container detectado: $auto" -ForegroundColor Yellow
         $Container = $auto
     } else {
         Write-Host "[ERR] Container Kafka nao encontrado. Suba o ambiente primeiro." -ForegroundColor Red
         exit 1
     }
 }

 $kafkaCmd = "/opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092"

 switch ($Action) {
     "list" {
         Write-Host "[*] Topicos:" -ForegroundColor Cyan
         docker exec $Container sh -c "$kafkaCmd --list"
     }
     "create" {
         if (-not $Name) { Write-Host "[ERR] -Name obrigatorio." -ForegroundColor Red; exit 1 }
         Write-Host "[*] Criando topico '$Name' (P=$Partitions, RF=$ReplicationFactor)..." -ForegroundColor Cyan
         docker exec $Container sh -c "$kafkaCmd --create --if-not-exists --topic $Name --partitions $Partitions --replication-factor $ReplicationFactor"
         Write-Host "[OK] Topico '$Name' pronto." -ForegroundColor Green
     }
     "describe" {
         if (-not $Name) { Write-Host "[ERR] -Name obrigatorio." -ForegroundColor Red; exit 1 }
         docker exec $Container sh -c "$kafkaCmd --describe --topic $Name"
     }
     "delete" {
         if (-not $Name) { Write-Host "[ERR] -Name obrigatorio." -ForegroundColor Red; exit 1 }
         $confirm = Read-Host "Apagar topico '$Name'? (s/N)"
         if ($confirm -eq "s") {
             docker exec $Container sh -c "$kafkaCmd --delete --topic $Name"
             Write-Host "[OK] Topico '$Name' apagado." -ForegroundColor Green
         } else {
             Write-Host "Cancelado." -ForegroundColor Yellow
         }
     }
 }