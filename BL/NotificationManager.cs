using Domain;
using BL.Dto_s;
using DAL;
using Domain.Enums;

namespace BL
{
    public class NotificationManager
    {
        private readonly NotificationRepository _notificationRepository;
        private readonly UserRepository _userRepository;

        public NotificationManager(NotificationRepository notificationRepository, UserRepository userRepository)
        {
            _notificationRepository = notificationRepository;
            _userRepository = userRepository;
        }
        
        public async Task<NotificationDto> CreateNotification(NotificationDto dto)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto), "NotificationDto mag niet null zijn");

            // Controleer of de patiënt bestaat
            var patient = await _userRepository.ReadUserById(dto.PatientId);
            if (patient == null)
            {
                throw new Exception($"Patiënt met ID {dto.PatientId} niet gevonden.");
            }

            // Controleer of er al een Emergency is voor deze patiënt
            var emergency = await _notificationRepository.GetEmergencyByPatientId(dto.PatientId);

            // Als er geen bestaande Emergency is, maak een nieuwe aan
            if (emergency == null)
            {
                // Zet het juiste emergency level
                EmergencyLevel emergencyLevel = EmergencyLevel.Low;
                if (dto.Status == "Dringend") emergencyLevel = EmergencyLevel.Medium;
                if (dto.Status == "Nood") emergencyLevel = EmergencyLevel.High;

                emergency = new Emergency(-101, emergencyLevel)
                {
                    User = patient
                };

                // Sla de Emergency op in de database
                emergency = await _notificationRepository.CreateEmergency(emergency);
            }

            // Maak de notificatie en koppel deze aan de Emergency
            var notification = new Notification(dto.Message)
            {
                Status = "te behandelen",
                TimeStamp = DateTime.UtcNow.ToUniversalTime().AddHours(2),
                Emergency = emergency  // Emergency is correct gekoppeld
            };

            await _notificationRepository.CreateNotification(notification);

            return new NotificationDto
            {
                Id = notification.Id,
                Message = notification.Message,
                Status = notification.Status,
                TimeStamp = notification.TimeStamp,
                PatientId = emergency.User.Id
            };
        }

        
        public async Task<IEnumerable<NotificationDto>> GetNotificationsForNurse(Guid nurseId)
        {
            var notifications = await _notificationRepository.GetNotificationsForNurse(nurseId);
    
            return notifications.Select(n => new NotificationDto
            {
                Id = n.Id,
                Message = n.Message,
                Status = n.Status,
                TimeStamp = n.TimeStamp,
                PatientId = n.Emergency?.User?.Id ?? Guid.Empty // Voorkom NullReferenceException
            });
        }


        public async Task<NotificationDto> UpdateNotificationStatus(Guid notificationId, string newStatus)
        {
            var updated = await _notificationRepository.UpdateNotificationStatus(notificationId, newStatus);
    
            return new NotificationDto
            {
                Id = updated.Id,
                Message = updated.Message,
                Status = updated.Status,
                TimeStamp = updated.TimeStamp,
                PatientId = updated.Emergency?.User?.Id ?? Guid.Empty // Voorkom null-crash
            };
        }

    }
}
