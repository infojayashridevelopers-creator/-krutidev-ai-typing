import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> downloadDocxFile(List<int> bytes, String filename) async {
  if (Platform.isWindows) {
    // Save to Documents folder and open with MS Word
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    await Process.run('explorer', [file.path]);
  } else {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [
        XFile(
          file.path,
          mimeType:
              'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          name: filename,
        )
      ],
      subject: 'Kruti Dev Document',
    );
  }
}
