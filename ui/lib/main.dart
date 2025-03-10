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
    options: DefaultFirebaseOptions.currentPlatform
  );
  String e1 = ".env.development";
  String e2 = ".env.production";
  String envFile = String.fromEnvironment('ENV_FILE', defaultValue: e2);
  print('Using env file: $envFile');
  await dotenv.load(fileName: envFile);
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
        home: MainScaffold(body: HomePage()),
      ),
    );
  }
}
