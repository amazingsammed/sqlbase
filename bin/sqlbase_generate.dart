import 'dart:io';
import 'package:path/path.dart' as p;

void main(List<String> args) {

  final String scriptDir = p.dirname(Platform.script.toFilePath());
  final String templatePath = p.join(scriptDir, 'backend', 'sqlbase_template.php');
  String phpCode = File(templatePath).readAsStringSync();
  final outputPath = p.join(Directory.current.path, 'sqlbase2.php');
  File(outputPath).writeAsStringSync(phpCode);
  print("✅ PHP backend file generated at: $outputPath");
}
