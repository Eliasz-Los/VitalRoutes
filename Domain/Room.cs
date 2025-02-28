namespace Domain;

public class Room
{
    public Guid Id { get; set; }
    public Point Point { get; set; }
    public User? AssignedPatient { get; set; }
    public int RoomNumber { get; set; }
    
    public Room(){}
    public Room(Point point, User user, int roomNumber)
    {
        Point = point;
        AssignedPatient = user;
        RoomNumber = roomNumber;
    }
}
