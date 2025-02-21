using BL.Dto_s;
using DAL;

namespace BL;

public class RoomManager
{
    private readonly RoomRepository _roomRepository;

    public RoomManager(RoomRepository roomRepository)
    {
        _roomRepository = roomRepository;
    }

    public IEnumerable<RoomDto> GetRooms()
    {
        var rooms = _roomRepository.GetRooms();

        var result = new List<RoomDto>();

        foreach (var room in rooms)
        {
            var roomDto = new RoomDto
            {
                Id = room.Id,
                Point = new PointDto
                {
                    Id = room.Point.Id,
                    XWidth = room.Point.XWidth,
                    YHeight = room.Point.YHeight
                },
                AssignedPatient = room.AssignedPatient != null ? new UserDto
                {
                    Id = room.AssignedPatient.Id,
                    FirstName = room.AssignedPatient.FirstName,
                    LastName = room.AssignedPatient.LastName,
                    Email = room.AssignedPatient.Email,
                    TelephoneNr = room.AssignedPatient.TelephoneNr,
                    Function = room.AssignedPatient.Function
                } : null,
                RoomNumber = room.RoomNumber
            };
            result.Add(roomDto);
        }

        return result;
    }
}