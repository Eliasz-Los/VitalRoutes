namespace Domain;

public class Floorplan
{
    public Guid Id {get; set;}
    public string Name {get; set;}
    public string Image {get; set;}
    public string Scale {get; set;}
    public IEnumerable<Point> Nodes {get; set;}
    public Hospital Hospital {get; set;}
    
    public Floorplan(string name, string image, string scale)
    {
        Name = name;
        Image = image;
        Scale = scale;
    }
}