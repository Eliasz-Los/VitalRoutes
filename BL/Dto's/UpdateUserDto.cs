namespace BL.Dto_s;

public class UpdateUserDto
{
    public Guid Id {get; set;}
    public string Uid {get; set;}
    public string FirstName {get; set;}
    public string LastName {get; set;}
    public string Email {get; set;}
    public string TelephoneNr {get; set;}
}