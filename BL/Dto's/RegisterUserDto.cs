using Domain.Enums;

namespace BL.Dto_s;

public class RegisterUserDto
{
    public AddUserDto AddUserDto { get; set; }
    public string Password { get; set; }
}