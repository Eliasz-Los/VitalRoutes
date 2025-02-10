using Domain.Enums;

namespace BL.Dto_s;

public class AddUserDto
{
    public string FirebaseUid { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public string Email { get; set; }
    public string TelephoneNr { get; set; }
    public Function Function { get; set; }
}