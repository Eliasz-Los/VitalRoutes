using BL;
using BL.Dto_s;
using Microsoft.AspNetCore.Mvc;

namespace BackendApi.Controllers.auth;

[ApiController]
[Route("api/[controller]")]
public class FireBaseAuthController : ControllerBase
{
    private readonly FirebaseAuthManager _firebaseAuthManager;
    private readonly UserManager _userManager;

    public FireBaseAuthController(FirebaseAuthManager firebaseAuthManager, UserManager userManager)
    {
        _firebaseAuthManager = firebaseAuthManager;
        _userManager = userManager;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterUserDto registerUserDto)
    {
        var token = await _firebaseAuthManager.SignUp(registerUserDto.Email, registerUserDto.Password);
        if (token == null)
        {
            return BadRequest(new { message = "User registration failed" });
        }
        AddUserDto addUserDto = new AddUserDto
        {
            FirstName = registerUserDto.FirstName,
            LastName = registerUserDto.LastName,
            Email = registerUserDto.Email,
            TelephoneNr = registerUserDto.TelephoneNr,
            Function = registerUserDto.Function
        };
        await _userManager.AddUserAsync(addUserDto);

        return Ok(new { message = "User registered successfully", token, addUserDto });
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginUserDto userCredentialsDto)
    {
        var token = await _firebaseAuthManager.Login(userCredentialsDto.Email, userCredentialsDto.Password);
        if (token == null)
        {
            return Unauthorized(new { message = "Invalid credentials" });
        }
        return Ok(new { token });
    }

    [HttpPost("signout")]
    public IActionResult SignOut()
    {
        _firebaseAuthManager.SignOut();
        return Ok(new { message = "User signed out" });
    }
}