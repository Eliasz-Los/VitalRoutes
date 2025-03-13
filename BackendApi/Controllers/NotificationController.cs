using BL;
using BL.Dto_s;
using Microsoft.AspNetCore.Mvc;

namespace BackendApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class NotificationController : ControllerBase
    {
        private readonly NotificationManager _notificationManager;

        public NotificationController(NotificationManager notificationManager)
        {
            _notificationManager = notificationManager;
        }

        // Endpoint om een notificatie aan te maken (bijvoorbeeld vanuit een patient)
        [HttpPost("create")]
        public async Task<IActionResult> CreateNotification([FromBody] NotificationDto dto)
        {
            var created = await _notificationManager.CreateNotification(dto);
            return Ok(created);
        }
        
        [HttpGet("nurse/{nurseId}")]
        public async Task<IActionResult> GetNotificationsForNurse(Guid nurseId)
        {
            if (nurseId == Guid.Empty)
            {
                return BadRequest("NurseId is ongeldig!");
            }

            try
            {
                var notifications = await _notificationManager.GetNotificationsForNurse(nurseId);
                return Ok(notifications);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error bij ophalen notificaties: {ex.Message}");
                return StatusCode(500, $"Fout bij ophalen notificaties: {ex.Message}");
            }
        }


        // Endpoint om de status van een notificatie te updaten
        [HttpPut("{notificationId}/status")]
        public async Task<IActionResult> UpdateNotificationStatus(Guid notificationId, [FromBody] string newStatus)
        {
            // Optioneel: validatie of newStatus een toegestane waarde is
            var updated = await _notificationManager.UpdateNotificationStatus(notificationId, newStatus);
            return Ok(updated);
        }
        
        [HttpGet("patient/{patientId}")]
        public async Task<IActionResult> GetNotificationsForPatient(Guid patientId)
        {
            if (patientId == Guid.Empty)
            {
                return BadRequest("PatientId is ongeldig!");
            }

            try
            {
                var notifications = await _notificationManager.GetNotificationsForPatient(patientId);
                return Ok(notifications);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error bij ophalen notificaties patient: {ex.Message}");
                return StatusCode(500, $"Fout bij ophalen notificaties: {ex.Message}");
            }
        }

    }
}