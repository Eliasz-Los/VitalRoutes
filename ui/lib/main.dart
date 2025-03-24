import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:ui/Pages/Users/UserProvider.dart';
import 'Pages/Navigation/MainScaffold.dart';
import 'Pages/home_page.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  String e1 = ".env.development";
  String e2 = ".env.production";
  String envFile = String.fromEnvironment('ENV_FILE', defaultValue: e2);
  await dotenv.load(fileName: envFile);
  runApp(MyApp(userProvider: UserProvider()));
}

class MyApp extends StatelessWidget {
  final UserProvider userProvider;
  const MyApp({Key? key, required this.userProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => userProvider),
      ],
      child: MaterialApp(
        title: 'Vital Routes',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: MainScaffold(body: HomePage()),
      ),
    );
  }
}