using System;
using System.Collections.Generic;
using Domain.Enums;

namespace Domain;
public class User
{
    public Guid Id { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public string Email { get; set; }
    public string TelephoneNr { get; set; }
    public Function Function { get; set; }
    public UserLocation? Location { get; set; }
    public Room? Room { get; set; }
    public ICollection<User> UnderSupervisions { get; set; } = new List<User>();
    public ICollection<User> Supervisors { get; set; } = new List<User>();
    public IEnumerable<Emergency> Emergencies { get; set; }
    public Hospital? Hospital { get; set; }
    public User() {}

    public User(Guid id, string firstName, string lastName, string email, string telephoneNr, Function function,
        UserLocation? location, Hospital? hospital, Room? room)
    {
        Id = id;
        FirstName = firstName;
        LastName = lastName;
        Email = email;
        TelephoneNr = telephoneNr;
        Function = function;
        Location = location;
        Hospital = hospital;
        Room = room;
        UnderSupervisions = new List<User>();
        Supervisors = new List<User>();
    }

    public User(Guid id, string firstName, string lastName, string email, string telephoneNr, Function function, UserLocation? location, Hospital? hospital)
    {
        Id = id;
        FirstName = firstName;
        LastName = lastName;
        Email = email;
        TelephoneNr = telephoneNr;
        Function = function;
        Location = location;
        Hospital = hospital;
        UnderSupervisions = new List<User>();
        Supervisors = new List<User>();
    }

    public User(string firstName, string lastName, string email, string telephoneNr)
    {
        FirstName = firstName;
        LastName = lastName;
        Email = email;
        TelephoneNr = telephoneNr;
        UnderSupervisions = new List<User>();
        Supervisors = new List<User>();
    }

    public User(string firstName, string lastName, string email, string telephoneNr, Function function)
    {
        FirstName = firstName;
        LastName = lastName;
        Email = email;
        TelephoneNr = telephoneNr;
        Function = function;
        UnderSupervisions = new List<User>();
        Supervisors = new List<User>();
    }

    public User(string firstName, string lastName, string email, string telephoneNr, Function function, UserLocation location, Hospital hospital)
    {
        FirstName = firstName;
        LastName = lastName;
        Email = email;
        TelephoneNr = telephoneNr;
        Function = function;
        Location = location;
        Hospital = hospital;
        UnderSupervisions = new List<User>();
        Supervisors = new List<User>();
    }
}