using Confluent.Kafka;
using System.Text;

namespace KafkaOnboarding.Consumer.DeadLetter;

/// <summary>
/// Envia mensagens com erro para um topico DLQ.
/// Permite analise posterior sem bloquear o pipeline.
/// </summary>
public sealed class DeadLetterProducer : IDisposable
{
    private readonly IProducer<string, string> _producer;
    private readonly string _topic;

    public DeadLetterProducer(string bootstrapServers, string dlqTopic)
    {
        var config = new ProducerConfig
        {
            BootstrapServers = bootstrapServers,
            Acks = Acks.All,
            EnableIdempotence = true,
            ClientId = "dlq-producer"
        };

        _producer = new ProducerBuilder<string, string>(config).Build();
        _topic = dlqTopic;
    }

    public async Task SendAsync(
        string key,
        string rawPayload,
        Exception exception,
        string sourceTopic,
        int partition,
        long offset,
        CancellationToken ct)
    {
        var headers = new Headers
        {
            { "x-source-topic",     Encoding.UTF8.GetBytes(sourceTopic) },
            { "x-source-partition", Encoding.UTF8.GetBytes(partition.ToString()) },
            { "x-source-offset",    Encoding.UTF8.GetBytes(offset.ToString()) },
            { "x-error-type",       Encoding.UTF8.GetBytes(exception.GetType().FullName ?? "unknown") },
            { "x-error-message",    Encoding.UTF8.GetBytes(exception.Message) },
            { "x-failed-at",        Encoding.UTF8.GetBytes(DateTime.UtcNow.ToString("O")) },
        };

        var msg = new Message<string, string>
        {
            Key = key,
            Value = rawPayload,
            Headers = headers
        };

        await _producer.ProduceAsync(_topic, msg, ct);
        _producer.Flush(TimeSpan.FromSeconds(5));
    }

    public void Dispose() => _producer?.Dispose();
}