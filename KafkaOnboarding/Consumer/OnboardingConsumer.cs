using Confluent.Kafka;
using KafkaOnboarding.Consumer.DeadLetter;
using KafkaOnboarding.Models;
using Microsoft.Extensions.Logging;
using System.Text.Json;

namespace KafkaOnboarding.Consumer;

/// <summary>
/// Consumer de eventos de onboarding.
/// 
/// Garantias:
///  • At-least-once  → commit manual após processamento bem-sucedido
///  • Resiliência    → mensagens com erro vão para DLQ (não bloqueiam o pipeline)
///  • Observabilidade→ logs estruturados por stage/status
///  • Shutdown limpo → respeita CancellationToken, faz Close() do consumer
/// </summary>
public sealed class OnboardingConsumer : IDisposable
{
    private readonly ILogger<OnboardingConsumer> _logger;
    private readonly IConsumer<string, string> _consumer;
    private readonly DeadLetterProducer _dlq;

    public OnboardingConsumer(ILogger<OnboardingConsumer> logger)
    {
        _logger = logger;

        _consumer = new ConsumerBuilder<string, string>(ConsumerConfiguration.Build())
            .SetErrorHandler((_, e) =>
                _logger.LogError("🔴 Kafka error: {Reason} (IsFatal={IsFatal})", e.Reason, e.IsFatal))
            .SetPartitionsAssignedHandler((_, partitions) =>
                _logger.LogInformation("📌 Partições atribuídas: [{Partitions}]",
                    string.Join(", ", partitions.Select(p => p.Partition.Value))))
            .SetPartitionsRevokedHandler((_, partitions) =>
                _logger.LogWarning("⚠️ Partições revogadas: [{Partitions}]",
                    string.Join(", ", partitions.Select(p => $"{p.Partition.Value}@{p.Offset.Value}"))))

            .Build();

        _dlq = new DeadLetterProducer(
            ConsumerConfiguration.BootstrapServers,
            ConsumerConfiguration.DeadLetterTopic);
    }

    public async Task RunAsync(CancellationToken ct)
    {
        _consumer.Subscribe(ConsumerConfiguration.Topic);

        _logger.LogInformation(
            "📡 Consumer iniciado | topic={Topic} | group={GroupId} | dlq={Dlq}",
            ConsumerConfiguration.Topic,
            ConsumerConfiguration.GroupId,
            ConsumerConfiguration.DeadLetterTopic);

        var processed = 0;
        var failed = 0;

        try
        {
            while (!ct.IsCancellationRequested)
            {
                ConsumeResult<string, string>? result = null;

                try
                {
                    result = _consumer.Consume(ct);

                    // 🏁 Fim da partição — útil pra debug, não é erro
                    if (result.IsPartitionEOF)
                    {
                        _logger.LogDebug("🏁 EOF | partition={Partition} | offset={Offset}",
                            result.Partition.Value, result.Offset.Value);
                        continue;
                    }

                    // 📥 Deserializa
                    var evt = JsonSerializer.Deserialize<OnboardingEvent>(result.Message.Value)
                              ?? throw new InvalidOperationException("Payload deserializado é nulo.");

                    // ⚙️ Processa
                    await ProcessAsync(evt, result, ct);

                    // ✅ Commit manual (at-least-once)
                    _consumer.Commit(result);
                    processed++;
                }
                catch (ConsumeException ex)
                {
                    // Erro de infra do Kafka (não tem mensagem pra mandar pra DLQ)
                    _logger.LogError(ex, "❌ Erro de consumo: {Reason}", ex.Error.Reason);
                }
                catch (OperationCanceledException)
                {
                    throw; // propaga pro outer catch
                }
                catch (Exception ex) when (result is not null)
                {
                    // 💀 Mensagem envenenada → DLQ
                    failed++;
                    _logger.LogError(ex,
                        "💀 Falha ao processar | key={Key} | partition={Partition} | offset={Offset} → DLQ",
                        result.Message.Key, result.Partition.Value, result.Offset.Value);

                    try
                    {
                        await _dlq.SendAsync(
                            key: result.Message.Key ?? string.Empty,
                            rawPayload: result.Message.Value ?? string.Empty,
                            exception: ex,
                            sourceTopic: result.Topic,
                            partition: result.Partition.Value,
                            offset: result.Offset.Value,
                            ct: ct);

                        // Commit pra não reprocessar uma mensagem envenenada
                        _consumer.Commit(result);
                    }
                    catch (Exception dlqEx)
                    {
                        // Se a DLQ falhar, NÃO commita — vamos reprocessar
                        _logger.LogCritical(dlqEx,
                            "🚨 Falha ao enviar para DLQ — offset NÃO commitado, será reprocessado.");
                    }
                }
            }
        }
        catch (OperationCanceledException)
        {
            _logger.LogInformation("🛑 Cancelamento solicitado — encerrando consumer...");
        }
        finally
        {
            _logger.LogInformation(
                "📊 Resumo | processados={Processed} | falhas(DLQ)={Failed}",
                processed, failed);

            // Close() faz commit dos offsets pendentes e revoga partições
            _consumer.Close();
            _logger.LogInformation("👋 Consumer fechado com segurança.");
        }
    }

    /// <summary>
    /// Lógica de negócio do onboarding.
    /// Hoje só loga; futuramente: persistir, chamar APIs, emitir eventos derivados, etc.
    /// </summary>
    private Task ProcessAsync(
        OnboardingEvent evt,
        ConsumeResult<string, string> result,
        CancellationToken ct)
    {
        // 🧪 Simulação de "mensagem envenenada" para testar a DLQ
        // (descomente para testar o fluxo de erro)
        // if (evt.Status == "FORCE_ERROR")
        //     throw new InvalidOperationException("Erro simulado para DLQ");

        // 🎯 Validação básica
        if (string.IsNullOrWhiteSpace(evt.CustomerId))
            throw new InvalidOperationException("CustomerId obrigatório.");

        if (!OnboardingStages.All.Contains(evt.Stage))
            throw new InvalidOperationException($"Stage inválido: '{evt.Stage}'");

        if (!OnboardingStatus.All.Contains(evt.Status))
            throw new InvalidOperationException($"Status inválido: '{evt.Status}'");

        // 📊 Log estruturado — Serilog/Seq/Elastic vão adorar
        _logger.LogInformation(
            "✅ {Stage}/{Status} | customer={CustomerId} | event={EventId} | partition={Partition} | offset={Offset}",
            evt.Stage,
            evt.Status,
            evt.CustomerId,
            evt.EventId,
            result.Partition.Value,
            result.Offset.Value);

        return Task.CompletedTask;
    }

    public void Dispose()
    {
        _consumer?.Dispose();
        _dlq?.Dispose();
    }
}
