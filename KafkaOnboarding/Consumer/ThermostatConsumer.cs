// Consumer/ThermostatConsumer.cs
using Confluent.Kafka;
using System.Text.Json;
using KafkaOnboarding.Models;

namespace KafkaOnboarding.Consumer;

public class ThermostatConsumer
{
    private const string Topic = "thermostat-readings";
    private const string GroupId = "thermostat-group";

    private readonly ConsumerConfig _config = new()
    {
        BootstrapServers = "localhost:9092",
        GroupId = GroupId,
        AutoOffsetReset = AutoOffsetReset.Earliest,
        EnableAutoCommit = false   // commit manual = mais controle
    };

    public void Run(CancellationToken ct)
    {
        using var consumer = new ConsumerBuilder<string, string>(_config).Build();
        consumer.Subscribe(Topic);

        Console.WriteLine("🎧 Aguardando mensagens... (Ctrl+C para sair)\n");

        try
        {
            while (!ct.IsCancellationRequested)
            {
                var result = consumer.Consume(ct);

                var reading = JsonSerializer.Deserialize<ThermostatReading>(
                    result.Message.Value
                );

                Console.WriteLine(
                    $"📩 Key: {result.Message.Key} | " +
                    $"Local: {reading?.Location} | " +
                    $"Temp: {reading?.Temperature}°C | " +
                    $"Partição: {result.Partition.Value} | " +
                    $"Offset: {result.Offset.Value}"
                );

                // Alerta de temperatura alta
                if (reading?.Temperature > 25)
                    Console.WriteLine($"🔥 ALERTA: Temperatura alta em {reading.Location}!");

                // Commit manual do offset
                consumer.Commit(result);
            }
        }
        catch (OperationCanceledException)
        {
            Console.WriteLine("\n🛑 Consumer encerrado com segurança.");
        }
        finally
        {
            consumer.Close();
        }
    }
}