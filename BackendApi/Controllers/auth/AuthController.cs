using BL.Dto_s;
using BL;
using Domain;
using FirebaseAdmin.Auth;
using Microsoft.AspNetCore.Mvc;
using NuGet.Common;

namespace BackendApi.Controllers.auth;
[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    
    private readonly UserManager _userManager;
    

    public AuthController(UserManager userManager)
    {
        _userManager = userManager;
    }
    
    [HttpPost("firebase-login")]
    public async Task<IActionResult> FirebaseLogin([FromBody] string idToken)
    {
        try
        {
            var decodedToken = await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync(idToken);
            var uid = decodedToken.Uid;
            var user = await _userManager.GetUserByFirebaseUidAsync(uid);
            if (user == null)
            {
                return NotFound();
            }

            return Ok(new { message="User authenticated", idToken });
        }
        catch (FirebaseAuthException e)
        {
            return Unauthorized(new {message = "invalid token", error = e.Message});
        }
    }

    [HttpPost]
    public async Task<IActionResult> AddUser([FromBody] AddUserDto addUserDto)
    {
        var user = new User(
            addUserDto.FirebaseUid, 
            addUserDto.FirstName, 
            addUserDto.LastName, 
            addUserDto.Email, 
            addUserDto.TelephoneNr, 
            addUserDto.Function);
        await _userManager.AddUserAsync(user);
        
        return Ok(user);
    }
}