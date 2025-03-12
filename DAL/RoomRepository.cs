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
    
    public async Task<Room?> ReadRoomWithPointAndAssignedPatientByUserId(Guid userId)
    {
        return await _context.Rooms
            .Include(r => r.AssignedPatient)
            .Include(r => r.Point)
            .FirstOrDefaultAsync(r => r.AssignedPatient != null && r.AssignedPatient.Id == userId);
    }

    
    public async Task UpdateRoom(Room room)
    {
        _context.Rooms.Update(room);
        await _context.SaveChangesAsync();
    }
    
    public async Task<Room> ReadRoomWithAssignedPatient(Guid id)
    {
        var room = await _context.Rooms
            .Include(r => r.AssignedPatient)
            .FirstOrDefaultAsync(r => r.Id == id);

        if (room == null)
        {
            throw new Exception($"Geen kamer gevonden met ID: {id}");
        }

        return room;
    }

    public async Task<Room?> ReadRoomById(Guid? patientRoomId)
    {
        if (patientRoomId == null)
        {
            return null; 
        }

        var room = await _context.Rooms
            .Include(r => r.Point)
            .FirstOrDefaultAsync(r => r.Id == patientRoomId);

        return room;
    }

}