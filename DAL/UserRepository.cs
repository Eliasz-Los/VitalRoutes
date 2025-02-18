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
    
    public async Task<User> ReadUserByEmail(string email)
    {
        return await _context.Users.FirstOrDefaultAsync(u => u.Email.ToLower() == email.ToLower());
    }
    
    public async Task<User> UpdateUser(User user)
    {
        _context.Users.Update(user);
        await _context.SaveChangesAsync();
        return user;
    }
    
    public async Task<User> ReadUserById(Guid id)
    {
        return await _context.Users.FirstOrDefaultAsync(u => u.Id == id);
    }
    
}