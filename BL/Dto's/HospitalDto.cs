namespace BL.Dto_s;

public class HospitalDto
{
    public Guid Id { get; set; }
    public string Name { get; set; }

    public int MaxFloorNumber { get; set; }
    
    public int MinFloorNumber { get; set; }
}