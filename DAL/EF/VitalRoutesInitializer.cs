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

        User user1 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287fc1"),"Gustavo", "Fring", "gustavo.fring@hotmail.com", "0412345678", Function.Doctor, userLocation3, hospital1)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        User user2 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287fc2"),"Mike", "Ehrmentraut", "mike.erhmrgir@hotmail.com", "0495687812", Function.Doctor, userLocation4, hospital1)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        User user3 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287fc3"),"Walter", "heisenberg", "walter.burgir@hotmail.com", "0411228828", Function.Patient, userLocation1, hospital1)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        User user4 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287fc4"),"Jesse", "Pinkman", "jesse.pinkman@hotmail.com", "0411228828", Function.HeadNurse, userLocation2, hospital1)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        
        List<Room> roomsFloorMinus1Groenplaats = new List<Room>
        {
            new (new Point(1061.0,1479.0, floorplanGPMinus1), user3, -102),
            // NEW 1061.0,1479.0 : OLD 100.01, 168.01
            new (new Point(1592.0,1449.0, floorplanGPMinus1), user2, -101),
            // 1592.0,1449.0 : 147.01, 168.01
            new (new Point( 2164.0,1445.0, floorplanGPMinus1), null, -100),
            // 2164.0,1445.0 : 194.01, 168.01
            new (new Point(2816.0,1479.0, floorplanGPMinus1), null, -114),
            // 2816.0,1479.0 : 246.01, 168.01
            new (new Point(3414.0, 1479.0, floorplanGPMinus1), null, -113),
            // 3414.0, 1479.0 : 298.01, 168.01
            new (new Point(3469.0 ,974.0 , floorplanGPMinus1), null, -111),
            // 3469.0 ,974.0 : 305.01, 128.01,
            new (new Point(2942.0, 860.0 , floorplanGPMinus1), null, -109),
            // 2942.0, 860.0 : 258.01, 123.01
            new (new Point(1318.0 ,889.0, floorplanGPMinus1), null, -106)
            // 1318.0 ,889.0 : 120.01, 115.01
        };


        context.Hospitals.Add(hospital1);
        context.UserLocations.AddRange(userLocation1, userLocation2, userLocation3, userLocation4);
        context.Users.AddRange(user1, user2, user3, user4);
        context.Floorplans.AddRange(gpFloorplans);
        context.Rooms.AddRange(roomsFloorMinus1Groenplaats);
        context.SaveChanges();
        context.ChangeTracker.Clear();
    }
}