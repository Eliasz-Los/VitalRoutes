namespace Domain;

public class UserLocation
{
    public double XWidth {get; set;}
    public double YHeight {get; set;}
    public User User {get; set;}
    
    public UserLocation(double xWidth, double yHeight, User user)
    {
        XWidth = xWidth;
        YHeight = yHeight;
        User = user;
    }
}