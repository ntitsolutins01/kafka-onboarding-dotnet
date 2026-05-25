using System.Text.Json;
using Confluent.Kafka;
using KafkaOnboarding.Models;
using KafkaOnboarding.Services;
using Microsoft.Extensions.Logging;

namespace KafkaOnboarding.Producer;

public class OnboardingProducer
{
    private readonly ILogger<OnboardingProducer> _logger;
    private readonly string _bootstrapServers;
    private readonly string _topic;
    private readonly int _eventsPerSecond;
    private readonly int _totalEvents;

    public OnboardingProducer(ILogger<OnboardingProducer> logger)
    {
        _logger = logger;
        _bootstrapServers = Environment.GetEnvironmentVariable("KAFKA_BOOTSTRAP_SERVERS")
                            ?? "localhost:9092";
        _topic = Environment.GetEnvironmentVariable("KAFKA_TOPIC")
                 ?? "onboarding-events";
        _eventsPerSecond = int.Parse(Environment.GetEnvironmentVariable("EVENTS_PER_SECOND") ?? "5");
        _totalEvents = int.Parse(Environment.GetEnvironmentVariable("TOTAL_EVENTS") ?? "100");
    }

    public async Task RunAsync(CancellationToken cancellationToken = default)

    {
        var config = new ProducerConfig
        {
            BootstrapServers = _bootstrapServers,
            ClientId = "onboarding-producer-dotnet",
            Acks = Acks.All,
            EnableIdempotence = true,
            MessageSendMaxRetries = 3,
            CompressionType = CompressionType.Snappy
        };

        _logger.LogInformation("🚀 Starting Onboarding Producer");
        _logger.LogInformation("📡 Bootstrap Servers: {Servers}", _bootstrapServers);
        _logger.LogInformation("📬 Topic: {Topic}", _topic);
        _logger.LogInformation("⚡ Rate: {Rate} events/sec | Total: {Total}", _eventsPerSecond, _totalEvents);

        using var producer = new ProducerBuilder<string, string>(config)
            .SetErrorHandler((_, e) => _logger.LogError("❌ Kafka error: {Reason}", e.Reason))
            .Build();

        var generator = new EventGenerator();
        var delayMs = 1000 / _eventsPerSecond;
        var successCount = 0;
        var failCount = 0;

        for (int i = 1; i <= _totalEvents; i++)
        {
            var evt = generator.Generate();
            var json = JsonSerializer.Serialize(evt);

            try
            {
                var result = await producer.ProduceAsync(_topic, new Message<string, string>
                {
                    Key = evt.CustomerId,
                    Value = json
                });

                successCount++;
                _logger.LogInformation(
                    "✅ [{Index}/{Total}] {Stage}/{Status} → {Customer} (p:{Partition}, o:{Offset})",
                    i, _totalEvents, evt.Stage, evt.Status, evt.CustomerId,
                    result.Partition.Value, result.Offset.Value);
            }
            catch (ProduceException<string, string> ex)
            {
                failCount++;
                _logger.LogError("❌ Failed to deliver message: {Reason}", ex.Error.Reason);
            }

            await Task.Delay(delayMs);
        }

        producer.Flush(TimeSpan.FromSeconds(10));
        _logger.LogInformation("🎉 Done! Success: {Success} | Failed: {Failed}", successCount, failCount);
    }
}
