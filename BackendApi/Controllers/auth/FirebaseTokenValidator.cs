using System.Security.Claims;
using FirebaseAdmin.Auth;
using Microsoft.AspNetCore.Authentication.JwtBearer;

namespace BackendApi.Controllers.auth;

public class FirebaseTokenValidator
{
    private readonly FirebaseAuth _firebaseAuth;

    public FirebaseTokenValidator(FirebaseAuth firebaseAuth)
    {
        _firebaseAuth = firebaseAuth;
    }

    public async Task<ClaimsPrincipal?> ValidateTokenAsync(string idToken)
    {
        try
        {
            var decodedToken = await _firebaseAuth.VerifyIdTokenAsync(idToken);
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, decodedToken.Uid)
            };

            var identity = new ClaimsIdentity(claims, JwtBearerDefaults.AuthenticationScheme);
            return new ClaimsPrincipal(identity);
        }
        catch (Exception)
        {
            return null; // Invalid token
        }
    }
}
