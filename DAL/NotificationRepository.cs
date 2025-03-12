using DAL.EF;
using Domain;
using Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace DAL
{
    public class NotificationRepository
    {
        private readonly VitalRoutesDbContext _context;

        public NotificationRepository(VitalRoutesDbContext context)
        {
            _context = context;
        }

        public async Task<Notification> CreateNotification(Notification notification)
        {
            _context.Notifications.Add(notification);
            await _context.SaveChangesAsync();
            return notification;
        }

        public async Task<IEnumerable<Notification>> GetNotificationsForNurse(Guid nurseId)
        {
            return await _context.Notifications
                .Include(n => n.Emergency)
                .ThenInclude(e => e.User)
                .ThenInclude(u => u.Supervisors)
                .Where(n =>
                    n.Emergency.User.Function == Function.Patient 
                    && n.Emergency.User.Supervisors.Any(s => 
                            s.Id == nurseId 
                            && (s.Function == Function.Nurse || s.Function == Function.HeadNurse))
                    )
                .OrderByDescending(n => n.TimeStamp)
                .ToListAsync();
        }
        
        public async Task<IEnumerable<Notification>> GetNotificationsForDoctor(Guid doctorId)
        {
            return await _context.Notifications
                .Include(n => n.Emergency)
                .ThenInclude(e => e.User)
                .ThenInclude(u => u.Supervisors)
                .Where(n =>
                    (n.Emergency.User.Function == Function.Nurse 
                     || n.Emergency.User.Function == Function.HeadNurse)
                    && n.Emergency.User.Supervisors.Any(s => s.Id == doctorId)
                )
                .OrderByDescending(n => n.TimeStamp)
                .ToListAsync();
        }
        
        public async Task<Notification> UpdateNotificationStatus(Guid notificationId, string newStatus)
        {
            var notification = await _context.Notifications
                .Include(n => n.Emergency)
                .ThenInclude(e => e.User)
                .FirstOrDefaultAsync(n => n.Id == notificationId);
    
            if (notification == null)
            {
                throw new Exception("Notificatie niet gevonden");
            }
            notification.Status = newStatus;
            _context.Notifications.Update(notification);
            await _context.SaveChangesAsync();
            return notification;
        }


        public async Task<Emergency?> GetEmergencyByPatientId(Guid patientId)
        {
            return await _context.Emergencies
                .Include(e => e.User)
                .FirstOrDefaultAsync(e => e.User.Id == patientId);
        }

        public async Task<Emergency> CreateEmergency(Emergency emergency)
        {
            _context.Emergencies.Add(emergency);
            await _context.SaveChangesAsync();
            return emergency;
        }

        public async Task<Notification> UpdateNotification(Notification notification)
        {
            _context.Notifications.Update(notification);
            await _context.SaveChangesAsync();
            return notification;
        }

        public async Task<Emergency> UpdateEmergency(Emergency emergency)
        {
            _context.Emergencies.Update(emergency);
            await _context.SaveChangesAsync();
            return emergency;
        }


    }
}
