import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> pickImage() async {
  final picker = ImagePicker();
  final XFile? userImage = await picker.pickImage(source: ImageSource.gallery);

  if(userImage != null) {
    // save file locally to application folder 
    final String localImageName = await saveXFileToAppFolder(userImage);
    // return local image 
    return localImageName;
  }

  return null;
}

// save file
Future<String> saveXFileToAppFolder(XFile image) async {
  final appDir = await getApplicationSupportDirectory();

  final Directory imagesDir = Directory('${appDir.path}/images');

  if(!await imagesDir.exists()) {
    await imagesDir.create(recursive: true);
  }

  final String imageName = '${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}';

  final String path = '${imagesDir.path}/$imageName';

  await File(image.path).copy(path);
  return imageName;
}

// delete file
Future<void> deleteImageFile(String fullPath)async {
  final file = File(fullPath);
  if(await file.exists()) {
    await file.delete();
  }
}
