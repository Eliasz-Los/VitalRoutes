using BL.Dto_s;
using DAL;
using Domain;
using FirebaseAdmin.Auth;

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
    
    public async Task AddUserAsync(AddUserDto user)
    {
        User newUser = new User(
            user.FirstName, 
            user.LastName, 
            user.Email, 
            user.TelephoneNr, 
            user.Function);
        await _userRepository.CreateUserAsync(newUser);
    }
}