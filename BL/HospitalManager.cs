using AutoMapper;
using BL.Dto_s;
using DAL;

namespace BL;

public class HospitalManager
{
    private readonly HospitalRepository _hospitalRepository;
    private readonly IMapper _mapper;

    public HospitalManager(HospitalRepository hospitalRepository, IMapper mapper)
    {
        _hospitalRepository = hospitalRepository;
        _mapper = mapper;
    }

    public async Task<HospitalDto> GetHospitalByName(String name)
    {
        var hospital = await _hospitalRepository.ReadHospitalWithFloorplansByName(name);
        var hospitalDto = new HospitalDto
        {
            Id = hospital.Id,
            Name = hospital.Name,
            MaxFloorNumber = hospital.GetMaxFloor(),
            MinFloorNumber = hospital.GetMinFloor()
        };
        return hospitalDto;
    }
}