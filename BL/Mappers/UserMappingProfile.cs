using AutoMapper;
using BL.Dto_s;
using Domain;

namespace BL.Mappers;

public class UserMappingProfile : Profile
{
    public UserMappingProfile()
    {
        CreateMap<User, UserDto>();
        CreateMap<UserDto, User>();
        
        CreateMap<RegisterUserDto, User>();
        CreateMap<User, RegisterUserDto>();
        
        CreateMap<AddUserDto, User>();
        CreateMap<User, AddUserDto>();
        
        CreateMap<UpdateUserDto, User>();
        CreateMap<User, UpdateUserDto>();
    }
}