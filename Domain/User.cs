using Domain.Enums;

namespace Domain;

public class User
{
    //TODO: 2 nullables (Hospital en Location)
    public Guid Id {get; set;}
    public string FirstName {get; set;}
    public string LastName {get; set;}
    public string Email {get; set;}
    public string TelephoneNr {get; set;}
    public Function Function {get; set;}
    public UserLocation? Location {get; set;} //Nullable omdat niet iedereen een locatie heeft in begin 
    // Puur voor goeie benaming zodat het duidelijk is dat het om een lijst gaat
    // van meerdere users met onderliggende functies(patienten en verplegers onder doktor)
    // Benaming is niet super, maar het is duidelijk wat het is
    public IEnumerable<User> UnderSupervisions {get; set;} 
    public IEnumerable<Emergency> Emergencies {get; set;}
    public Hospital? Hospital {get; set;} //voor nu ook geen ziekenhuis

    public User(string firstName, string lastName, string email, string telephoneNr, Function function)
    {
        FirstName = firstName;
        LastName = lastName;
        Email = email;
        TelephoneNr = telephoneNr;
        Function = function;
    }
    

    public User(string firstName, string lastName, string email, string telephoneNr, Function function, UserLocation location, Hospital hospital)
    {
        FirstName = firstName;
        LastName = lastName;
        Email = email;
        TelephoneNr = telephoneNr;
        Function = function;
        Location = location;
        Hospital = hospital;
    }
    
}