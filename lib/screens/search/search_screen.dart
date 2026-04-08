import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../home/dashboard_screen.dart' show Sitter;

// Shared data repository for mock Indian babysitters (we can keep it here or externalize it)
final _allSitters = [
  Sitter('s1', 'Priya Sharma', 4.9, '2 km away',
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=150&q=80'),
  Sitter('s2', 'Aarti Patel', 4.8, '5 km away',
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80'),
  Sitter('s3', 'Neha Gupta', 5.0, '1 km away',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=150&q=80'),
  Sitter('s4', 'Kavita Singh', 4.7, '3 km away',
      'https://thumbs.dreamstime.com/b/happy-young-indian-woman-smiling-camera-standing-city-street-millennial-female-middle-eastern-feeling-positive-over-urban-301722030.jpg'),
  Sitter('s5', 'Riya Verma', 4.6, '6 km away',
      'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&w=150&q=80'),
  Sitter('s6', 'Anjali Desai', 4.9, '4 km away',
      'https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?auto=format&fit=crop&w=150&q=80'),
  Sitter('s7', 'Simran Kaur', 4.5, '7 km away',
      'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&w=150&q=80'),
  Sitter('s8', 'Meera Reddy', 4.8, '2.5 km away',
      'https://thumbs.dreamstime.com/b/vertical-portrait-happy-young-business-lady-indian-ethnicity-standing-confident-pose-looking-camera-profile-picture-339154738.jpg'),
  Sitter('s9', 'Sneha Joshi', 4.9, '1.5 km away',
      'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?auto=format&fit=crop&w=150&q=80'),
  Sitter('s10', 'Pooja Iyer', 4.7, '8 km away',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQz3zGJhadpV5CmEDYdvHFN3r3M34VZ_TtOJw&s'),
  Sitter('s11', 'Swati Mehta', 4.6, '9 km away',
      'https://images.unsplash.com/photo-1615813967515-e1838c1f5f09?auto=format&fit=crop&w=150&q=80'),
  Sitter('s12', 'Radhika Nair', 5.0, '0.5 km away',
      'https://images.unsplash.com/photo-1605993439219-9d09d2020fa5?auto=format&fit=crop&w=150&q=80'),
  Sitter('s13', 'Deepa Rao', 4.8, '2 km away',
      'https://images.unsplash.com/photo-1557862921-37829c790f19?auto=format&fit=crop&w=150&q=80'),
  Sitter('s14', 'Nidhi Kumar', 4.9, '3.5 km away',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSJHre8xGzFuI6rwvXolqMpaUQHmn6TQYfYpQ&s'),
  Sitter('s15', 'Divya Bose', 4.7, '4.5 km away',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTTNsEwdKJ-1baff5Q6k8jHMezSQokxWs3wMA&s'),
  Sitter('s16', 'Shweta Das', 4.6, '5.5 km away',
      'https://media.licdn.com/dms/image/v2/D5622AQGzrP5FTNM8sg/feedshare-shrink_800/feedshare-shrink_800/0/1687141820541?e=2147483647&v=beta&t=e8ju0ezo5VT8Z8eYYcFFFtADcFEquzEASllO04lTmHs'),
  Sitter('s17', 'Smriti Sen', 4.4, '6.5 km away',
      'https://media.licdn.com/dms/image/v2/D5603AQFOD-75BLNrWQ/profile-displayphoto-shrink_200_200/profile-displayphoto-shrink_200_200/0/1705135896273?e=2147483647&v=beta&t=qk5fGk-7_L-k7r9AuRU2-ZNAyny6grB7tOdjgBXmPpM'),
  Sitter('s18', 'Tara Menon', 4.9, '2.2 km away',
      'https://media.licdn.com/dms/image/v2/C4E03AQH1YN9A6GoCSQ/profile-displayphoto-shrink_200_200/profile-displayphoto-shrink_200_200/0/1637216239733?e=2147483647&v=beta&t=K1ByZFuHaYKMrhbQKgDTGAahTD-MM9XVNCQDCSE8RgU'),
  Sitter('s19', 'Rashi Pillai', 4.8, '3.1 km away',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3pskLR9MV6XLqA2C-JNtSkmjDK1zwMLwp5Q&s'),
  Sitter('s20', 'Vidya Chawla', 5.0, '1.2 km away',
      'https://images.unsplash.com/photo-1614204424926-196a80bf0be8?auto=format&fit=crop&w=150&q=80'),
];

Sitter getSitterById(String id) =>
    _allSitters.firstWhere((s) => s.id == id, orElse: () => _allSitters[0]);


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Sitter> _filteredSitters = _allSitters;

  void _onSearchChanged(String query) {
    setState(() {
      _filteredSitters = _allSitters.where((sitter) {
        final sitterLower = sitter.name.toLowerCase();
        final searchLower = query.toLowerCase();
        return sitterLower.contains(searchLower);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEAE5), // Cream background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              
              // Search Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(4, 4))
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: GoogleFonts.lato(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Search for babysitters...',
                    hintStyle: GoogleFonts.lato(color: Colors.black54),
                    prefixIcon: const Icon(Icons.search, color: Colors.black54),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.black),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Babysitters',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '${_filteredSitters.length} found',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: _filteredSitters.isEmpty
                    ? Center(
                        child: Text(
                          'No results found',
                          style: GoogleFonts.lato(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _filteredSitters.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: _SearchResultListItem(sitter: _filteredSitters[index]),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 80), // dock padding
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultListItem extends StatelessWidget {
  final Sitter sitter;
  const _SearchResultListItem({required this.sitter});

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
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.black, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${sitter.rating} • ${sitter.location}',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
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
