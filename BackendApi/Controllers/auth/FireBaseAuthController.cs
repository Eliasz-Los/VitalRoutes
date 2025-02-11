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
        var token = await _firebaseAuthManager.SignUp(registerUserDto.AddUserDto.Email, registerUserDto.Password);
        if (token == null)
        {
            return BadRequest(new { message = "User registration failed" });
        }
        //TODO als dit werkt die uitwerken om die toe te voegen aan de database
        // Additional logic to save user details in the database...

        _userManager.AddUserAsync(registerUserDto.AddUserDto);
        var user = registerUserDto.AddUserDto; //TODO fix

        return Ok(new { message = "User registered successfully", token, user });
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