// Models/ThermostatReading.cs
namespace KafkaOnboarding.Models;

public record ThermostatReading(
    int    SensorId,
    string Location,
    double Temperature,
    DateTime EventTime
);