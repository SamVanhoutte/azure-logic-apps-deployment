using Events.WebAPI.Models;
using Events.WebAPI.Responses;
using Events.WebAPI.Runtime;
using Events.WebAPI.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using NSwag.Annotations;

namespace Events.WebAPI.Controllers;

/// <summary>
/// API endpoint that exposes Events functionality
/// </summary>
[ApiController]
[Route("events")]
[ApiType(apiType: ApiTypes.Admin)]
public class EventController(EventsService eventsService): ControllerBase
{
    /// <summary>
    /// Get all events
    /// </summary>
    [HttpGet()]
    [ApiType(apiType: ApiTypes.Public)]
    [SwaggerResponse(StatusCodes.Status200OK, typeof(EventsResponse), Description = "The available events.")]
    public async Task<IActionResult> ListEvents()
    {
        var events = await eventsService.GetEventsAsync();
        return Ok(new EventsResponse(events.ToArray()));
    }
    
    /// <summary>
    /// Get all events
    /// </summary>
    [HttpPost()]
    [SwaggerResponse(StatusCodes.Status200OK, typeof(void), Description = "The event was created.")]
    public async Task<IActionResult> CreateEvent(Event @event)
    {
        await eventsService.CreateEventAsync(@event);
        return Ok();
    }
}