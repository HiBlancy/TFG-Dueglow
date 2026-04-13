import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';

class ImageService {
  static const int MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
  static const int MAX_WIDTH = 1200;
  static const int MAX_HEIGHT = 1200;
  static const int COMPRESSION_QUALITY = 85;
  
  static const List<String> ALLOWED_EXTENSIONS = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> ALLOWED_MIME_TYPES = [
    'image/jpeg',
    'image/png',
    'image/webp',
  ];

  final ImagePicker _picker = ImagePicker();

  /// Selecciona una imagen desde la galería
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        return await _validateAndCompressImage(imageFile);
      }
      return null;
    } catch (e) {
      print('❌ Error seleccionando imagen de galería: $e');
      return null;
    }
  }

  /// Captura una imagen con la cámara
  Future<File?> takePhotoWithCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        return await _validateAndCompressImage(imageFile);
      }
      return null;
    } catch (e) {
      print('❌ Error al capturar foto: $e');
      return null;
    }
  }

  /// Valida y comprime la imagen
  Future<File?> _validateAndCompressImage(File imageFile) async {
    try {
      // 1️⃣ Validar que el archivo existe
      if (!await imageFile.exists()) {
        print('❌ El archivo no existe');
        return null;
      }

      // 2️⃣ Validar tamaño inicial
      final fileSizeBytes = await imageFile.length();
      if (fileSizeBytes > MAX_FILE_SIZE) {
        print('❌ El archivo es demasiado grande: ${(fileSizeBytes / 1024 / 1024).toStringAsFixed(2)}MB (máximo 5MB)');
        return null;
      }

      // 3️⃣ Validar extensión
      final extension = _getFileExtension(imageFile.path);
      if (!ALLOWED_EXTENSIONS.contains(extension.toLowerCase())) {
        print('❌ Tipo de archivo no permitido: $extension');
        return null;
      }

      // 4️⃣ Validar MIME type
      final mimeType = lookupMimeType(imageFile.path);
      if (!ALLOWED_MIME_TYPES.contains(mimeType)) {
        print('❌ MIME type no permitido: $mimeType');
        return null;
      }

      // 5️⃣ Comprimir imagen
      print('📦 Comprimiendo imagen...');
      final compressedFile = await _compressImage(imageFile);

      if (compressedFile != null) {
        final compressedSize = await compressedFile.length();
        print('✅ Imagen comprimida: ${(fileSizeBytes / 1024 / 1024).toStringAsFixed(2)}MB → ${(compressedSize / 1024 / 1024).toStringAsFixed(2)}MB');
        return compressedFile;
      }

      return imageFile;
    } catch (e) {
      print('❌ Error validando/comprimiendo imagen: $e');
      return null;
    }
  }

  /// Comprime la imagen
  Future<File?> _compressImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        print('❌ No se pudo decodificar la imagen');
        return null;
      }

      // Redimensionar si es necesario
      img.Image thumbnail = image;
      if (image.width > MAX_WIDTH || image.height > MAX_HEIGHT) {
        thumbnail = img.copyResize(
          image,
          width: image.width > image.height ? MAX_WIDTH : null,
          height: image.height > image.width ? MAX_HEIGHT : null,
          interpolation: img.Interpolation.linear,
        );
      }

      // Codificar a JPEG con compresión
      final compressedBytes = img.encodeJpg(thumbnail, quality: COMPRESSION_QUALITY);

      // Guardar en archivo temporal
      final tempDir = Directory.systemTemp;
      final compressedFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      print('❌ Error comprimiendo: $e');
      return null;
    }
  }

  /// Obtiene la extensión del archivo
  String _getFileExtension(String filePath) {
    return filePath.split('.').last;
  }

  /// Obtiene información de la imagen para debugging
  Future<Map<String, dynamic>> getImageInfo(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final mimeType = lookupMimeType(imageFile.path);
      final size = await imageFile.length();

      return {
        'path': imageFile.path,
        'size': size,
        'sizeInMB': (size / 1024 / 1024).toStringAsFixed(2),
        'mimeType': mimeType,
        'extension': _getFileExtension(imageFile.path),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}