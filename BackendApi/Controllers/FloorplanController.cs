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
        var floorPlans = _floorplanManager.GetFloorplansByHospitalName(hospitalName).ToList();
        if (!floorPlans.Any())
        {
            return NotFound("No floorplans found for hospital " + hospitalName);
        }

        var result = new List<FloorplanDto>();
        var hospital = hospitalName.Replace(" ", "_");
        var folderPath = Path.Combine(_webHostEnvironment.ContentRootPath, "Floorplans", hospital);
        
        foreach (var floorPlan in floorPlans)
        {
            var filePath = Path.Combine(folderPath,floorPlan.Image);

            if (!System.IO.File.Exists(filePath))
            {
                return NotFound($"File not found for floorplan: {floorPlan.Image}");
            }

            var svgData = Convert.ToBase64String(System.IO.File.ReadAllBytes(filePath));
            result.Add(new FloorplanDto
            {
                Id = floorPlan.Id,
                Name = floorPlan.Name,
                FloorNumber = floorPlan.FloorNumber,
                Scale = floorPlan.Scale,
                Nodes = floorPlan.Nodes,
                Hospital = floorPlan.Hospital,
                SvgData = svgData
            });
        }

        return Ok(result);
    }
}