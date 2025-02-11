import 'package:flutter/material.dart';
import 'widgets/custom_drawer.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'VitalRoutes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24, 
          ),
        ),
        backgroundColor: Colors.blue,
        toolbarHeight: 70, 
      ),
      drawer: CustomDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Home',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Placeholder afbeelding
            Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: Icon(
                Icons.image,
                size: 100,
                color: Colors.grey[600],
              ),
            ),
            Image.asset('assets/route.png', width: 200, height: 200),
            SizedBox(height: 30), // Meer witruimte
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              height: MediaQuery.of(context).size.width * 0.18,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, 
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                 
                },
                child: Text(
                  'Navigate',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
