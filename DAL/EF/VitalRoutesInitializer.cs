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
        //TODO: Implement seeding
        User user1 = new User("Walter", "heisenberg", "walter.burgir@hotmail.com","0411228828" ,Function.Patient);
        User user2 = new User("Jesse", "Pinkman", "jesse.pinkman@hotmail.com","0411228828" ,Function.Patient);
        User user3 = new User("Gustavo", "Fring", "gustavo.fring@hotmail.com","0412345678" ,Function.Doctor);
        User user4 = new User("Mike", "Ehrmentraut", "mike.erhmrgir@hotmail.com","0495687812" ,Function.Nurse);
        
        
        context.Users.AddRange(user1, user2, user3, user4);
        context.SaveChanges();
        //context.ChangeTracker.Clear();
    }
}