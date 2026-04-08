import 'dart:io';

void main() {
  final file = File('lib/screens/home/dashboard_screen.dart');
  String content = file.readAsStringSync();

  final regex = RegExp(r"final dashboardSitters = \[.*?\];", dotAll: true);
  content = content.replaceAll(regex, '''final dashboardSitters = [
  Sitter('s1', 'Priya Sharma', 4.9, '2 km away',
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=150&q=80'),
  Sitter('s2', 'Aarti Patel', 4.8, '5 km away',
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80'),
  Sitter('s3', 'Neha Gupta', 5.0, '1 km away',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=150&q=80'),
];''');

  final catRegex = RegExp(r"Widget _buildCategoryIcon\(IconData icon, String label, bool isSelected\) \{[\s\S]*?return Padding\([\s\S]*?child: Column\([\s\S]*?children: \[[\s\S]*?Container\([\s\S]*?decoration: BoxDecoration\([\s\S]*?color: isSelected \? const Color\(0xFFF9C8A8\) : Colors\.transparent, // Peach outline if selected[\s\S]*?borderRadius: BorderRadius\.circular\(16\),[\s\S]*?border: Border\.all\([\s\S]*?color: isSelected \? const Color\(0xFFF9C8A8\) : Colors\.black,[\s\S]*?width: 1\.5,[\s\S]*?\),[\s\S]*?\),[\s\S]*?child: Icon\(icon, color: isSelected \? Colors\.white : Colors\.black, size: 28\),[\s\S]*?\),[\s\S]*?const SizedBox\(height: 8\),[\s\S]*?Text\([\s\S]*?label,[\s\S]*?style: GoogleFonts\.lato\([\s\S]*?color: isSelected \? const Color\(0xFFF9C8A8\) : Colors\.black,[\s\S]*?fontSize: 12,[\s\S]*?fontWeight: isSelected \? FontWeight\.bold : FontWeight\.w600,[\s\S]*?\),[\s\S]*?\),[\s\S]*?\],[\s\S]*?\),[\s\S]*?\);[\s\S]*?\}");

  final newCategoryIcon = '''  Widget _buildCategoryIcon(IconData icon, String label, bool isSelected) {
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
  }''';

  content = content.replaceAll(catRegex, newCategoryIcon);
  file.writeAsStringSync(content);
}
