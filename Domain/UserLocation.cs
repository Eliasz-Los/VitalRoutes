namespace Domain;

public class UserLocation
{
    public Guid Id {get; set;}
    public double XWidth {get; set;}
    public double YHeight {get; set;}
    public User User {get; set;}
    
    public UserLocation(double xWidth, double yHeight, User user)
    {
        XWidth = xWidth;
        YHeight = yHeight;
        User = user;
    }
    
    public UserLocation(double xWidth, double yHeight)
    {
        XWidth = xWidth;
        YHeight = yHeight;
    }
}