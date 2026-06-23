// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

Future<void> downloadDocxFile(List<int> bytes, String filename) async {
  final blob = html.Blob(
    [bytes],
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  );
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
