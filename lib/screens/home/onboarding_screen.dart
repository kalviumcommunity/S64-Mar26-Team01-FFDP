import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _lotties = [
    'lib/lotties/Say hi cute baby girl.json', // Page 1
    'lib/lotties/baby.json',                 // Page 2
    'lib/lotties/Baby (1).json',             // Page 3
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/loader', extra: '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9C8A8), // Peach background
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Header Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    'Difficult home office?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quickly find the best babysitter around\nand work from home peacefully',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Animation Wrapper
            SizedBox(
              height: 380,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF18698), // Inner pink box
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Lottie.asset(
                        _lotties[index],
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const Spacer(),

            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => _buildDot(index == _currentPage)),
            ),
            
            const SizedBox(height: 48),

            // Bottom Action Area
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: _nextPage,
                child: Container(
                  width: _currentPage == 2 ? 200 : 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC4C6D0), // Grayish tone
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(32)),
                    border: Border(
                      top: BorderSide(color: Colors.black, width: 2),
                      left: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: _currentPage == 2 
                      ? Text(
                          'Find a Baby-Sitter',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(Icons.arrow_forward_rounded, size: 32, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 1.5),
      ),
    );
  }
}
