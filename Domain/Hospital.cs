namespace Domain;

public class Hospital
{
    public Guid Id {get; set;}
    public string Name {get; set;}
    public IEnumerable<Floorplan> Floorplans {get; set;}

    public Hospital(string name)
    {
        Name = name;
    }
}