// qr_save_web.dart
import 'dart:html' as html;
import 'dart:typed_data';

Future<void> saveQr(Uint8List pngBytes, String filename) async {
  final blob = html.Blob([pngBytes], 'image/png');
  final url = html.Url.createObjectUrlFromBlob(blob);

  html.AnchorElement(href: url)
    ..setAttribute("download", "$filename.png")
    ..click();

  html.Url.revokeObjectUrl(url);
}
