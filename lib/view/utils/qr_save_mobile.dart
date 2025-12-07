
import 'dart:typed_data';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

Future<void> saveQr(Uint8List pngBytes, String filename) async {
  await ImageGallerySaverPlus.saveImage(
    pngBytes,
    name: filename,
  );
}
