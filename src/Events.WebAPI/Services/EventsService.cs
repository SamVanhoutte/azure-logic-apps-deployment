using Events.WebAPI.Models;

namespace Events.WebAPI.Services;

public class EventsService
{
    private List<Event> ActiveEvents;
    
    public EventsService()
    {
        ActiveEvents = new List<Event>
        {
            new Event(){Description = "My event", Name = "Event1", Price = 3400, Time = DateTime.Now.AddDays(7)},
            new Event(){Description = "Your event", Name = "Event2", Price = 2700, Time = DateTime.Now.AddDays(14)},
        };
    }

    public Task<List<Event>> GetEventsAsync()
    {
        return Task.FromResult(ActiveEvents);
    }
    
    public Task CreateEventAsync(Event @event)
    {
        ActiveEvents.Add(@event);
        return Task.CompletedTask;
    }
}