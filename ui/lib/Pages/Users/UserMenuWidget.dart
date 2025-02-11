import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Services/AuthService.dart';

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
      // Navigator.of(context).pushReplacementNamed('/signIn');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(user.email ?? 'User'),
        SizedBox(width: 8),
        Icon(Icons.person),
        PopupMenuButton<String>(
          onSelected: (String result) {
            if (result == 'profile') {
              onProfile();
            } else if (result == 'logout') {
              _signOut(context);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'profile',
              child: Text('Profile'),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Text('Logout'),
            ),
          ],
        ),
      ],
    );
  }
}