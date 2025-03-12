using Domain;

namespace BL.Dto_s;

public class PathRequestDto
{
    public PathPointDto Start { get; set; }
    public PathPointDto End { get; set; }
    public String HospitalName { get; set; }
    public int FloorNumber { get; set; }
}