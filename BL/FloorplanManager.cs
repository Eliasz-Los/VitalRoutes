using System;
using System.Collections.Generic;
using DAL.EF;
using Domain;

namespace BL;

public class FloorplanManager
{
    private readonly FloorplanRepository _floorplanRepository;

    public FloorplanManager(FloorplanRepository floorplanRepository)
    {
        _floorplanRepository = floorplanRepository;
    }
    
    public IEnumerable<Floorplan> GetFloorplans()
    {
        return _floorplanRepository.ReadFloorplans();
    }

    public Floorplan GetFloorplan(Guid id)
    {
        return _floorplanRepository.ReadFloorplan(id);
    }

    public IEnumerable<Floorplan> GetFloorplansByHospitalName(string hospitalName)
    {
        return _floorplanRepository.ReadFloorplanByHospitalName(hospitalName);
    }
}