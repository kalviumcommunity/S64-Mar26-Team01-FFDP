import 'dart:io';

void main() {
  var file = File('lib/screens/home/sitter_profile_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(RegExp(r"IconButton\(\s*icon:\s*const\s*Icon\(Icons.menu.*?\),\s*onPressed:\s*\(\)\s*\{\s*// We use a Scaffold key.*?\},\s*\),?", dotAll: true), '');
  file.writeAsStringSync(content);
}
