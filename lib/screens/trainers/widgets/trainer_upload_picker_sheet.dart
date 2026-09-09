import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/file_picker_service.dart';
import '../../../theme/app_theme.dart';

/// Reusable bottom sheet for picking profile photo, ID proof,
/// or certificate on the trainer add/edit screens.
///
/// [documentType] must be one of: `'photo'`, `'id'`, `'certificate'`
/// [hasFile] controls whether the "Remove File" option appears.
/// [onFilePicked] receives the chosen file path.
/// [onRemove] is called when the user taps "Remove File".
class TrainerUploadPickerSheet extends StatelessWidget {
  final String documentType;
  final bool hasFile;
  final void Function(String path) onFilePicked;
  final VoidCallback onRemove;

  const TrainerUploadPickerSheet({
    super.key,
    required this.documentType,
    required this.hasFile,
    required this.onFilePicked,
    required this.onRemove,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    Navigator.of(context).pop();
    final path = await FilePickerService.instance.pickImage(source);
    if (path != null) onFilePicked(path);
  }

  Future<void> _pickDocument(BuildContext context) async {
    Navigator.of(context).pop();
    final path = await FilePickerService.instance.pickDocument();
    if (path != null) onFilePicked(path);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(
              Icons.camera_alt_outlined,
              color: AppColors.tealPrimary,
            ),
            title: const Text(
              'Take Photo',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            onTap: () => _pickImage(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(
              Icons.photo_library_outlined,
              color: AppColors.tealPrimary,
            ),
            title: const Text(
              'Choose from Gallery',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            onTap: () => _pickImage(context, ImageSource.gallery),
          ),
          if (documentType != 'photo')
            ListTile(
              leading: const Icon(
                Icons.description_outlined,
                color: AppColors.tealPrimary,
              ),
              title: const Text(
                'Upload Document (PDF/File)',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
              onTap: () => _pickDocument(context),
            ),
          if (hasFile)
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: AppColors.danger,
              ),
              title: const Text(
                'Remove File',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.danger,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onRemove();
              },
            ),
        ],
      ),
    );
  }
}

/// Helper to show [TrainerUploadPickerSheet] as a modal bottom sheet.
void showTrainerUploadPicker({
  required BuildContext context,
  required String documentType,
  required bool hasFile,
  required void Function(String path) onFilePicked,
  required VoidCallback onRemove,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => TrainerUploadPickerSheet(
      documentType: documentType,
      hasFile: hasFile,
      onFilePicked: onFilePicked,
      onRemove: onRemove,
    ),
  );
}
