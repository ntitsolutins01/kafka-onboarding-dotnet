using Bogus;
using KafkaOnboarding.Models;

namespace KafkaOnboarding.Services;

public class EventGenerator
{
    private readonly Faker<OnboardingEvent> _faker;

    public EventGenerator()
    {
        _faker = new Faker<OnboardingEvent>("pt_BR")
            .RuleFor(e => e.CustomerId, f => $"CUST-{f.Random.Number(1000, 9999)}")
            .RuleFor(e => e.EventId, f => Guid.NewGuid().ToString())
            .RuleFor(e => e.Stage, f => f.PickRandom(OnboardingStages.All))
            .RuleFor(e => e.Status, f => f.Random.WeightedRandom(
                OnboardingStatus.All,
                new[] { 0.75f, 0.15f, 0.10f } // 75% success, 15% failed, 10% pending
            ))
            .RuleFor(e => e.Timestamp, f => DateTime.UtcNow)
            .RuleFor(e => e.Metadata, f => new Dictionary<string, string>
            {
                { "source", f.PickRandom("web", "mobile", "api") },
                { "country", f.Address.CountryCode() },
                { "ip", f.Internet.Ip() }
            });
    }

    public OnboardingEvent Generate() => _faker.Generate();

    public IEnumerable<OnboardingEvent> GenerateBatch(int count) => _faker.Generate(count);
}