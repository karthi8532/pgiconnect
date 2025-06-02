import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick a single image from gallery
  static Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  /// Pick multiple images (up to maxLimit)
  static Future<List<File>> pickMultipleImages({int maxLimit = 5}) async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      return images.take(maxLimit).map((xfile) => File(xfile.path)).toList();
    }
    return [];
  }
}
