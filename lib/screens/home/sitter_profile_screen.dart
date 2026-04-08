import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../search/search_screen.dart' show getSitterById;

class SitterProfileScreen extends StatefulWidget {
  final String id;
  const SitterProfileScreen({super.key, required this.id});

  @override
  State<SitterProfileScreen> createState() => _SitterProfileScreenState();
}

class _SitterProfileScreenState extends State<SitterProfileScreen> {
  final _lotties = [
    'lib/lotties/Baby (1).json',
    'lib/lotties/baby.json',
    'lib/lotties/Say hi cute baby girl.json'
  ];
  late String _randomLottie;

  @override
  void initState() {
    super.initState();
    _randomLottie = _lotties[Random().nextInt(_lotties.length)];
  }

  @override
  Widget build(BuildContext context) {
    final sitter = getSitterById(widget.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF9C8A8), // Peach background
      body: Stack(
        children: [
          // Background random Lottie at the top space
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 250,
              child: Lottie.asset(
                _randomLottie,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back, color: Colors.black),
                        const SizedBox(width: 8),
                        Text(
                          'Back',
                          style: GoogleFonts.lato(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                ],
              ),
            ),
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sitter.name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (index) => Padding(
                                  padding: const EdgeInsets.only(right: 2),
                                  child: Icon(
                                    index < sitter.rating.floor()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.black,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${sitter.rating.toString().replaceAll('.', ',')} (38 Reviews)',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sitter.location,
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        Text(
                          'Bio',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.lato(
                              color: Colors.black87,
                              fontSize: 15,
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    '${sitter.name.split(" ").first} is an experienced babysitter, with almost 15 years of practice. She raised her own 2 children... ',
                              ),
                              TextSpan(
                                text: 'Read more',
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildAttributeItem(Icons.child_care, 'Fulltime'),
                              _buildAttributeItem(Icons.looks_5, 'Kids max', isNumberIcon: true, number: '5'),
                              _buildAttributeItem(Icons.directions_car, 'Car'),
                              _buildAttributeItem(Icons.restaurant, 'Cooking'),
                              _buildAttributeItem(Icons.pets, 'Care'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        
                        Text(
                           'Fee',
                           style: GoogleFonts.lato(
                             fontSize: 14,
                             color: Colors.black54,
                           ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                           '€ 6 / h',
                           style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                           ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Dock Button Fixed at Bottom Right perfectly overlapping
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () {
                        context.push('/loader', extra: '/chat/${sitter.id}');
                      },
                      child: Container(
                        width: 200,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF9C8A8), // Peach
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(32)),
                          border: Border(
                            top: BorderSide(color: Colors.black, width: 2),
                            left: BorderSide(color: Colors.black, width: 2),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Contact ${sitter.name.split(" ").first}',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35 - 50,
            left: 24,
            child: Hero(
              tag: 'avatar_${sitter.id}', // Added hero animation
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.5),
                  image: DecorationImage(
                    image: NetworkImage(sitter.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeItem(IconData icon, String label, {bool isNumberIcon = false, String number = ''}) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            alignment: Alignment.center,
            child: isNumberIcon
                ? Text(
                    number,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  )
                : Icon(icon, color: Colors.black, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
