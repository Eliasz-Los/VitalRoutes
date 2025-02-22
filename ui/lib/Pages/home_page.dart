import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String title = "VitalRoutes";

  @override
  Widget build(BuildContext context) {
    final double imageWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Text(
                  'VitalRoutes',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                    letterSpacing: 1.2,
                    fontFamily: 'Arial',
                  ),
                ),
              ),
              // Creative tagline
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Connecting Care, Step by Step',
                  style: TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                    fontFamily: 'Times New Roman',
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/route.png',
                        width: imageWidth,
                        height: MediaQuery.of(context).size.width * 0.6,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 40),
                      SizedBox(
                        width: imageWidth,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            padding: EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                            shadowColor: Colors.blue.shade200,
                          ),
                          onPressed: () {
                          },
                          child: Text(
                            'Navigate',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                              letterSpacing: 0.5,
                              fontFamily: 'Arial',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
