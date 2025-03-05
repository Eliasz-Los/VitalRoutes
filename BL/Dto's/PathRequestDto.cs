using Domain;

namespace BL.Dto_s;

public class PathRequestDto
{
    public PathPointDto Start { get; set; }
    public PathPointDto End { get; set; }
    public string HospitalName { get; set; }
    public string FloorName { get; set; }
}