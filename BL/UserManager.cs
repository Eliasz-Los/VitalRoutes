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
    
    /*public async Task RegisterUserAsync(AddUserDto addUserDto, string password)
    {
        //create user in firebase
        var userRecordArgs = new UserRecordArgs()
        {
            Email = addUserDto.Email,
            EmailVerified = false,
            Password = password,
            DisplayName = $"{addUserDto.FirstName} {addUserDto.LastName}",
            Disabled = false
        }; 
        
        UserRecord userRecord = await FirebaseAuth.DefaultInstance.CreateUserAsync(userRecordArgs);
       
        var user = new User(
            addUserDto.FirebaseUid, 
            addUserDto.FirstName, 
            addUserDto.LastName, 
            addUserDto.Email, 
            addUserDto.TelephoneNr, 
            addUserDto.Function);
        
        await AddUserAsync(user);
    }*/
}