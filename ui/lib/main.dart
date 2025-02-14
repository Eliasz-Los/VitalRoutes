import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/Pages/Users/UserProfileScreen.dart';
import 'package:ui/Pages/Users/UserProvider.dart';
import './Pages/Users/SignInScreen.dart';
import 'firebase_options.dart';
import './Pages/Users/UserMenuWidget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        title: 'Vital Routes',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Vital Routes'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  // User? _user; 

  static final List<Widget> _widgetOptions = <Widget>[
    Text('Home Page'),
    SignInScreen(),
  ];

/*  @override
  void initState() {
    super.initState();
    // _checkUser();
  }*/

/*  void _checkUser() {
    setState(() {
      _user = Provider.of<UserProvider>(context, listen: false).user;
    });
    
  }*/

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  void _viewProfile(User user) {
     Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(email: user.email!)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final user = userProvider.user;
            if (user != null) {
             return UserMenuWidget(user: user, onProfile: () => _viewProfile(user));
            }else{
              return TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
                },
                child: Text('Sign In'),
              );
            }
          },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Sign In',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}