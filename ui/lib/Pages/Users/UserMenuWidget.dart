import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:ui/Pages/Users/UserProvider.dart';
import '../../Services/AuthService.dart';
import '../Navigation/MainScaffold.dart';
import '../home_page.dart';

class UserMenuWidget extends StatelessWidget {
  final User user;
  final VoidCallback onProfile;

  const UserMenuWidget({
    Key? key,
    required this.user,
    required this.onProfile,
  }) : super(key: key);

  Future<void> _signOut(BuildContext context) async {
    try {
      await AuthService.signOut();
      Provider.of<UserProvider>(context, listen: false).setUser(null);
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => MainScaffold(body: HomePage())),);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error bij uitloggen: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showMenu(
            context: context, position: RelativeRect.fromLTRB(100, 100, 0, 0),
            items: <PopupMenuEntry<String>>[
              PopupMenuItem<String>(value: 'profiel', child: Text('Profiel')),
              PopupMenuItem<String>(value: 'uitloggen', child: Text('Uitloggen')),
            ]
        ).then((value) {
          if (value == 'profiel') {
            onProfile();
          } else if (value == 'uitloggen') {
            _signOut(context);
          }
        });
      },
      child: Row(
        children: [
          Text(user.email ?? 'User'),
          const SizedBox(width: 6),
          Icon(Icons.person),
        ],
      ),
    );
  }
}