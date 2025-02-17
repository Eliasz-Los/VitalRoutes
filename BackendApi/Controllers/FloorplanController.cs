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
    public async Task<IActionResult> GetFloorPlans(string hospitalName)
    {
        var hospital = hospitalName.Replace(" ", "_");
        var folderPath = Path.Combine(_webHostEnvironment.ContentRootPath, "Floorplans", hospital);
        
        var floorPlans = await _floorplanManager.GetFloorplansByHospitalName(hospitalName, folderPath);
        
        if (!floorPlans.Any())
        {
            return NotFound("No floorplans found for hospital " + hospitalName);
        }
        
        return Ok(floorPlans);
    }
    
    [HttpGet("getFloorplan/{hospitalName}/{floorNumber}")]
    public async Task<IActionResult> GetFloorplan(string hospitalName, int floorNumber)
    {
        var hospital = hospitalName.Replace(" ", "_");
        var folderPath = Path.Combine(_webHostEnvironment.ContentRootPath, "Floorplans", hospital);

        try
        {
            var floorPlan = await _floorplanManager.GetFloorplanByHospitalNameAndFloorNumber(hospitalName, floorNumber, folderPath);
            return Ok(floorPlan);
        }
        catch (KeyNotFoundException)
        {
            return NotFound($"No floorplan found for hospital {hospitalName} and floor number {floorNumber}");
        }
        catch (FileNotFoundException ex)
        {
            return NotFound(ex.Message);
        }
    }
}