namespace BL.Dto_s
{
    public class NotificationDto
    {
        public Guid Id { get; set; }
        public string Message { get; set; }
        public string Status { get; set; }
        public DateTime TimeStamp { get; set; }
        public Guid PatientId { get; set; }
    }
}