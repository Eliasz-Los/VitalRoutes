using DAL.EF;
using Domain;
using Domain.Enums;
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
    
    public async Task<User> ReadUserByEmail(string email)
    {
        var user = await _context.Users
            .Include(u => u.UnderSupervisions)
            .FirstOrDefaultAsync(u => u.Email.ToLower() == email.ToLower());

        if (user == null)
        {
            throw new Exception($"Geen gebruiker gevonden met e-mail: {email}");
        }

        return user;
    }


    public async Task<User> UpdateUser(User user)
    {
        _context.Users.Update(user);
        await _context.SaveChangesAsync();
        return user;
    }
    
    public async Task<User> ReadUserById(Guid id)
    {
        var user = await _context.Users
            .Include(u => u.UnderSupervisions) 
            .FirstOrDefaultAsync(u => u.Id == id);
        
        if (user == null)
        {
            throw new Exception($"Geen gebruiker gevonden met ID: {id}");
        }
        
        return user;
    }
    
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

        if (supervisor != null && supervisee != null)
        {
            ((List<User>)supervisor.UnderSupervisions).Remove(supervisee);
            await _context.SaveChangesAsync();
        }
    }

    public async Task<List<User>> ReadUsersByFunction(Function function)
    {
        var users = await _context.Users.Where(u => u.Function == function).ToListAsync();
        return users;
    }
}