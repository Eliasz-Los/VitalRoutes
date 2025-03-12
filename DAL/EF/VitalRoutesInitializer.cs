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
        
        // ******** Doctors ********
        User user1 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287fc1"),"Gustavo", "Fring", "gustavo.fring@hotmail.com", "0412345678", Function.Doctor, null, hospital1, null)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        
        User user2 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287fc2"),"Lora", "Flora", "lora.flora@hotmail.com", "0412345679", Function.Doctor, null, hospital1, null)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        User user3 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287fc3"),"Julia", "Goossens", "julia.goossens@hotmail.com", "0412345671", Function.Doctor, null, hospital1, null)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        
        // ******** Headnurse ********
        User user4 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287fc4"),"Hans", "Carlson", "hans.carlson@hotmail.com", "0411228838", Function.HeadNurse, null, hospital1, null)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        
        // ******** Nurses ********
        User user5 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287fc5"),"Mike", "Ehrmentraut", "mike.erhmrgir@hotmail.com", "0495687812", Function.Nurse, null, hospital1, null)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        User user6 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287fc6"),"Maria", "Haya", "maria.haya@hotmail.com", "0495687813", Function.Nurse, null, hospital1, null)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        User user7 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287fc7"),"Michael", "Bidon", "michael.bidon@hotmail.com", "0495687814", Function.Nurse, null, hospital1, null)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        
        // ******** Patients ********
        User user8 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287fc8"),"Walter", "heisenberg", "walter.burgir@hotmail.com", "0495687815", Function.Patient, null, hospital1, null)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        User user9 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287fc9"),"Jesse", "Pinkman", "jesse.pinkman@hotmail.com", "0495687816", Function.Patient, null, hospital1, null)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        
        User user10 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287f10"),"Simon", "Stoofvleesman", "simon.stoofvleesman@hotmail.com", "0495687817", Function.Patient, null, hospital1, null)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        User user11 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287f11"),"Timmy", "Neutron", "timmy.neutron@hotmail.com", "0495687818", Function.Patient, null, hospital1, null)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        User user12 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287f12"),"Rick", "Boris", "rick.boris@hotmail.com", "0495687819", Function.Patient, null, hospital1, null)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        User user13 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287f13"),"Dirk", "Verbelen", "dirk.verbelen@hotmail.com", "0495687820", Function.Patient, null, hospital1, null)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        User user14 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287f14"),"Joe", "White", "joe.white@hotmail.com", "0495687821", Function.Patient, null, hospital1, null)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        User user15 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287f15"),"Peter", "Pan", "peter.pan@hotmail.com", "0495687822", Function.Patient, null, hospital1, null)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        User user16 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287f16"),"Pepe", "Frogger", "pepe.frogger@hotmail.com", "0495687823", Function.Patient, null, hospital1, null)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        User user17 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287f17"),"Lex", "Frietman", "lex.frietman@hotmail.com", "0495687824", Function.Patient, null, hospital1, null)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        
        // ******** System Admin ********
        User user18 = new User(Guid.Parse("019527ff-c8a3-79e7-b7db-c76ade287f18"),"Steffen", "Vochten", "steffen.vochten@hotmail.com", "0495687825", Function.SystemAdmin, null, hospital1, null)
        {
            UnderSupervisions = new List<User>(),
            Supervisors = new List<User>()
        };
        
        
        List<Room> roomsFloorMinus1Groenplaats = new List<Room>
        {
            new (new Point(1061.0,1479.0, floorplanGPMinus1), user8, -102),
            // NEW 1061.0,1479.0 : OLD 100.01, 168.01
            new (new Point(1592.0,1449.0, floorplanGPMinus1), user9, -101),
            // 1592.0,1449.0 : 147.01, 168.01
            new (new Point( 2164.0,1445.0, floorplanGPMinus1), user10, -100),
            // 2164.0,1445.0 : 194.01, 168.01
            new (new Point(2816.0,1479.0, floorplanGPMinus1), user11, -114),
            // 2816.0,1479.0 : 246.01, 168.01
            new (new Point(3414.0, 1479.0, floorplanGPMinus1), user12, -113),
            // 3414.0, 1479.0 : 298.01, 168.01
            new (new Point(3469.0 ,974.0 , floorplanGPMinus1), user13, -111),
            // 3469.0 ,974.0 : 305.01, 128.01,
            new (new Point(2942.0, 860.0 , floorplanGPMinus1), user14, -109),
            // 2942.0, 860.0 : 258.01, 123.01
            new (new Point(1318.0 ,889.0, floorplanGPMinus1), user15, -106),
            // 1318.0 ,889.0 : 120.01, 115.01
            new (new Point(447.0 ,1482.0, floorplanGPMinus1), user16, -103),
            // 447.0 ,1482.0
            new (new Point(3045.0 ,368.0, floorplanGPMinus1), user17, -110),
            // 3045.0 ,368.0
        };
        
        context.Hospitals.Add(hospital1);
        context.UserLocations.AddRange(userLocation1, userLocation2, userLocation3, userLocation4);
        context.Users.AddRange(user1, user2, user3, user4, user5, user6, user7, user8, user9, user10, user11, user12, user13, user14, user15, user16, user17, user18);
        context.Floorplans.AddRange(gpFloorplans);
        context.Rooms.AddRange(roomsFloorMinus1Groenplaats);
        context.SaveChanges();
        context.ChangeTracker.Clear();
    }
}