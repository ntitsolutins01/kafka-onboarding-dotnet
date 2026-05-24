using System.Text.Json.Serialization;

namespace KafkaOnboarding.Models;

public class OnboardingEvent
{
    [JsonPropertyName("customer_id")]
    public string CustomerId { get; set; } = string.Empty;

    [JsonPropertyName("event_id")]
    public string EventId { get; set; } = Guid.NewGuid().ToString();

    [JsonPropertyName("stage")]
    public string Stage { get; set; } = string.Empty;

    [JsonPropertyName("status")]
    public string Status { get; set; } = string.Empty;

    [JsonPropertyName("timestamp")]
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;

    [JsonPropertyName("metadata")]
    public Dictionary<string, string> Metadata { get; set; } = new();
}

public static class OnboardingStages
{
    public const string Registration = "REGISTRATION";
    public const string KYC = "KYC";
    public const string Validation = "VALIDATION";
    public const string Completed = "COMPLETED";

    public static readonly string[] All = { Registration, KYC, Validation, Completed };
}

public static class OnboardingStatus
{
    public const string Success = "SUCCESS";
    public const string Failed = "FAILED";
    public const string Pending = "PENDING";

    public static readonly string[] All = { Success, Failed, Pending };
}