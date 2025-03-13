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
        private readonly RoomRepository _roomRepository;

        public NotificationManager(NotificationRepository notificationRepository, UserRepository userRepository, RoomRepository roomRepository)
        {
            _notificationRepository = notificationRepository;
            _userRepository = userRepository;
            _roomRepository = roomRepository;
        }
        
        public async Task<NotificationDto> CreateNotification(NotificationDto dto) 
        {
            if (dto == null)
            {
                throw new ArgumentNullException(nameof(dto), "NotificationDto mag niet null zijn");
            }

            var patient = await _userRepository.ReadUserById(dto.PatientId);

            if (patient == null)
            {
                var errorMessage = $" [FOUT] Patiënt met ID {dto.PatientId} niet gevonden.";
                throw new Exception(errorMessage);
            }

            EmergencyLevel emergencyLevel = dto.Status switch
            {
                "Dringend" => EmergencyLevel.Medium,
                "Nood" => EmergencyLevel.High,
                _ => EmergencyLevel.Low
            };

            var room = await _roomRepository.ReadRoomWithPointAndAssignedPatientByUserId(patient.Id);
            int chamberNr = room?.RoomNumber ?? -101;

            var notification = new Notification(dto.Message)
            {
                Status = "Te behandelen",
                TimeStamp = DateTime.UtcNow.ToUniversalTime().AddHours(2)
            };

            notification = await _notificationRepository.CreateNotification(notification);

            var emergency = new Emergency(chamberNr, emergencyLevel)
            {
                User = patient,
                Notification = notification
            };

            emergency = await _notificationRepository.CreateEmergency(emergency);

            notification.Emergency = emergency;
            await _notificationRepository.UpdateNotification(notification);

            return new NotificationDto
            {
                Id = notification.Id,
                Message = notification.Message,
                Status = notification.Status,
                TimeStamp = notification.TimeStamp,
                PatientId = emergency.User.Id,
                RoomNumber = chamberNr
            }; 
        }
        
        public async Task<IEnumerable<NotificationDto>> GetNotificationsForNurse(Guid nurseId)
        {
            var notifications = await _notificationRepository.GetNotificationsForNurse(nurseId);
            var result = new List<NotificationDto>();

            foreach (var notification in notifications)
            {
                var patient = notification.Emergency?.User;
                if (patient == null) continue;

                var room = await _roomRepository.ReadRoomWithPointAndAssignedPatientByUserId(patient.Id);

                result.Add(new NotificationDto
                {
                    Id = notification.Id,
                    Message = notification.Message,
                    Status = notification.Status,
                    TimeStamp = notification.TimeStamp,
                    PatientId = patient.Id,
                    PatientName = $"{patient.FirstName} {patient.LastName}",
                    RoomNumber = room?.RoomNumber ?? -120
                });
            }

            return result;
        }
        
        public async Task<IEnumerable<NotificationDto>> GetNotificationsForPatient(Guid patientId)
        {
            var notifications = await _notificationRepository.GetNotificationsForPatient(patientId);
            var result = new List<NotificationDto>();

            foreach (var notification in notifications)
            {
                var patient = notification.Emergency?.User;
                if (patient == null) continue;

                result.Add(new NotificationDto
                {
                    Id = notification.Id,
                    Message = notification.Message,
                    Status = notification.Status,
                    TimeStamp = notification.TimeStamp,
                    PatientId = patient.Id,
                    PatientName = $"{patient.FirstName} {patient.LastName}",
                    RoomNumber = notification.Emergency?.ChamberNr ?? -120
                });
            }

            return result;
        }

        
        public async Task<IEnumerable<NotificationDto>> GetNotificationsForDoctor(Guid doctorId)
        {
            var notifications = await _notificationRepository.GetNotificationsForDoctor(doctorId);
            var result = new List<NotificationDto>();

            foreach (var notification in notifications)
            {
                var nurseOrHeadNurse = notification.Emergency?.User;
                if (nurseOrHeadNurse == null) continue;

                // Als je extra informatie nodig hebt, kan je die hier ophalen
                var room = await _roomRepository.ReadRoomWithPointAndAssignedPatientByUserId(nurseOrHeadNurse.Id);

                result.Add(new NotificationDto
                {
                    Id = notification.Id,
                    Message = notification.Message,
                    Status = notification.Status,
                    TimeStamp = notification.TimeStamp,
                    // In dit geval is "PatientId" eigenlijk de ID van de Nurse/HeadNurse
                    // omdat die hier de 'afzender' is. Eventueel kun je hiervoor
                    // een aparte property maken in de DTO.
                    PatientId = nurseOrHeadNurse.Id,
                    PatientName = $"{nurseOrHeadNurse.FirstName} {nurseOrHeadNurse.LastName}",
                    RoomNumber = room?.RoomNumber ?? -120
                });
            }

            return result;
        }


        public async Task<NotificationDto> UpdateNotificationStatus(Guid notificationId, string newStatus)
        {
            var updated = await _notificationRepository.UpdateNotificationStatus(notificationId, newStatus);

            return new NotificationDto
            {
                Id = updated.Id,
                Message = updated.Message,
                Status = updated.Status,
                PatientName = updated.Emergency?.User.FirstName + " " + updated.Emergency?.User.LastName,
                RoomNumber = updated.Emergency?.ChamberNr ?? -120,
                TimeStamp = updated.TimeStamp,
                PatientId = updated.Emergency?.User.Id ?? Guid.Empty
            };
        }

    }
}
