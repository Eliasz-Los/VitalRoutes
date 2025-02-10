namespace Domain;

public class Point
{
    public double XWidth {get; set;}
    public double YHeight {get; set;}
    public Floorplan Floorplan {get; set;}
    
    public Point(double xWidth, double yHeight)
    {
        XWidth = xWidth;
        YHeight = yHeight;
    }
}