using BL;
using Microsoft.AspNetCore.Mvc;

namespace BackendApi.Controllers;

[Route("api/[controller]")]
[ApiController]
public class RoomController : Controller
{
    private readonly RoomManager _roomManager;

    public RoomController(RoomManager roomManager)
    {
        _roomManager = roomManager;
    }

    [HttpGet("getRooms")]
    public IActionResult GetRooms()
    {
        var rooms = _roomManager.GetRooms();
        return Ok(rooms);
    }
}