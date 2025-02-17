using BL;
using BL.Dto_s;
using Microsoft.AspNetCore.Mvc;

namespace BackendApi.Controllers.auth;

[ApiController]
[Route("api/[controller]")]
public class UserController : Controller
{
    private readonly UserManager _userManager;

    public UserController(UserManager userManager)
    {
        _userManager = userManager;
    }

 
    [HttpGet("{email}")]
    public async Task<IActionResult> GetUserByEmail(string email)
    {
        var user = await _userManager.GetUserByEmail(email);
        if (user == null)
        {
            return NotFound(new { message = "User not found" });
        }
        return Ok(user);
    }
    
    [HttpPut("update")]
    public async Task<IActionResult> UpdateUser([FromBody] UpdateUserDto userDto)
    {
        var updatedUser = await _userManager.UpdateUser(userDto);
        return Ok(updatedUser);
    }
    
    [HttpPost("{supervisorId}/addUnderSupervision/{superviseeId}")]
    public async Task<IActionResult> AddUnderSupervision(Guid supervisorId, Guid superviseeId)
    {
        await _userManager.AddUnderSupervision(supervisorId, superviseeId);
        return Ok(new { message = "Supervision added successfully" });
    }

    [HttpPost("{supervisorId}/removeUnderSupervision/{superviseeId}")]
    public async Task<IActionResult> RemoveUnderSupervision(Guid supervisorId, Guid superviseeId)
    {
        await _userManager.RemoveUnderSupervision(supervisorId, superviseeId);
        return Ok(new { message = "Supervision removed successfully" });
    }
}