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
    public UserManager(UserRepository userRepository, IMapper mapper)
    {
        _userRepository = userRepository;
        _mapper = mapper;
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
            Uid = userDto.Uid
        });
        return _mapper.Map<UpdateUserDto>(updatedUser);
    }
}