using Firebase.Auth;
using FirebaseAdmin.Auth;
using Microsoft.Extensions.Logging;

namespace BL;

public class FirebaseAuthManager
{
    private readonly FirebaseAuthClient _firebaseAuth;
    private readonly ILogger<FirebaseAuthManager> _logger;

    public FirebaseAuthManager(FirebaseAuthClient firebaseAuth, ILogger<FirebaseAuthManager> logger)
    {
        _firebaseAuth = firebaseAuth;
        _logger = logger;
    }

    public async Task<string?> SignUp(string email, string password)
    {
        var userCredentials = await _firebaseAuth.CreateUserWithEmailAndPasswordAsync(email, password);
        if (userCredentials == null)
        {
            _logger.LogError("Failed to create user with email: {Email}", email);
            return null;
        }
        var uid = userCredentials.User.Uid;
        var customToken = await FirebaseAuth.DefaultInstance.CreateCustomTokenAsync(uid);
        _logger.LogInformation("Generated custom token for user {Email}: {Token}", email, customToken);
        return customToken;
    }

    public async Task<string?> Login(string email, string password)
    {
        var userCredentials = await _firebaseAuth.SignInWithEmailAndPasswordAsync(email, password);
        if (userCredentials == null)
        {
            _logger.LogError("Failed to authenticate user with email: {Email}", email);
            return null;
        }
       var uid = userCredentials.User.Uid;
       //generatie van de token om te gebruiken in de frontend en dus user koppelen aan firebase auth
       var customToken = await FirebaseAuth.DefaultInstance.CreateCustomTokenAsync(uid);
        _logger.LogInformation("Generated custom token for user {Email}: {Token}", email, customToken);
        return customToken;
    }

    public void SignOut() => _firebaseAuth.SignOut();
}