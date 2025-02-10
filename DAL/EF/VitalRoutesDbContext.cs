using System.Diagnostics;
using Domain;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace DAL.EF;

public class VitalRoutesDbContext : DbContext
{
    public DbSet<Emergency> Emergencies { get; set; }
    public DbSet<Notification> Notifications { get; set; }
    public DbSet<UserLocation> UserLocations { get; set; }
    public DbSet<User> Users { get; set; }
    public DbSet<Hospital> Hospitals { get; set; }
    public DbSet<Floorplan> Floorplans { get; set; }
    public DbSet<Point> Points { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
        {
            optionsBuilder.UseNpgsql("Host=localhost;Database=postgres_db;Username=user;Password=postgres");
        }
        optionsBuilder.LogTo(message => Debug.WriteLine(message), LogLevel.Information);
    }
    public VitalRoutesDbContext(DbContextOptions options) : base(options)
    {
        VitalRoutesInitializer.Initialize(this, true);
    }
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        //TODO in beide richtingen navigeerbaar maken
        modelBuilder.Entity<Notification>()
            .HasOne(notification => notification.Emergency)
            .WithOne(emergency => emergency.Notification);
        modelBuilder.Entity<Emergency>()
            .HasOne(emergency => emergency.Notification)
            .WithOne(notification => notification.Emergency);
        
        modelBuilder.Entity<Emergency>()
            .HasOne(em => em.User)
            .WithMany(user => user.Emergencies)
            .HasForeignKey("UserId");
        
        modelBuilder.Entity<User>()
            .HasMany(user => user.Emergencies)
            .WithOne(emergency => emergency.User)
            .HasForeignKey("UserId");

        modelBuilder.Entity<User>()
            .HasOne(user => user.Location)
            .WithOne(userLocation => userLocation.User);

        modelBuilder.Entity<UserLocation>()
            .HasOne(userLocation => userLocation.User)
            .WithOne(user => user.Location);
    }
    
  
}