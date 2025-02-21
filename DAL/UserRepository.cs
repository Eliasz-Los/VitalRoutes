using DAL.EF;
using Domain;
using Microsoft.EntityFrameworkCore;

namespace DAL;

public class UserRepository
{
    private readonly VitalRoutesDbContext _context;

    public UserRepository(VitalRoutesDbContext context)
    {
        _context = context;
    }
    
    public async Task CreateUser(User user)
    {
        user.Hospital = await _context.Hospitals.FirstOrDefaultAsync();
        _context.Users.Add(user);
        await _context.SaveChangesAsync();
    }
    
 /*   public async Task<User> ReadUserByEmail(string email)
    {
        return await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
    }*/
    
    public async Task<User> ReadUserByEmail(string email)
    {
        return await _context.Users
            .Include(u => u.UnderSupervisions)
            .FirstOrDefaultAsync(u => u.Email == email);
    }

    
    public async Task<User> UpdateUser(User user)
    {
        _context.Users.Update(user);
        await _context.SaveChangesAsync();
        return user;
    }
    
 /*   public async Task<User> ReadUserById(Guid id)
    {
        return await _context.Users.FirstOrDefaultAsync(u => u.Id == id);
    }*/
    
    public async Task<User> ReadUserById(Guid id)
    {
        return await _context.Users
            .Include(u => u.UnderSupervisions) 
            .FirstOrDefaultAsync(u => u.Id == id);
    }

    
    /*public async Task AddUnderSupervision(Guid supervisorId, Guid superviseeId)
    {
        var supervisor = await _context.Users.Include(u => u.UnderSupervisions)
            .FirstOrDefaultAsync(u => u.Id == supervisorId);
        var supervisee = await _context.Users.FirstOrDefaultAsync(u => u.Id == superviseeId);

        if (supervisor == null)
        {
            throw new Exception($"Supervisor with ID {supervisorId} not found");
        }
        if (supervisee == null)
        {
            throw new Exception($"Supervisee with ID {superviseeId} not found");
        }

        // Voeg de supervisee toe aan de UnderSupervisions van de supervisor, zelfs als deze leeg is
        if (supervisor.UnderSupervisions == null)
        {
            supervisor.UnderSupervisions = new List<User>();
        }
        supervisor.UnderSupervisions.Add(supervisee);

        // Optioneel: Stel SupervisorId in voor de supervisee (als je dat wilt bijhouden)
        supervisee.SupervisorId = supervisorId;

        await _context.SaveChangesAsync();
    }*/
    
    public async Task AddUnderSupervision(Guid supervisorId, Guid superviseeId)
    {
        var supervisor = await _context.Users
            .Include(u => u.UnderSupervisions) 
            .FirstOrDefaultAsync(u => u.Id == supervisorId);
    
        var supervisee = await _context.Users.FirstOrDefaultAsync(u => u.Id == superviseeId);

        if (supervisor == null)
        {
            throw new Exception($"Supervisor met ID {supervisorId} niet gevonden.");
        }
        if (supervisee == null)
        {
            throw new Exception($"Supervisee met ID {superviseeId} niet gevonden.");
        }

        // Voorkom duplicaten in supervisie
        if (!supervisor.UnderSupervisions.Contains(supervisee))
        {
            supervisor.UnderSupervisions.Add(supervisee);
            supervisee.SupervisorId = supervisorId;
        }

        await _context.SaveChangesAsync();
    }

    
    public async Task RemoveUnderSupervision(Guid supervisorId, Guid superviseeId)
    {
        var supervisor = await _context.Users.Include(u => u.UnderSupervisions).FirstOrDefaultAsync(u => u.Id == supervisorId);
        var supervisee = await _context.Users.FirstOrDefaultAsync(u => u.Id == superviseeId);

        if (supervisor != null && supervisee != null && supervisor.UnderSupervisions != null)
        {
            ((List<User>)supervisor.UnderSupervisions).Remove(supervisee);
            await _context.SaveChangesAsync();
        }
    }
}