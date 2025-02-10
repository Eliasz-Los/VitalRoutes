using System;

namespace Domain;

public class Notification
{
    public Guid Id {get; set;}
    public string Message {get; set;}
    public DateTime TimeStamp {get; set;} =  DateTime.UtcNow.ToUniversalTime().AddHours(2);
    public Emergency Emergency {get; set;}
    
    public Notification(string message)
    {
        Message = message;
    }
}