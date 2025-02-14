using BL.Dto_s;
using Domain;

namespace BackendApi.Models.Dto;

public class FloorplanDto
{
    public Guid Id { get; set; }
    
    public String Name { get; set; }
    
    public int FloorNumber { get; set; }
    
    public String Scale { get; set; }
    
    public IEnumerable<PointDto> Nodes { get; set; }
    
    public HospitalDto Hospital { get; set; }
    
    public string ImageData { get; set; }
}