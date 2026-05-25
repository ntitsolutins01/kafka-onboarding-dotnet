using KafkaOnboarding.Consumer;
using KafkaOnboarding.Producer;
using Microsoft.Extensions.Logging;

// 🎨 Setup de logging
using var loggerFactory = LoggerFactory.Create(builder =>
{
    builder
        .SetMinimumLevel(LogLevel.Information)
        .AddSimpleConsole(options =>
        {
            options.SingleLine = true;
            options.TimestampFormat = "HH:mm:ss ";
            options.IncludeScopes = false;
        });
});

var appLogger = loggerFactory.CreateLogger("KafkaOnboarding");

// 🧭 Roteamento por argumento de linha de comando
var mode = args.Length > 0 ? args[0].ToLowerInvariant() : "producer";

// 🛑 Graceful shutdown
// Ctrl+C NÃO mata o processo imediatamente — sinaliza cancelamento
// para que producer/consumer fechem com segurança (flush, commit, close).
using var cts = new CancellationTokenSource();

Console.CancelKeyPress += (_, e) =>
{
    e.Cancel = true; // impede o kill imediato do .NET
    appLogger.LogWarning("🛑 Ctrl+C detectado — iniciando shutdown gracioso...");
    cts.Cancel();
};

// 🚀 Execução com tratamento global de erros
try
{
    switch (mode)
    {
        case "producer":
            {
                var logger = loggerFactory.CreateLogger<OnboardingProducer>();
                var producer = new OnboardingProducer(logger);
                await producer.RunAsync(cts.Token);
                break;
            }

        case "consumer":
            {
                var logger = loggerFactory.CreateLogger<OnboardingConsumer>();
                var consumer = new OnboardingConsumer(logger);
                await consumer.RunAsync(cts.Token);
                break;
            }

        default:
            appLogger.LogError("❌ Modo desconhecido: {Mode}", mode);
            Console.WriteLine("Usage: dotnet run -- [producer|consumer]");
            return 1;
    }

    appLogger.LogInformation("✅ Processo finalizado com sucesso.");
    return 0;
}
catch (OperationCanceledException) when (cts.IsCancellationRequested)
{
    // Esperado: cancelamento via Ctrl+C
    appLogger.LogInformation("✅ Shutdown gracioso concluído.");
    return 0;
}
catch (Exception ex)
{
    appLogger.LogCritical(ex, "💥 Erro fatal: {Message}", ex.Message);
    return 1;
}
