using AutoMapper;
using BL.Dto_s;
using Domain;

namespace BL.Mappers;

public class PointMappingProfile : Profile
{
    public PointMappingProfile()
    {
        CreateMap<Point, PointDto>();
        CreateMap<PointDto, Point>();
    }
}