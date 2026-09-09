import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FilePickerService {
  FilePickerService._();
  static final FilePickerService instance = FilePickerService._();

  final ImagePicker _picker = ImagePicker();

  // ── Permanent storage helpers ──────────────────────────────────────────────

  /// Returns the app''s permanent uploads directory, creating it if needed.
  Future<Directory> _uploadsDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final uploadsDir = Directory(p.join(appDir.path, 'trackt_uploads'));
    if (!await uploadsDir.exists()) {
      await uploadsDir.create(recursive: true);
    }
    return uploadsDir;
  }

  /// Copies a file at [sourcePath] into the permanent uploads directory.
  Future<String?> _copyFilePathToPermanent(String sourcePath, String originalName) async {
    try {
      final source = File(sourcePath);
      if (!await source.exists()) {
        debugPrint('[FilePickerService] Source file not found: $sourcePath');
        return null;
      }
      final dir = await _uploadsDir();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final destName = '${timestamp}_$originalName';
      final dest = File(p.join(dir.path, destName));
      await source.copy(dest.path);
      return dest.path;
    } catch (e) {
      debugPrint('[FilePickerService] Copy error: $e');
      return null;
    }
  }

  /// Writes raw [bytes] into the permanent uploads directory.
  Future<String?> _writeBytesToPermanent(Uint8List bytes, String originalName) async {
    try {
      final dir = await _uploadsDir();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final destName = '${timestamp}_$originalName';
      final dest = File(p.join(dir.path, destName));
      await dest.writeAsBytes(bytes);
      return dest.path;
    } catch (e) {
      debugPrint('[FilePickerService] Write error: $e');
      return null;
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Picks an image and returns its **permanent** path, or null if cancelled.
  ///
  /// Uses [XFile.readAsBytes()] to read image data — this works regardless of
  /// whether the underlying path is a real file or an Android content URI.
  Future<String?> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (image == null) return null;

    try {
      final bytes = await image.readAsBytes();
      final originalName = p.basename(image.path).isNotEmpty
          ? p.basename(image.path)
          : 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      return _writeBytesToPermanent(bytes, originalName);
    } catch (e) {
      debugPrint('[FilePickerService] Image read error: $e');
      return null;
    }
  }

  /// Picks a document and returns its permanent path, or null if cancelled.
  /// Uses withData:true to receive raw bytes, avoiding Android content URI issues.
  Future<String?> pickDocument() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final originalName = file.name;

    if (file.bytes != null) {
      return _writeBytesToPermanent(file.bytes!, originalName);
    }

    if (file.path != null && file.path!.isNotEmpty) {
      return _copyFilePathToPermanent(file.path!, originalName);
    }

    debugPrint('[FilePickerService] No bytes or path returned for: $originalName');
    return null;
  }
}
