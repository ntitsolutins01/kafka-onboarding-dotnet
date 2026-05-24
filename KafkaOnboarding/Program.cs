// Program.cs
using KafkaOnboarding.Producer;
using KafkaOnboarding.Consumer;

var cts = new CancellationTokenSource();
Console.CancelKeyPress += (_, e) =>
{
    e.Cancel = true;
    cts.Cancel();
};

var commandLineArgs = Environment.GetCommandLineArgs();
var mode = commandLineArgs.Length > 1 ? commandLineArgs[1] : "producer";

switch (mode.ToLower())
{
    case "producer":
        var producer = new ThermostatProducer();
        await producer.RunAsync();
        break;

    case "consumer":
        var consumer = new ThermostatConsumer();
        consumer.Run(cts.Token);
        break;

    default:
        Console.WriteLine("Uso: dotnet run -- [producer|consumer]");
        break;
}