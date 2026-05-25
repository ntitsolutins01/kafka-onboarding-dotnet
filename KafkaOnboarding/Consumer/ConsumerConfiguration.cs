using Confluent.Kafka;

namespace KafkaOnboarding.Consumer;

/// <summary>
/// Configurações centralizadas do Consumer de onboarding.
/// Centralizar facilita testes e troca de ambiente (dev/staging/prod).
/// </summary>
public static class ConsumerConfiguration
{
    public const string BootstrapServers = "localhost:9092";
    public const string Topic = "onboarding-events";
    public const string DeadLetterTopic = "onboarding-events-dlq";
    public const string GroupId = "onboarding-processor";

    public static ConsumerConfig Build() => new()
    {
        // ── Identidade ──
        BootstrapServers = BootstrapServers,
        GroupId = GroupId,
        ClientId = $"{Environment.MachineName}-{Guid.NewGuid():N}".Substring(0, 32),

        // ── Offset ──
        // Earliest = começa do início se não houver offset commitado
        // Latest   = começa do fim (só mensagens novas)
        AutoOffsetReset = AutoOffsetReset.Earliest,

        // ── Commit manual (CRÍTICO para at-least-once) ──
        EnableAutoCommit = false,

        // ── Performance e resiliência ──
        SessionTimeoutMs = 10_000,   // 10s sem heartbeat = morto
        MaxPollIntervalMs = 300_000,  // 5min para processar um batch
        FetchMinBytes = 1,
        FetchWaitMaxMs = 500,

        // ── Isolamento de transações (futuro Schema Registry / EOS) ──
        IsolationLevel = IsolationLevel.ReadCommitted,

        // ── Diagnóstico ──
        EnablePartitionEof = true,    // emite evento ao chegar no fim da partição
    };
}