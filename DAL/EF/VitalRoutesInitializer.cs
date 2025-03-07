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
        
        Floorplan floorplanGPMinus1 = new Floorplan("kelder", -1, "1/200", "floor_minus1.png");

        List<Floorplan> gpFloorplans = new List<Floorplan>
        {
            floorplanGPMinus1,
            new ("gelijkvloers", 0, "1/200","floor0.png"),
            new ("eerste verdiep", 1, "1/200","floor1.png"),
            new ("tweede verdiep", 2, "1/200","floor2.png"),
            new ("derde verdiep", 3, "1/200","floor3.png"),
            new ("vierde verdiep", 4, "1/200","floor4.png"),
            new ("vijfde verdiep", 5, "1/200","floor5.png"),
            new ("zesde verdiep", 6, "1/200","floor6.png"),
        };
        
        hospital1.Floorplans = gpFloorplans;
        
        UserLocation userLocation1 = new UserLocation(1, 1);
        UserLocation userLocation2 = new UserLocation(2, 2);
        UserLocation userLocation3 = new UserLocation(3, 3);
        UserLocation userLocation4 = new UserLocation(4, 4);
        UserLocation userLocation5 = new UserLocation(4, 3);

        User user1 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287fc1"),"Gustavo", "Fring", "gustavo.fring@hotmail.com", "0412345678", Function.Doctor, userLocation3, hospital1)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        User user2 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287fc2"),"Mike", "Ehrmentraut", "mike.erhmrgir@hotmail.com", "0495687812", Function.Nurse, userLocation4, hospital1)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        User user3 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287fc3"),"Walter", "heisenberg", "walter.burgir@hotmail.com", "0411228828", Function.Patient, userLocation1, hospital1)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        User user4 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287fc4"),"Jesse", "Pinkman", "jesse.pinkman@hotmail.com", "0411228828", Function.Patient, userLocation2, hospital1)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        User user5 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287fc5"),"Hans", "Carlson", "hans.carlson@hotmail.com", "0411228838", Function.HeadNurse, userLocation5, hospital1)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        
        List<Room> roomsFloorMinus1Groenplaats = new List<Room>
        {
            new (new Point(100.01, 168.01, floorplanGPMinus1), user1, -102),
            new (new Point(147.01, 168.01, floorplanGPMinus1), user2, -101),
            new (new Point(194.01, 168.01, floorplanGPMinus1), null, -100),
            new (new Point(246.01, 168.01, floorplanGPMinus1), null, -114),
            new (new Point(298.01, 168.01, floorplanGPMinus1), null, -113),
            new (new Point(305.01, 128.01, floorplanGPMinus1), null, -111),
            new (new Point(258.01, 123.01, floorplanGPMinus1), null, -109),
            new (new Point(120.01, 115.01, floorplanGPMinus1), null, -106)
        };
        
        context.Hospitals.Add(hospital1);
        context.UserLocations.AddRange(userLocation1, userLocation2, userLocation3, userLocation4);
        context.Users.AddRange(user1, user2, user3, user4, user5);
        context.Floorplans.AddRange(gpFloorplans);
        context.Rooms.AddRange(roomsFloorMinus1Groenplaats);
        context.SaveChanges();
        context.ChangeTracker.Clear();
    }
}