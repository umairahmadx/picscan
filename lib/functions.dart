import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

String imageFinal = "";
String message = "";
Uint8List? imageBytes=null;

final gemini = Gemini.instance;

Future<File?> compressFile(File image, Function callState) async {
  callState(); // Indicate processing start
  int quality = 100;
  File? resultFile;

  try {
    do {
      quality -= 10;
      var result = await FlutterImageCompress.compressAndGetFile(
        image.path,
        '${image.path}_compressed.jpg', // Compressed file path
        quality: quality,
      );

      if (result == null) return null;

      resultFile = File(result.path);
    } while ((resultFile.lengthSync() / 1024) > 1000 && quality > 10);
  } catch (e) {
    debugPrint("Compression error: $e");
    return null;
  }

  try {
    if (await image.exists()) {
      await image.delete(); // Delete original if compression succeeds
    }
  } catch (e) {
    debugPrint("Error deleting original file: $e");
  }

  callState(); // Indicate processing end
  return resultFile;
}

Future<void> imagePickerWeb() async {
  XFile? img2;

  // Pick image based on platform
  final ImagePicker picker = ImagePicker();
  img2 = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
  if(img2!=null){
    final bytes = await img2.readAsBytes();
    imageBytes = bytes;
  }
}

Future<void> imagePicker(Function callState) async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  if (image == null) return;

  File? compressed = await compressFile(File(image.path), callState);
  if (compressed != null) {
    imageFinal = compressed.path;
  } else {
    debugPrint("Compression failed or file is null.");
  }
}
Future<String> apiCall(String imagePath) async {
  File imageFile = File(imagePath);
  message="";
  try {
    final response = await Gemini.instance.prompt(parts: [
      Part.bytes(await imageFile.readAsBytes()),
      Part.text("Identify and Describe The Object In this Image?"),
    ]);

    if (response != null && response.output != null) {
      message = response.output!;
      return message;
    } else {
      debugPrint("API response is null.");
      return "No response from API.";
    }
  } catch (e) {
    debugPrint("Error during API call: $e");
    return "Error processing request.";
  }
}

Future<String> apiCallWeb(Uint8List bytes) async {
  message="";
  try {
    final response = await Gemini.instance.prompt(
      parts: [
        Part.bytes(bytes),
        Part.text("Identify and Describe The Object In this Image?"),
      ],
    );

    if (response != null && response.output != null) {
      message = response.output!;
      return message;
    } else {
      debugPrint("API response is null.");
      return "No response from API.";
    }
  } catch (e) {
    debugPrint("Error during API call: $e");
    return "Error processing request.";
  }
}
