import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/trainer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trainer_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';

class EditTrainerScreen extends StatefulWidget {
  final Trainer trainer;

  const EditTrainerScreen({super.key, required this.trainer});

  @override
  State<EditTrainerScreen> createState() => _EditTrainerScreenState();
}

class _EditTrainerScreenState extends State<EditTrainerScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  // File paths
  late String? _profilePhotoPath;
  late String? _idProofPath;
  late String? _certificatePhotoPath;

  // Controllers — initialised in initState from existing trainer data
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _dobController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _qualificationController;
  late final TextEditingController _experienceController;
  late final TextEditingController _shiftStartController;
  late final TextEditingController _shiftEndController;
  late final TextEditingController _joiningDateController;
  late final TextEditingController _salaryController;

  late String _gender;
  late String _bloodGroup;

  static const _genders = ['Male', 'Female', 'Other'];
  static const _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.trainer;

    _nameController = TextEditingController(text: t.name);
    _ageController = TextEditingController(text: t.age.toString());
    _dobController = TextEditingController(text: t.dob ?? '');
    _mobileController = TextEditingController(text: t.mobileNumber ?? '');
    _emailController = TextEditingController(text: t.email ?? '');
    _addressController = TextEditingController(text: t.address ?? '');
    _qualificationController = TextEditingController(
      text: t.qualification ?? '',
    );
    _experienceController = TextEditingController(text: t.experience ?? '');
    _shiftStartController = TextEditingController(text: t.shiftStart ?? '');
    _shiftEndController = TextEditingController(text: t.shiftEnd ?? '');
    _joiningDateController = TextEditingController(text: t.joiningDate);
    _salaryController = TextEditingController(
      text: t.salary > 0 ? t.salary.toStringAsFixed(0) : '',
    );

    // Ensure gender/blood group defaults are valid list entries
    _gender = _genders.contains(t.gender) ? t.gender! : _genders.first;
    _bloodGroup = _bloodGroups.contains(t.bloodGroup)
        ? t.bloodGroup!
        : _bloodGroups.first;

    _profilePhotoPath = t.profilePhotoPath;
    _idProofPath = t.idProofPath;
    _certificatePhotoPath = t.certificatePhotoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _dobController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _shiftStartController.dispose();
    _shiftEndController.dispose();
    _joiningDateController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final updated = Trainer(
      id: widget.trainer.id,
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? widget.trainer.age,
      gender: _gender,
      dob: _dobController.text.trim().isEmpty
          ? null
          : _dobController.text.trim(),
      bloodGroup: _bloodGroup,
      mobileNumber: _mobileController.text.trim().isEmpty
          ? null
          : _mobileController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      profilePhotoPath: _profilePhotoPath,
      idProofPath: _idProofPath,
      qualification: _qualificationController.text.trim().isEmpty
          ? null
          : _qualificationController.text.trim(),
      certificatePhotoPath: _certificatePhotoPath,
      experience: _experienceController.text.trim().isEmpty
          ? null
          : _experienceController.text.trim(),
      shiftStart: _shiftStartController.text.trim().isEmpty
          ? null
          : _shiftStartController.text.trim(),
      shiftEnd: _shiftEndController.text.trim().isEmpty
          ? null
          : _shiftEndController.text.trim(),
      joiningDate: _joiningDateController.text.trim().isEmpty
          ? widget.trainer.joiningDate
          : _joiningDateController.text.trim(),
      salary:
          double.tryParse(_salaryController.text.trim()) ??
          widget.trainer.salary,
    );

    final provider = context.read<TrainerProvider>();
    final success = await provider.updateTrainer(updated);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trainer profile updated successfully!'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Failed to update trainer. Please try again.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _showUploadOptions(String documentType) async {
    final bool hasFile =
        (documentType == 'photo' && _profilePhotoPath != null) ||
        (documentType == 'id' && _idProofPath != null) ||
        (documentType == 'certificate' && _certificatePhotoPath != null);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
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
              onTap: () {
                Navigator.of(ctx).pop();
                _getImage(documentType, ImageSource.camera);
              },
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
              onTap: () {
                Navigator.of(ctx).pop();
                _getImage(documentType, ImageSource.gallery);
              },
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
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickDocument(documentType);
                },
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
                  Navigator.of(ctx).pop();
                  setState(() {
                    if (documentType == 'photo') _profilePhotoPath = null;
                    if (documentType == 'id') _idProofPath = null;
                    if (documentType == 'certificate') {
                      _certificatePhotoPath = null;
                    }
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(String documentType, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null && image.path.isNotEmpty) {
        setState(() {
          if (documentType == 'photo') _profilePhotoPath = image.path;
          if (documentType == 'id') _idProofPath = image.path;
          if (documentType == 'certificate') _certificatePhotoPath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick image: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _pickDocument(String documentType) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.single.path;
        if (filePath != null && filePath.isNotEmpty) {
          setState(() {
            if (documentType == 'id') _idProofPath = filePath;
            if (documentType == 'certificate') _certificatePhotoPath = filePath;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick document: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.tealPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.tealPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() => controller.text = picked.format(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    final initial = (currentUser != null && currentUser.fName.isNotEmpty)
        ? currentUser.fName[0].toUpperCase()
        : 'A';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP BAR ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: Color(0xFF344054),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Edit Trainer Details',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF054446),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_none_outlined,
                      color: Color(0xFF344054),
                    ),
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF054446),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── SCROLLABLE FORM ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── GENERAL DETAILS ─────────────────────────────
                      _buildCardContainer(
                        children: [
                          _buildLabeledField(
                            label: 'Full Name',
                            child: TextFormField(
                              controller: _nameController,
                              style: _inputStyle,
                              decoration: _inputDecor('Enter full name'),
                              validator: (v) => AppValidators.validateRequired(
                                v,
                                'Full Name',
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _buildLabeledField(
                                  label: 'Age',
                                  child: TextFormField(
                                    controller: _ageController,
                                    keyboardType: TextInputType.number,
                                    style: _inputStyle,
                                    decoration: _inputDecor('Years'),
                                    validator: (v) =>
                                        AppValidators.validateRequired(
                                          v,
                                          'Age',
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildLabeledField(
                                  label: 'Gender',
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _gender,
                                    style: _inputStyle,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Color(0xFF667085),
                                    ),
                                    decoration: _inputDecor('Select'),
                                    items: _genders
                                        .map(
                                          (g) => DropdownMenuItem(
                                            value: g,
                                            child: Text(g, style: _inputStyle),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() => _gender = v);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _buildLabeledField(
                                  label: 'Date of Birth',
                                  child: TextFormField(
                                    controller: _dobController,
                                    readOnly: true,
                                    onTap: () => _pickDate(_dobController),
                                    style: _inputStyle,
                                    decoration: _inputDecor('mm/dd/yyyy'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildLabeledField(
                                  label: 'Blood Group',
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _bloodGroup,
                                    style: _inputStyle,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Color(0xFF667085),
                                    ),
                                    decoration: _inputDecor('Select'),
                                    items: _bloodGroups
                                        .map(
                                          (b) => DropdownMenuItem(
                                            value: b,
                                            child: Text(b, style: _inputStyle),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() => _bloodGroup = v);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildLabeledField(
                            label: 'Mobile',
                            child: TextFormField(
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              style: _inputStyle,
                              decoration: _inputDecor('+1 234...'),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildLabeledField(
                            label: 'Email Address',
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: _inputStyle,
                              decoration: _inputDecor('trainer@trackt.com'),
                              validator: (v) {
                                if (v != null && v.trim().isNotEmpty) {
                                  return AppValidators.validateEmail(v);
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildLabeledField(
                            label: 'Home Address',
                            child: TextFormField(
                              controller: _addressController,
                              maxLines: 3,
                              style: _inputStyle,
                              decoration: _inputDecor('Enter complete address'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _DashedUploadBox(
                                  icon: Icons.camera_alt_outlined,
                                  label: 'Upload Photo',
                                  isUploaded: _profilePhotoPath != null,
                                  onTap: () => _showUploadOptions('photo'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _DashedUploadBox(
                                  icon: Icons.fingerprint,
                                  label: 'ID Proof',
                                  isUploaded: _idProofPath != null,
                                  onTap: () => _showUploadOptions('id'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── QUALIFICATION DETAILS ────────────────────────
                      _buildSectionHeader(
                        title: 'Qualification Details',
                        icon: Icons.school_outlined,
                      ),
                      const SizedBox(height: 10),
                      _buildCardContainer(
                        children: [
                          _buildLabeledField(
                            label: 'Qualification',
                            child: TextFormField(
                              controller: _qualificationController,
                              maxLines: 2,
                              style: _inputStyle,
                              decoration: _inputDecor(
                                'Enter qualification (e.g., Certified Personal Trainer)',
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildLabeledField(
                            label: 'Upload Certification',
                            child: _DashedUploadBox(
                              icon: Icons.cloud_upload_outlined,
                              label: 'Upload File',
                              isUploaded: _certificatePhotoPath != null,
                              height: 72,
                              onTap: () => _showUploadOptions('certificate'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── PROFESSIONAL DETAILS ─────────────────────────
                      _buildSectionHeader(
                        title: 'Professional Details',
                        icon: Icons.work_outline,
                      ),
                      const SizedBox(height: 10),
                      _buildCardContainer(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildLabeledField(
                                  label: 'Experience',
                                  child: TextFormField(
                                    controller: _experienceController,
                                    style: _inputStyle,
                                    decoration: _inputDecor('e.g. 5 Years'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildLabeledField(
                                  label: 'Shift start',
                                  child: TextFormField(
                                    controller: _shiftStartController,
                                    readOnly: true,
                                    style: _inputStyle,
                                    onTap: () =>
                                        _pickTime(_shiftStartController),
                                    decoration: _inputDecor('09:00 AM'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildLabeledField(
                                  label: 'Shift end',
                                  child: TextFormField(
                                    controller: _shiftEndController,
                                    readOnly: true,
                                    style: _inputStyle,
                                    onTap: () => _pickTime(_shiftEndController),
                                    decoration: _inputDecor('05:00 PM'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildLabeledField(
                            label: 'Joining Date',
                            child: TextFormField(
                              controller: _joiningDateController,
                              readOnly: true,
                              onTap: () => _pickDate(_joiningDateController),
                              style: _inputStyle,
                              decoration: _inputDecor('mm/dd/yyyy'),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildLabeledField(
                            label: 'Base Salary',
                            child: TextFormField(
                              controller: _salaryController,
                              keyboardType: TextInputType.number,
                              style: _inputStyle,
                              decoration: _inputDecor('3,500'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── SAVE BUTTON ──────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF054446),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isSubmitting ? null : _handleSubmit,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Update Trainer Profile',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HELPERS ─────────────────────────────────────────────────────────────

  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1D2939),
          ),
        ),
        Icon(icon, size: 20, color: const Color(0xFF475467)),
      ],
    );
  }

  Widget _buildCardContainer({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildLabeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF344054),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  static const TextStyle _inputStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    color: Color(0xFF101828),
  );

  InputDecoration _inputDecor(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        color: Color(0xFF98A2B3),
      ),
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF054446), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
    );
  }
}

// ── DASHED UPLOAD BOX ──────────────────────────────────────────────────────

class _DashedUploadBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isUploaded;
  final double height;
  final VoidCallback onTap;

  const _DashedUploadBox({
    required this.icon,
    required this.label,
    required this.isUploaded,
    this.height = 68,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(
        color: isUploaded ? AppColors.accentGreen : const Color(0xFFB2DDDD),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: height,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isUploaded
                ? AppColors.accentGreen.withValues(alpha: 0.05)
                : const Color(0xFFF9FCFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isUploaded ? Icons.check_circle_outline : icon,
                size: 22,
                color: isUploaded
                    ? AppColors.accentGreen
                    : const Color(0xFF008080),
              ),
              const SizedBox(height: 4),
              Text(
                isUploaded ? 'File Attached' : label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isUploaded
                      ? AppColors.accentGreen
                      : const Color(0xFF475467),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;

  static const double _strokeWidth = 1.2;
  static const double _gap = 4.0;
  static const double _dash = 6.0;

  const _DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + _dash),
          Offset.zero,
        );
        distance += _dash + _gap;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
