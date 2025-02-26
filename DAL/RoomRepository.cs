using DAL.EF;
using Domain;
using Microsoft.EntityFrameworkCore;

namespace DAL;

public class RoomRepository
{
    private readonly VitalRoutesDbContext _context;

    public RoomRepository(VitalRoutesDbContext context)
    {
        _context = context;
    }

    public IEnumerable<Room> ReadRoomsWithPointAndAssignedPatientByHospitalAndFloorNumber(string hospital, int floorNumber)
    {
        return _context.Rooms
            .Include(r => r.AssignedPatient)
            .Include(r => r.Point)
            .Where(r => r.Point.Floorplan.Hospital.Name.Equals(hospital))
            .Where(r => r.Point.Floorplan.FloorNumber == floorNumber)
            .ToList();
    }
}