using System;
using System.Collections.Generic;
using System.Linq;
using Domain;

namespace DAL.EF;

public class FloorplanRepository
{
    private readonly VitalRoutesDbContext _context;

    public FloorplanRepository(VitalRoutesDbContext context)
    {
        _context = context;
    }
    
    public IEnumerable<Floorplan> ReadFloorplans()
    {
        return _context.Floorplans;
    }
    
    public Floorplan ReadFloorplan(Guid id)
    {
        return _context.Floorplans.Find(id);
    }
    
    public IEnumerable<Floorplan> ReadFloorplanByHospitalName(string hospitalName)
    {
        return _context.Floorplans.Where(f => f.Hospital.Name == hospitalName);
    }
}