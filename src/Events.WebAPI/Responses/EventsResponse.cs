using Events.WebAPI.Models;

namespace Events.WebAPI.Responses;

public class EventsResponse(Event[] events)
{
    public long Count { get; set; } = events.Length;
    public Event[] Events { get; set; } = events;
}