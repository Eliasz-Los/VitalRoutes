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

    public IEnumerable<Room> GetRooms()
    {
        return _context.Rooms.Include(r => r.AssignedPatient).Include(r => r.Point).ToList();
    }

    public IEnumerable<Room> GetRoomsUnderSupervision(Guid doctorId)
    {
        var doctor = _context.Users
            .Include(u => u.UnderSupervisions)
            .FirstOrDefault(u => u.Id == doctorId);

        if (doctor == null)
        {
            return [];
        }

        var supervisedPatientIds = doctor.UnderSupervisions.Select(p => p.Id).ToList();

        return _context.Rooms
            .Where(room => room.AssignedPatient != null && supervisedPatientIds.Contains(room.AssignedPatient.Id))
            .ToList();
    }
}