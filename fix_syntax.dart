import 'dart:io';

void main() {
  final file = File('lib/screens/home/dashboard_screen.dart');
  var content = file.readAsStringSync();
  
  var parts = content.split('class _ResultListItem');
  if (parts.length > 1) {
    var topPart = parts[0];
    var beforeData = topPart.substring(0, topPart.indexOf('final dashboardSitters = ['));
    
    var correctData = '''
final dashboardSitters = [
  Sitter('s1', 'Priya Sharma', 4.9, '2 km away',
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=150&q=80'),
  Sitter('s2', 'Aarti Patel', 4.8, '5 km away',
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80'),
  Sitter('s3', 'Neha Gupta', 5.0, '1 km away',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=150&q=80'),
];

''';
    var finalContent = beforeData + correctData + 'class _ResultListItem' + parts[1];
    file.writeAsStringSync(finalContent);
  }
}
