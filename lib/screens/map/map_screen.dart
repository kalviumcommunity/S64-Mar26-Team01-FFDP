import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../search/search_screen.dart' show getSitterById;

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sitter = getSitterById('s1');

    return Scaffold(
      backgroundColor: const Color(0xFFEBEAE5), // Cream background
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Text(
                'Explore Map',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 120), // dock padding
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9C8A8), // Peach background
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black, offset: Offset(4, 4))
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Fake Map Background Content
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.map_rounded,
                                size: 80, color: Colors.black),
                            const SizedBox(height: 16),
                            Text(
                              'Neighborhood Map\nLoading...',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.black, 
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Fake Sitter Pin
                      Positioned(
                        top: 150,
                        left: 100,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                            boxShadow: const [
                              BoxShadow(color: Colors.black, offset: Offset(2, 2))
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(sitter.imagePath),
                          ),
                        ),
                      ),
                      // Floating Bottom sheet for selected Sitter
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black, width: 1.5),
                            boxShadow: const [
                              BoxShadow(color: Colors.black, offset: Offset(4, 4))
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black, width: 1.5),
                                ),
                                child: CircleAvatar(
                                    radius: 24,
                                    backgroundImage:
                                        NetworkImage(sitter.imagePath)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        sitter.name,
                                        style: GoogleFonts.playfairDisplay(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text(
                                        '${sitter.location} • ${sitter.rating} ★',
                                        style: GoogleFonts.lato(
                                            color: Colors.black54,
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF18698), // Pink pop
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.directions_rounded,
                                      color: Colors.white),
                                  onPressed: () {},
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
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
