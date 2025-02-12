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
    
    public async Task CreateUserAsync(User user)
    {
        _context.Users.Add(user);
        await _context.SaveChangesAsync();
    }
    
    public async Task<User> ReadUserByEmailAsync(string email)
    {
        return await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
    }
    
}