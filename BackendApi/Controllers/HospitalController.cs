using BL;
using Microsoft.AspNetCore.Mvc;

namespace BackendApi.Controllers;

[ApiController]
[Route("/api/[controller]")]
public class HospitalController : Controller
{
    private readonly HospitalManager _hospitalManager;

    public HospitalController(HospitalManager hospitalManager)
    {
        _hospitalManager = hospitalManager;
    }

    [HttpGet("getHospital/{name}")]
    public async Task<IActionResult> GetHospital(string name)
    {
        var hospital = await _hospitalManager.GetHospitalByName(name);
        return Ok(hospital);
    }
}