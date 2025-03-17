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
        
        public async Task<NotificationDto> CreatePatientToNurseNotification(NotificationDto dto) 
        {
            if (dto == null)
            {
                throw new ArgumentNullException(nameof(dto), "NotificationDto mag niet null zijn");
            }

            var patient = await _userRepository.ReadUserById(dto.UserId);

            if (patient == null)
            {
                var errorMessage = $" [FOUT] Gebruiker met ID {dto.UserId} niet gevonden.";
                throw new Exception(errorMessage);
            }

            EmergencyLevel emergencyLevel = dto.Status switch
            {
                "Dringend" => EmergencyLevel.Medium,
                "Nood" => EmergencyLevel.High,
                _ => EmergencyLevel.Low
            };

            var room = await _roomRepository.ReadRoomWithPointAndAssignedPatientByUserId(patient.Id);
            int chamberNr = room?.RoomNumber ?? -120;

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
                UserId = emergency.User.Id,
                UserName = $"{emergency.User.FirstName} {emergency.User.LastName}",
                RoomNumber = chamberNr
            }; 
        }
        
        public async Task<NotificationDto> CreateNurseToDoctorNotification(NotificationDto dto)
        {
            var nurse = await _userRepository.ReadUserById(dto.UserId);
            if (nurse == null || (nurse.Function != Function.Nurse && nurse.Function != Function.HeadNurse))
            {
                throw new Exception($"Genruiker met ID {dto.UserId} bestaat niet of is geen Nurse/HeadNurse!");
            }
            
            EmergencyLevel emergencyLevel = dto.Status switch
            {
                "Dringend" => EmergencyLevel.Medium,
                "Nood" => EmergencyLevel.High,
                _ => EmergencyLevel.Low
            };

            int chamberNr = -120;

            var notification = new Notification(dto.Message)
            {
                Status = "Te behandelen",
                TimeStamp = DateTime.UtcNow.ToUniversalTime().AddHours(2)
            };
            notification = await _notificationRepository.CreateNotification(notification);

            var emergency = new Emergency(chamberNr, emergencyLevel)
            {
                User = nurse,
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
                UserId = nurse.Id,                 
                UserName = $"{nurse.FirstName} {nurse.LastName}",
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
                    UserId = patient.Id,
                    UserName = $"{patient.FirstName} {patient.LastName}",
                    RoomNumber = room?.RoomNumber ?? -120
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

                var room = await _roomRepository.ReadRoomWithPointAndAssignedPatientByUserId(nurseOrHeadNurse.Id);

                result.Add(new NotificationDto
                {
                    Id = notification.Id,
                    Message = notification.Message,
                    Status = notification.Status,
                    TimeStamp = notification.TimeStamp,
                    UserId = nurseOrHeadNurse.Id,
                    UserName = $"{nurseOrHeadNurse.FirstName} {nurseOrHeadNurse.LastName}",
                    RoomNumber = room?.RoomNumber ?? -120
                });
            }

            return result;
        }

        
        public async Task<IEnumerable<NotificationDto>> GetSentNotificationsForPatient(Guid patientId)
        {
            var notifications = await _notificationRepository.GetSentNotificationsForPatient(patientId);
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
                    UserId = patient.Id,
                    UserName = $"{patient.FirstName} {patient.LastName}",
                    RoomNumber = notification.Emergency?.ChamberNr ?? -120
                });
            }

            return result;
        }
        
        public async Task<IEnumerable<NotificationDto>> GetSentNotificationsForNurse(Guid nurseId)
        {
            var notifications = await _notificationRepository.GetSentNotificationsForNurse(nurseId);
            var result = new List<NotificationDto>();

            foreach (var notification in notifications)
            {
                var nurse = notification.Emergency?.User;
                if (nurse == null) continue;

                result.Add(new NotificationDto
                {
                    Id = notification.Id,
                    Message = notification.Message,
                    Status = notification.Status,
                    TimeStamp = notification.TimeStamp,
                    UserId = nurse.Id,
                    UserName = $"{nurse.FirstName} {nurse.LastName}",
                    RoomNumber = notification.Emergency?.ChamberNr ?? -120
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
                UserName = updated.Emergency?.User.FirstName + " " + updated.Emergency?.User.LastName,
                RoomNumber = updated.Emergency?.ChamberNr ?? -120,
                TimeStamp = updated.TimeStamp,
                UserId = updated.Emergency?.User.Id ?? Guid.Empty
            };
        }

    }
}
