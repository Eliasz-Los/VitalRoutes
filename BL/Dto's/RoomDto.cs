using Domain;

namespace BL.Dto_s;

public class RoomDto
{
    public Guid Id { get; set; }
    public PointDto Point { get; set; }
    public UserDto? AssignedPatient { get; set; }
    public int RoomNumber { get; set; }
    
}
