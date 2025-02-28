using BL;
using BL.Dto_s;
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

    [HttpGet("getRooms/{hospital}/{floorNumber}")]
    public IActionResult GetRooms(string hospital, int floorNumber)
    {
        var rooms = _roomManager.GetRoomsWithPointAndAssignedPatientByHospitalAndFloorNumber(hospital,floorNumber);
        return Ok(rooms);
    }
    
    [HttpPut("assignPatient")]
    public async Task<IActionResult> AssignPatient([FromBody] AssignPatientToRoomDto assignPatientDto)
    {
        try
        {
            await _roomManager.ChangeAssignedPatientInRoom(assignPatientDto.RoomId, assignPatientDto.PatientId);
            return Ok();
        }
        catch (Exception ex)
        {
            return BadRequest(ex.Message);
        }
    }
}