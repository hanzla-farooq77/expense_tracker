import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {

  static const String cloudName = "dmldm7jei";
  static const String uploadPreset = "hnzlamayo";


  static Future<String?> uploadImage() async {
    try {

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null) {
        print("⚠️ No image selected");
        return null;
      }

      final imageFile = File(pickedFile.path);

      final uploadUrl =
      Uri.parse("https://api.cloudinary.com/v1_1/dmldm7jei/image/upload");

      final request = http.MultipartRequest("POST", uploadUrl)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final resBody = await response.stream.bytesToString();
        final data = jsonDecode(resBody);
        final imageUrl = data['secure_url'];
        print("✅ Uploaded image URL: $imageUrl");
        return imageUrl;
      } else {
        final error = await response.stream.bytesToString();
        print("❌ Upload failed: $error");
        return null;
      }
    } catch (e) {
      print("⚠️ Error uploading image: $e");
      return null;
    }
  }
}
