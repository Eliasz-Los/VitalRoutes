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
            optionsBuilder.UseNpgsql("Host=localhost;Port=54326;Database=postgres_db;Username=user;Password=postgres");
        }
        optionsBuilder.LogTo(message => Debug.WriteLine(message), LogLevel.Information);
    }
    public VitalRoutesDbContext(DbContextOptions options) : base(options)
    {
        //TODO: door op true, werd na registreren van user, user opgeslagen maar dan kijkenn aar de user page, andere api call werd hele databank her gecreeerd
        VitalRoutesInitializer.Initialize(this, false);
    }
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Hospital>().ToTable("Hospitals").HasIndex(hosp => hosp.Id).IsUnique();
        modelBuilder.Entity<Notification>().ToTable("Notifications").HasIndex(not => not.Id).IsUnique();
        modelBuilder.Entity<Emergency>().ToTable("Emergencies").HasIndex(em => em.Id).IsUnique();
        modelBuilder.Entity<User>().ToTable("Users").HasIndex(user => user.Id).IsUnique();  
        modelBuilder.Entity<UserLocation>().ToTable("UserLocations").HasIndex(userLoc => userLoc.Id).IsUnique();
        modelBuilder.Entity<Floorplan>().ToTable("Floorplans").HasIndex(floor => floor.Id).IsUnique();
        modelBuilder.Entity<Point>().ToTable("Points").HasIndex(point => point.Id).IsUnique();
        
        //TODO in beide richtingen navigeerbaar maken
        /*modelBuilder.Entity<Notification>()
            .HasOne(notification => notification.Emergency)
            .WithOne(emergency => emergency.Notification)
            .HasForeignKey("EmergencyId");*/
        modelBuilder.Entity<User>()
            .HasMany(u => u.UnderSupervisions)
            .WithOne()
            .HasForeignKey(u => u.SupervisorId); 

        modelBuilder.Entity<Emergency>()
            .HasOne(emergency => emergency.Notification)
            .WithOne(notification => notification.Emergency)
            .HasForeignKey<Emergency>("EmergencyFK");
        
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
            .WithOne(userLocation => userLocation.User)
            .HasForeignKey<User>("UserLocationFK");

        modelBuilder.Entity<User>()
            .HasOne(user => user.Hospital)
            .WithMany(hospital => hospital.Users);
        
    }


}