using DAL.EF;
using Domain;
using Microsoft.EntityFrameworkCore;

namespace DAL;

public class HospitalRepository
{
    private readonly VitalRoutesDbContext _context;
    
    public HospitalRepository(VitalRoutesDbContext context)
    {
        _context = context;
    }

    public async Task<Hospital> ReadHospitalWithFloorplansByName(string name)
    {
        var hospital = await _context.Hospitals.Include(h => h.Floorplans).FirstOrDefaultAsync(h => h.Name.Equals(name));
        if (hospital == null)
        {
            throw new Exception($"Geen ziekenhuis gevonden met naam: {name}");
        }
        return hospital;
    }
}