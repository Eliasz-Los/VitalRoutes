using BackendApi.Models.Dto;
using BL;
using Microsoft.AspNetCore.Mvc;

namespace BackendApi.Controllers;

[Route("api/[controller]")]
[ApiController]
public class FloorplanController : ControllerBase
{
    private readonly FloorplanManager _floorplanManager;
    private readonly IWebHostEnvironment _webHostEnvironment;

    public FloorplanController(FloorplanManager floorplanManager, IWebHostEnvironment webHostEnvironment)
    {
        _floorplanManager = floorplanManager;
        _webHostEnvironment = webHostEnvironment;
    }
    
    [HttpGet("getFloorPlans/{hospitalName}")]
    public IActionResult GetFloorPlans(string hospitalName)
    {
        var hospital = hospitalName.Replace(" ", "_");
        var folderPath = Path.Combine(_webHostEnvironment.ContentRootPath, "Floorplans", hospital);
        
        var floorPlans = _floorplanManager.GetFloorplansByHospitalName(hospitalName, folderPath);
        
        if (!floorPlans.Any())
        {
            return NotFound("No floorplans found for hospital " + hospitalName);
        }
        
        return Ok(floorPlans);
    }
}