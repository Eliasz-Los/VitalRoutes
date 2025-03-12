using System;
using System.Collections.Generic;

namespace Domain;

public class Floorplan
{
    public Guid Id {get; set;}
    public string Name {get; set;}
    
    public int FloorNumber { get; set; }
    
    public string Image {get; set;}
    public string Scale {get; set;}
    
   // public IEnumerable<Point> Nodes {get; set;}
   public HashSet<Point> Points {get; set;} // Huge performance improvement allemaal zelfde oplook tijd 
    public Hospital Hospital {get; set;}
    
    public Floorplan(string name, int floorNumber, string scale, string image)
    {
        Name = name;
        FloorNumber = floorNumber;
        Scale = scale;
        Image = image;
    }
}