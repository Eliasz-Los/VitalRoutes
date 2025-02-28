using AutoMapper;
using BL.Dto_s;
using Domain;

namespace BL.Mappers;

public class HospitalMappingProfile : Profile
{
    public HospitalMappingProfile()
    {
        CreateMap<Hospital, HospitalDto>()
            .ForMember(dest => dest.MaxFloorNumber, opt => opt.MapFrom(src => src.GetMaxFloor()))
            .ForMember(dest => dest.MinFloorNumber, opt => opt.MapFrom(src => src.GetMinFloor()));
        CreateMap<HospitalDto, Hospital>();
    }
}