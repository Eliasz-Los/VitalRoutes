import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this dependency in pubspec.yaml

class HomePage extends StatelessWidget {
  final String title = "VitalRoutes";

  @override
  Widget build(BuildContext context) {
    // Calculate responsive image width (80% of screen width)
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
              // Larger title positioned higher
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Text(
                  'VitalRoutes',
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              // Creative tagline
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Connecting Care, Step by Step',
                  style: GoogleFonts.lora(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              // Spacer to push content to center
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Larger image
                      Image.asset(
                        'assets/route.png',
                        width: imageWidth,
                        height: MediaQuery.of(context).size.width * 0.6,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 40),
                      // Navigate button matching image width
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
                            // Add navigation logic here
                          },
                          child: Text(
                            'Navigate',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                              letterSpacing: 0.5,
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