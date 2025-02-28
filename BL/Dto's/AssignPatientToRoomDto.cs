namespace BL.Dto_s;

public class AssignPatientToRoomDto
{
    public Guid RoomId { get; set; }
    public Guid? PatientId { get; set; }
}