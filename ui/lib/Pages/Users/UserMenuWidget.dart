import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Services/AuthService.dart';
import '../../main.dart';

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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage(title: 'Vital Routes')),);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
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
              PopupMenuItem<String>(value: 'profile', child: Text('Profile')),
              PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
            ]
        ).then((value) {
          if (value == 'profile') {
            onProfile();
          } else if (value == 'logout') {
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