using KafkaOnboarding.Producer;
using Microsoft.Extensions.Logging;

// 🎨 Setup de logging
using var loggerFactory = LoggerFactory.Create(builder =>
{
    builder.AddSimpleConsole(options =>
    {
        options.SingleLine = true;
        options.TimestampFormat = "HH:mm:ss ";
    });
});

// 🧭 Roteamento por argumento de linha de comando
var mode = args.Length > 0 ? args[0].ToLower() : "producer";

switch (mode)
{
    case "producer":
        var producerLogger = loggerFactory.CreateLogger<OnboardingProducer>();
        var producer = new OnboardingProducer(producerLogger);
        await producer.RunAsync();
        break;

    // 📌 Reservado pro Passo 3 (Consumer .NET)
    // case "consumer":
    //     var consumerLogger = loggerFactory.CreateLogger<OnboardingConsumer>();
    //     var consumer = new OnboardingConsumer(consumerLogger);
    //     await consumer.RunAsync();
    //     break;

    default:
        Console.WriteLine($"❌ Unknown mode: {mode}");
        Console.WriteLine("Usage: dotnet run [producer|consumer]");
        Environment.Exit(1);
        break;
}