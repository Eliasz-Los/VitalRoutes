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

        [HttpPost("createPatientToNurseNotification")]
        public async Task<IActionResult> CreatePatientToNurseNotification([FromBody] NotificationDto dto)
        {
            try
            {
                var created = await _notificationManager.CreatePatientToNurseNotification(dto);
                return Ok(created);
            }
            catch (Exception ex)
            {
                return BadRequest($"Fout bij aanmaken patient->doctor notificatie: {ex.Message}");
            }
        }

        [HttpPost("createNurseToDoctorNotification")]
        public async Task<IActionResult> CreateNurseToDoctorNotification([FromBody] NotificationDto dto)
        {
            try
            {
                var created = await _notificationManager.CreateNurseToDoctorNotification(dto);
                return Ok(created);
            }
            catch (Exception ex)
            {
                return BadRequest($"Fout bij aanmaken nurse->doctor notificatie: {ex.Message}");
            }
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
        
        
        [HttpGet("doctor/{doctorId}")]
        public async Task<IActionResult> GetNotificationsForDoctor(Guid doctorId)
        {
            if (doctorId == Guid.Empty)
            {
                return BadRequest("doctorId is ongeldig!");
            }
            try
            {
                var notifications = await _notificationManager.GetNotificationsForDoctor(doctorId);
                return Ok(notifications);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error bij ophalen notificaties: {ex.Message}");
                return StatusCode(500, $"Fout bij ophalen notificaties: {ex.Message}");
            }
        }
        
        
        [HttpGet("sent/patient/{patientId}")]
        public async Task<IActionResult> GetSentNotificationsForPatient(Guid patientId)
        {
            if (patientId == Guid.Empty)
            {
                return BadRequest("PatientId is ongeldig!");
            }
            
            try
            {
                var notifications = await _notificationManager.GetSentNotificationsForPatient(patientId);
                return Ok(notifications);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error bij ophalen notificaties patient: {ex.Message}");
                return StatusCode(500, $"Fout bij ophalen notificaties: {ex.Message}");
            }
        }
        
        [HttpGet("sent/nurse/{nurseId}")]
        public async Task<IActionResult> GetSentNotificationsForNurse(Guid nurseId)
        {
            if (nurseId == Guid.Empty)
            {
                return BadRequest("nurseId is ongeldig!");
            }
            
            try
            {
                var notifications = await _notificationManager.GetSentNotificationsForNurse(nurseId);
                return Ok(notifications);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error bij ophalen notificaties patient: {ex.Message}");
                return StatusCode(500, $"Fout bij ophalen notificaties: {ex.Message}");
            }
        }
        

        [HttpPut("{notificationId}/status")]
        public async Task<IActionResult> UpdateNotificationStatus(Guid notificationId, [FromBody] string newStatus)
        {
            var updated = await _notificationManager.UpdateNotificationStatus(notificationId, newStatus);
            return Ok(updated);
        }
        

    }
}