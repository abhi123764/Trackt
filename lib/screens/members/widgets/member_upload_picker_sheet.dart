import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/file_picker_service.dart';
import '../../../theme/app_theme.dart';

/// Reusable bottom sheet for picking profile photo, ID proof,
/// or medical reports on the member add/edit screens.
///
/// [documentType] must be one of: `'photo'`, `'id'`, `'medical'`
/// [hasFile] controls whether the "Remove File" option appears.
/// [onImagePicked] receives the chosen file path.
/// [onRemove] is called when the user taps "Remove File".
class MemberUploadPickerSheet extends StatelessWidget {
  final String documentType;
  final bool hasFile;
  final void Function(String path) onImagePicked;
  final VoidCallback onRemove;

  const MemberUploadPickerSheet({
    super.key,
    required this.documentType,
    required this.hasFile,
    required this.onImagePicked,
    required this.onRemove,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    Navigator.of(context).pop();
    final path = await FilePickerService.instance.pickImage(source);
    if (path != null) onImagePicked(path);
  }

  Future<void> _pickDocument(BuildContext context) async {
    Navigator.of(context).pop();
    final path = await FilePickerService.instance.pickDocument();
    if (path != null) onImagePicked(path);
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

/// Helper to show [MemberUploadPickerSheet] as a modal bottom sheet.
void showMemberUploadPicker({
  required BuildContext context,
  required String documentType,
  required bool hasFile,
  required void Function(String path) onImagePicked,
  required VoidCallback onRemove,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => MemberUploadPickerSheet(
      documentType: documentType,
      hasFile: hasFile,
      onImagePicked: onImagePicked,
      onRemove: onRemove,
    ),
  );
}
