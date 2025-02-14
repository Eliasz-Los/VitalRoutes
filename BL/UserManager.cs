using AutoMapper;
using BL.Dto_s;
using DAL;
using Domain;
using FirebaseAdmin.Auth;

namespace BL;

public class UserManager
{
    private readonly UserRepository _userRepository;
    private readonly IMapper _mapper;
    private readonly FirebaseAuthManager _firebaseAuthManager;
    public UserManager(UserRepository userRepository, IMapper mapper, FirebaseAuthManager firebaseAuthManager)
    {
        _userRepository = userRepository;
        _mapper = mapper;
        _firebaseAuthManager = firebaseAuthManager;
    }
    
    
    public async Task AddUser(AddUserDto user)
    {
        User newUser = new User(
            user.FirstName, 
            user.LastName, 
            user.Email, 
            user.TelephoneNr, 
            user.Function);
        await _userRepository.CreateUser(newUser);
    }
    
    public async Task<UserDto> GetUserByEmail(string email)
    {
        var user = await _userRepository.ReadUserByEmail(email);
        return _mapper.Map<UserDto>(user);
    }
    
    public async Task<UpdateUserDto> UpdateUser(UpdateUserDto userDto)
    {
        try
        {
            var user = _userRepository.ReadUserById(userDto.Id).Result;
            user.FirstName = userDto.FirstName;
            user.LastName = userDto.LastName;
            user.TelephoneNr = userDto.TelephoneNr;
            user.Email = userDto.Email;
            var updatedUser = await _userRepository.UpdateUser(user);
            await FirebaseAuth.DefaultInstance.UpdateUserAsync(new UserRecordArgs
            {
                Email = userDto.Email,
                PhoneNumber = userDto.TelephoneNr,
                Uid = userDto.Uid,
                Password = userDto.Password
            });
            await _firebaseAuthManager.Login(userDto.Email, userDto.Password);
            return _mapper.Map<UpdateUserDto>(updatedUser);
        }catch(FirebaseAuthException e)
        {
            throw new Exception($"Firebase error: {e.Message}");
        }
    }
}