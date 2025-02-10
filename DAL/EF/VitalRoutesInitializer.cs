using System.Collections.Generic;
using Domain;
using Domain.Enums;

namespace DAL.EF;

public class VitalRoutesInitializer
{
    public static void Initialize(VitalRoutesDbContext context, bool dropDatabase = false)
    {
        if (dropDatabase)
            context.Database.EnsureDeleted();
        if (context.Database.EnsureCreated())
            Seed(context);
    }

    private static void Seed(VitalRoutesDbContext context)
    {
        Hospital hospital1 = new Hospital("UZ Groenplaats");

        List<Floorplan> gpFloorplans = new List<Floorplan>
        {
            new ("kelder", -1, "1/200", "floor_minus1.svg"),
            new ("gelijkvloers", 0, "1/200","floor0.svg"),
            new ("eerste verdiep", 1, "1/200","floor1.svg"),
            new ("tweede verdiep", 2, "1/200","floor2.svg"),
            new ("derde verdiep", 3, "1/200","floor3.svg"),
            new ("vierde verdiep", 4, "1/200","floor4.svg"),
            new ("vijfde verdiep", 5, "1/200","floor5.svg"),
            new ("zesde verdiep", 6, "1/200","floor6.svg"),
        };
        
        hospital1.Floorplans = gpFloorplans;
        
        UserLocation userLocation1 = new UserLocation(1, 1);
        UserLocation userLocation2 = new UserLocation(2, 2);
        UserLocation userLocation3 = new UserLocation(3, 3);
        UserLocation userLocation4 = new UserLocation(4, 4);
        
        User user1 = new User("Walter", "heisenberg", "walter.burgir@hotmail.com","0411228828" ,Function.Patient, userLocation1, hospital1);
        User user2 = new User("Jesse", "Pinkman", "jesse.pinkman@hotmail.com","0411228828" ,Function.Patient, userLocation2, hospital1);
        User user3 = new User("Gustavo", "Fring", "gustavo.fring@hotmail.com","0412345678" ,Function.Doctor, userLocation3, hospital1);
        User user4 = new User("Mike", "Ehrmentraut", "mike.erhmrgir@hotmail.com","0495687812" ,Function.Nurse, userLocation4, hospital1);
        
        context.Hospitals.Add(hospital1);
        context.UserLocations.AddRange(userLocation1, userLocation2, userLocation3, userLocation4);
        context.Users.AddRange(user1, user2, user3, user4);
        context.Floorplans.AddRange(gpFloorplans);
        context.SaveChanges();
        context.ChangeTracker.Clear();
    }
}