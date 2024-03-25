namespace Events.WebAPI.Models;

public class Event
{
    public string Name { get; set; }
    public DateTime Time { get; set; }
    public string Description { get; set; }
    public int Price { get; set; }
}