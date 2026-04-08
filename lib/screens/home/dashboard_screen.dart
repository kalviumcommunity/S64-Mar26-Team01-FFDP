import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<String> _userNameFuture;
  final authService = AuthService();

  @override
  void initState() {
    super.initState();
    _userNameFuture = authService.getUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9C8A8), // Cream background
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi,',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                      FutureBuilder<String>(
                        future: _userNameFuture,
                        builder: (context, snapshot) {
                          final displayName =
                              snapshot.data?.split(' ').first ?? 'User';
                          return Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.black, width: 2),
                              ),
                            ),
                            child: Text(
                              '$displayName!',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  
                ],
              ),
              const SizedBox(height: 30),

              // Search Bar
              GestureDetector(
                onTap: () => context.go('/search'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.black54),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Bratislava, own car, fulltime...',
                          style: GoogleFonts.lato(color: Colors.black54, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Categories Header
              Text(
                'Categories',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // Sub-categories tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSubCategoryTab('Experiences', true),
                  _buildSubCategoryTab('Activities', false),
                  _buildSubCategoryTab('Ratings', false),
                  _buildSubCategoryTab('Fees', false),
                ],
              ),
              const SizedBox(height: 20),

              // Horizontal Category Icons
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildCategoryIcon(Icons.child_care, 'Baby', false),
                    _buildCategoryIcon(Icons.directions_run, 'Toddler', false),
                    _buildCategoryIcon(Icons.face, 'Preschooler', true), // Highlighted one
                    _buildCategoryIcon(Icons.directions_walk, 'Schoolchild', false),
                    _buildCategoryIcon(Icons.school, 'Teenager', false),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Results Header
              Text(
                'Results',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // Results List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dashboardSitters.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _ResultListItem(sitter: dashboardSitters[index]),
                  );
                },
              ),
              const SizedBox(height: 80), // bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategoryTab(String title, bool isSelected) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 14,
            color: isSelected ? Colors.black : Colors.black45,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (isSelected)
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 4,
            width: 4,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          )
      ],
    );
  }

    Widget _buildCategoryIcon(IconData icon, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: isSelected ? const [
                BoxShadow(color: Colors.black, offset: Offset(4, 4))
              ] : null,
            ),
            child: Icon(icon, color: Colors.black, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.lato(
              color: Colors.black,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

}

// Minimal dummy data class for Dashboard
class Sitter {
  final String id;
  final String name;
  final double rating;
  final String location;
  final String imagePath;
  Sitter(this.id, this.name, this.rating, this.location, this.imagePath);
}

final dashboardSitters = [
  Sitter('s1', 'Priya Sharma', 4.9, '2 km away',
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=150&q=80'),
  Sitter('s2', 'Aarti Patel', 4.8, '5 km away',
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80'),
  Sitter('s3', 'Neha Gupta', 5.0, '1 km away',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=150&q=80'),
];

class _ResultListItem extends StatelessWidget {
  final Sitter sitter;
  const _ResultListItem({required this.sitter});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/loader', extra: '/sitter/${sitter.id}'),
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            // Avatar with black border
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5),
                image: DecorationImage(
                  image: NetworkImage(sitter.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sitter.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sitter.location,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
