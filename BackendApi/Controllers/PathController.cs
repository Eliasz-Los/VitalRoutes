using AutoMapper;
using BL;
using BL.Dto_s;
using Domain;
using Microsoft.AspNetCore.Mvc;

namespace BackendApi.Controllers;

[Route("api/[controller]")]
[ApiController]
public class PathController : ControllerBase
{
    private readonly PathManager _pathManager;
    private readonly IWebHostEnvironment _webHostEnvironment;
    private readonly IMapper _mapper;

    public PathController(PathManager pathManager, IWebHostEnvironment webHostEnvironment, IMapper mapper)
    {
        _pathManager = pathManager;
        _webHostEnvironment = webHostEnvironment;
        _mapper = mapper;
    }

    [HttpGet("route")]
    public async Task<IActionResult> GetPath(PathRequestDto pathRequestDto)
    {
        var hospital = pathRequestDto.HospitalName.Replace(" ", "_");
        var folderPath = Path.Combine(_webHostEnvironment.ContentRootPath, "Floorplans", hospital, pathRequestDto.FloorName);
        
        var start = _mapper.Map<Point>(pathRequestDto.Start);
        var end = _mapper.Map<Point>(pathRequestDto.End);
        
        var path = await _pathManager.FindPath(start, end, folderPath);
        return Ok(path);
    }
}