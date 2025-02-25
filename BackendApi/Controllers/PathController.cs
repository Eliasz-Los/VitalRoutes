using BL;
using Domain;
using Microsoft.AspNetCore.Mvc;

namespace BackendApi.Controllers;

[Route("api/[controller]")]
[ApiController]
public class PathController : ControllerBase
{
    private readonly PathManager _pathManager;

    public PathController(PathManager pathManager)
    {
        _pathManager = pathManager;
    }

    //TODO: DTO opmaken, benaming verbeteren met params, en testen 
    [HttpGet("route")]
    public async Task<IActionResult> GetPath(Point start, Point end, string image)
    {
        var path = await _pathManager.FindPath(start, end, image);
        return Ok(path);
    }
}