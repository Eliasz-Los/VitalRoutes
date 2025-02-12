using Domain;

namespace BackendApi.Models.Dto;

public class FloorplanDto
{
    public Guid Id { get; set; }
    
    public String Name { get; set; }
    
    public int FloorNumber { get; set; }
    
    public String Scale { get; set; }
    
    public IEnumerable<Point> Nodes { get; set; }
    
    public Hospital Hospital { get; set; }
    
    public string SvgData { get; set; }
}