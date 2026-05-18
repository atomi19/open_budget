import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

// pick image from gallery
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

// take a photo 
Future<String?> getImageFromCamera() async {
  final picker = ImagePicker();
  final XFile? takenPhoto = await picker.pickImage(
    source: ImageSource.camera,
  );

  if(takenPhoto != null) {
    final String localImageName = await saveXFileToAppFolder(takenPhoto);
    return localImageName;
  }

  return null;
}

// pick image from files
Future<String?> pickFile() async {
  FilePickerResult? result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
  );

  if(result != null) {
    final XFile convertToXFile = XFile(result.files.single.path!);
    final String localImageName = await saveXFileToAppFolder(convertToXFile);
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
