using DAL;
using Domain;

namespace BL;

public class UserManager
{
    private readonly UserRepository _userRepository;

    public UserManager(UserRepository userRepository)
    {
        _userRepository = userRepository;
    }
    
    public async Task<User> GetUserByFirebaseUidAsync(string firebaseUid)
    {
        return await _userRepository.ReadUserByFirebaseUidAsync(firebaseUid);
    }
    
    public async Task AddUserAsync(User user)
    {
        await _userRepository.CreateUserAsync(user);
    }
}