import 'dart:io';

void main() {
  final file = File('lib/config/router.dart');
  String content = file.readAsStringSync();
  
  content = content.replaceAll(
    "name: 'loader',", 
    "name: 'loader',\n        parentNavigatorKey: rootNavigatorKey,"
  );
  content = content.replaceAll(
    "name: 'sitter_profile',", 
    "name: 'sitter_profile',\n        parentNavigatorKey: rootNavigatorKey,"
  );
  content = content.replaceAll(
    "name: 'chat_detail',", 
    "name: 'chat_detail',\n        parentNavigatorKey: rootNavigatorKey,"
  );

  file.writeAsStringSync(content);
}
