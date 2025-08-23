import 'dart:io';
import 'package:path/path.dart' as p;

void main(List<String> args) {
  stdout.write("Enter MySQL Host (e.g., localhost): ");
  final String host = stdin.readLineSync() ?? 'localhost';

  stdout.write("Enter MySQL Username: ");
  final String user = stdin.readLineSync() ?? 'root';

  stdout.write("Enter MySQL Password: ");
  final String pass = stdin.readLineSync() ?? '';

  stdout.write("Enter Database Name: ");
  final String db = stdin.readLineSync() ?? '';

  // Locate PHP template
  final String scriptDir = p.dirname(Platform.script.toFilePath());
  final String templatePath = p.join(scriptDir, 'backend', 'sqlbase_template.php');

  // Read template
  String phpCode = File(templatePath).readAsStringSync();


  phpCode = phpCode
      .replaceAll('{{DB_HOST}}', host)
      .replaceAll('{{DB_USER}}', user)
      .replaceAll('{{DB_PASS}}', pass)
      .replaceAll('{{DB_NAME}}', db);

  final outputPath = p.join(Directory.current.path, 'sqlbase.php');
  File(outputPath).writeAsStringSync(phpCode);

  print("✅ PHP backend file generated at: $outputPath");
}
