using AutoMapper;
using BL.Dto_s;
using Domain;

namespace BL.Mappers;

public class UserMappingProfile : Profile
{
    public UserMappingProfile()
    {
        CreateMap<User, UserDto>()
            .ForMember(dest => dest.UnderSupervisions, opt => opt.MapFrom(src => src.UnderSupervisions.Select(u => u.Id).ToList()))
            .ForMember(dest => dest.Supervisors, opt => opt.MapFrom(src => src.Supervisors.Select(u => u.Id).ToList()));

        CreateMap<UserDto, User>()
            .ForMember(dest => dest.UnderSupervisions, opt => opt.Ignore())  // vermijden van referentielussen
            .ForMember(dest => dest.Supervisors, opt => opt.Ignore());
        
        CreateMap<RegisterUserDto, User>();
        CreateMap<User, RegisterUserDto>();
        
        CreateMap<AddUserDto, User>();
        CreateMap<User, AddUserDto>();
        
        CreateMap<UpdateUserDto, User>();
        CreateMap<User, UpdateUserDto>();
    }
}