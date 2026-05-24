// Producer/ThermostatProducer.cs
using Confluent.Kafka;
using System.Text.Json;
using KafkaOnboarding.Models;

namespace KafkaOnboarding.Producer;

public class ThermostatProducer
{
    private const string Topic = "thermostat-readings";

    private readonly ProducerConfig _config = new()
    {
        BootstrapServers = "localhost:9092",
        Acks             = Acks.All,          // garante durabilidade
        EnableIdempotence = true              // evita duplicatas
    };

    public async Task RunAsync()
    {
        using var producer = new ProducerBuilder<string, string>(_config).Build();

        var readings = new List<ThermostatReading>
        {
            new(1,  "kitchen",  22.5, DateTime.UtcNow),
            new(2,  "living",   21.0, DateTime.UtcNow),
            new(3,  "bedroom",  19.8, DateTime.UtcNow),
            new(42, "kitchen",  24.0, DateTime.UtcNow), // mesma chave → mesma partição
            new(42, "kitchen",  26.3, DateTime.UtcNow)
        };

        foreach (var reading in readings)
        {
            var key   = $"sensor-{reading.SensorId}";
            var value = JsonSerializer.Serialize(reading);

            var result = await producer.ProduceAsync(
                Topic,
                new Message<string, string> { Key = key, Value = value }
            );

            Console.WriteLine(
                $"✅ Enviado | Sensor: {reading.SensorId} | " +
                $"Partição: {result.Partition.Value} | " +
                $"Offset: {result.Offset.Value} | " +
                $"Temp: {reading.Temperature}°C"
            );
        }

        producer.Flush(TimeSpan.FromSeconds(10));
        Console.WriteLine("🏁 Producer finalizado.");
    }
}