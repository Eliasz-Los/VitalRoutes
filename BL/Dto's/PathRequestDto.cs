using Domain;

namespace BL.Dto_s;

public class PathRequestDto
{
    public PointDto Start { get; set; }
    public PointDto End { get; set; }
    public string HospitalName { get; set; }
    public string FloorName { get; set; }
}