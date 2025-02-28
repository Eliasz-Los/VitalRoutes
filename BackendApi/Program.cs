using BackendApi.Controllers.auth;
using BL;
using BL.Mappers;
using DAL;
using DAL.EF;
using Firebase.Auth;
using Firebase.Auth.Providers;
using FirebaseAdmin;
using FirebaseAdmin.Auth;
using Google.Apis.Auth.OAuth2;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using UserManager = BL.UserManager;

var builder = WebApplication.CreateBuilder(args);


builder.Services.AddDbContext<VitalRoutesDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("postgres_db")));

//TODO: FireBase Admin SDK initiliazation & JWT token generation
FirebaseApp.Create(new AppOptions()
{
    Credential = GoogleCredential.FromFile("vitalroutes-58c59-firebase-adminsdk-fbsvc-668129add2.json"),
    ServiceAccountId ="firebase-adminsdk-fbsvc@vitalroutes-58c59.iam.gserviceaccount.com"
});

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = "https://securetoken.google.com/vitalroutes-58c59";
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = "https://securetoken.google.com/vitalroutes-58c59",
            ValidateAudience = true,
            ValidAudience = "vitalroutes-58c59",
            ValidateLifetime = true
        };
    });

builder.Services.AddSingleton(new FirebaseAuthClient(new FirebaseAuthConfig
{
    ApiKey = "AIzaSyDWYFqsbgB3GWl0MWzu-ZBmYdG3cLnEQTk",
    AuthDomain = "vitalroutes-58c59.firebaseapp.com",
    Providers = new FirebaseAuthProvider[]
    {
        new EmailProvider()
    }
}));

builder.Services.AddSingleton<FirebaseAuth>(FirebaseAuth.DefaultInstance);
builder.Services.AddScoped<FirebaseTokenValidator>();

builder.Services.AddScoped<FirebaseAuthManager>();
builder.Services.AddScoped<UserRepository>();
builder.Services.AddScoped<UserManager>();
builder.Services.AddScoped<FloorplanRepository>();
builder.Services.AddScoped<FloorplanManager>();
builder.Services.AddScoped<RoomRepository>();
builder.Services.AddScoped<RoomManager>();
builder.Services.AddScoped<HospitalRepository>();
builder.Services.AddScoped<HospitalManager>();
builder.Services.AddAuthorization();
builder.Services.AddOpenApi();
builder.Services.AddControllers();
//TODO voeg meerder mappers toe met , typeof(AndereMappingProfile)
builder.Services.AddAutoMapper(typeof(UserMappingProfile));
builder.Services.AddAutoMapper(typeof(HospitalMappingProfile));

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<VitalRoutesDbContext>();
    db.Database.Migrate();
}



// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();

