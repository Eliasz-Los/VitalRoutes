using BL.Dto_s;
using DAL;

namespace BL;

public class RoomManager
{
    private readonly RoomRepository _roomRepository;
    private readonly UserRepository _userRepository;

    public RoomManager(RoomRepository roomRepository, UserRepository userRepository)
    {
        _roomRepository = roomRepository;
        _userRepository = userRepository;
    }

    public IEnumerable<RoomDto> GetRoomsWithPointAndAssignedPatientByHospitalAndFloorNumber(string hospital, int floorNumber)
    {
        var rooms = _roomRepository.ReadRoomsWithPointAndAssignedPatientByHospitalAndFloorNumber(hospital,floorNumber);

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

    public async Task ChangeAssignedPatientInRoom(Guid roomId, Guid? patientId)
    {
        var room =  await _roomRepository.ReadRoomWithAssignedPatient(roomId);

        if (patientId.HasValue)
        {
            var patient = await _userRepository.ReadUserById(patientId.Value);
            room.AssignedPatient = patient;
        }
        else
        {
            room.AssignedPatient = null;
        }

        await _roomRepository.UpdateRoom(room);
    }
    
    public async Task<RoomDto?> GetRoomsWithPointAndAssignedPatientByUserId(Guid userId)
    {
        var room = await _roomRepository.ReadRoomWithPointAndAssignedPatientByUserId(userId);

        if (room == null)
        {
            Console.WriteLine($"Geen kamer gevonden voor gebruiker met ID: {userId}");
            return null;
        }

        return new RoomDto
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
    }

}