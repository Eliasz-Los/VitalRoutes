using System;
using Domain.Enums;

namespace Domain;

public class Emergency
{
    public Guid Id {get; set;}
    public int ChamberNr {get; set;}
    public EmergencyLevel EmergencyLevel {get; set;}
    public User User {get; set;}
    public Notification Notification {get; set;}
    
    public Emergency(int chamberNr, EmergencyLevel emergencyLevel)
    {
        ChamberNr = chamberNr;
        EmergencyLevel = emergencyLevel;
    }
}