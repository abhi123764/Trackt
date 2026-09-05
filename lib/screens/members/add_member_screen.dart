import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/validators.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  // File Upload Paths
  String? _profilePhotoPath;
  String? _idProofPath;
  String? _medicalReportsPath;

  // Personal Details
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  String? _gender;
  String? _bloodGroup;

  // Health & Fitness
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _bmiController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _dietPreferencesController = TextEditingController();
  String? _activityLevel;
  String? _fitnessGoal;
  String? _emotionalHealth;

  // Membership Details
  final _preferredTimeController = TextEditingController();
  int? _selectedPlanId;
  int? _selectedTrainerId;

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
  static const _activityLevels = [
    'Sedentary',
    'Light',
    'Moderate',
    'Active',
    'Very Active',
  ];
  static const _fitnessGoals = [
    'Weight Loss',
    'Muscle Gain',
    'Endurance',
    'Flexibility',
    'General Fitness',
    'Rehabilitation',
  ];
  static const _emotionalHealthOptions = [
    'Excellent',
    'Good',
    'Moderate',
    'Poor',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProvider>().fetchMembers();
    });
    // Auto-calculate BMI when height or weight changes
    _heightController.addListener(_calculateBmi);
    _weightController.addListener(_calculateBmi);
  }

  void _calculateBmi() {
    final h = double.tryParse(_heightController.text);
    final w = double.tryParse(_weightController.text);
    if (h != null && w != null && h > 0) {
      final hm = h / 100;
      final bmi = w / (hm * hm);
      _bmiController.text = bmi.toStringAsFixed(1);
    } else {
      _bmiController.text = '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    _bmiController.dispose();
    _medicalConditionsController.dispose();
    _dietPreferencesController.dispose();
    _preferredTimeController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<MemberProvider>();
    final success = await provider.addMember(
      name: _nameController.text,
      mobileNumber: _mobileController.text,
      email: _emailController.text.trim(),
      gender: _gender,
      bloodGroup: _bloodGroup,
      dob: _dobController.text.trim(),
      address: _addressController.text.trim(),
      profilePhotoPath: _profilePhotoPath,
      idProofPath: _idProofPath,
      medicalReportsPath: _medicalReportsPath,
      height: _heightController.text.trim(),
      weight: _weightController.text.trim(),
      targetWeight: _targetWeightController.text.trim(),
      bmi: _bmiController.text.trim(),
      activityLevel: _activityLevel,
      fitnessGoal: _fitnessGoal,
      emotionalHealth: _emotionalHealth,
      medicalConditions: _medicalConditionsController.text.trim(),
      planId: _selectedPlanId,
      trainerId: _selectedTrainerId,
      preferredTime: _preferredTimeController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Member registered successfully!'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Failed to register member. Please try again.',
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
        (documentType == 'medical' && _medicalReportsPath != null);

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
                    if (documentType == 'medical') _medicalReportsPath = null;
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
          if (documentType == 'medical') _medicalReportsPath = image.path;
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
            if (documentType == 'medical') _medicalReportsPath = filePath;
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.tealPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    final initial = (currentUser != null && currentUser.fName.isNotEmpty)
        ? currentUser.fName[0].toUpperCase()
        : 'U';
    final membershipPlans = context.watch<MemberProvider>().membershipPlans;
    final trainers = context.watch<MemberProvider>().trainers;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP BAR ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
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
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Add Members',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
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

            // ── FORM ─────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── PERSONAL DETAILS ─────────────────────────────
                      _buildSectionCard(
                        label: 'PERSONAL DETAILS',
                        children: [
                          _buildField(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: _decor('Full Name'),
                              validator: (v) => AppValidators.validateRequired(
                                v,
                                'Full Name',
                              ),
                            ),
                          ),
                          _buildField(
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _gender,
                                    decoration: _decor('Gender'),
                                    items: _genders
                                        .map(
                                          (g) => DropdownMenuItem(
                                            value: g,
                                            child: Text(g),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _gender = v),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _bloodGroup,
                                    decoration: _decor('Blood Group'),
                                    items: _bloodGroups
                                        .map(
                                          (b) => DropdownMenuItem(
                                            value: b,
                                            child: Text(b),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _bloodGroup = v),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildField(
                            child: TextFormField(
                              controller: _dobController,
                              readOnly: true,
                              onTap: _pickDate,
                              decoration: _decor('Date of Birth').copyWith(
                                suffixIcon: const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          _buildField(
                            child: TextFormField(
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              decoration: _decor('Mobile Number'),
                              validator: AppValidators.validatePhone,
                            ),
                          ),
                          _buildField(
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _decor('Email Id'),
                              validator: (v) {
                                if (v != null && v.trim().isNotEmpty) {
                                  return AppValidators.validateEmail(v);
                                }
                                return null;
                              },
                            ),
                          ),
                          _buildField(
                            child: TextFormField(
                              controller: _addressController,
                              maxLines: 3,
                              decoration: _decor('Address'),
                            ),
                          ),

                          // Upload Buttons Row
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildUploadButton(
                                icon: Icons.camera_alt_outlined,
                                label: 'Upload Photo',
                                filePath: _profilePhotoPath,
                                onTap: () => _showUploadOptions('photo'),
                              ),
                              const SizedBox(width: 12),
                              _buildUploadButton(
                                icon: Icons.upload_outlined,
                                label: 'Upload ID Proof',
                                filePath: _idProofPath,
                                onTap: () => _showUploadOptions('id'),
                              ),
                              const SizedBox(width: 12),
                              _buildUploadButton(
                                icon: Icons.description_outlined,
                                label: 'Upload\nMedical Reports',
                                filePath: _medicalReportsPath,
                                onTap: () => _showUploadOptions('medical'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── HEALTH & FITNESS ─────────────────────────────
                      _buildSectionCard(
                        label: 'HEALTH & FITNESS',
                        children: [
                          _buildField(
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _heightController,
                                    keyboardType: TextInputType.number,
                                    decoration: _decor('Height (cm)'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _weightController,
                                    keyboardType: TextInputType.number,
                                    decoration: _decor('Current Weight'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildField(
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _targetWeightController,
                                    keyboardType: TextInputType.number,
                                    decoration: _decor('Target Weight'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _bmiController,
                                    readOnly: true,
                                    decoration: _decor('BMI').copyWith(
                                      fillColor: const Color(0xFFF8FAFC),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildField(
                            child: DropdownButtonFormField<String>(
                              initialValue: _activityLevel,
                              decoration: _decor('Activity Level'),
                              items: _activityLevels
                                  .map(
                                    (a) => DropdownMenuItem(
                                      value: a,
                                      child: Text(a),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _activityLevel = v),
                            ),
                          ),
                          _buildField(
                            child: DropdownButtonFormField<String>(
                              initialValue: _fitnessGoal,
                              decoration: _decor('Fitness Goals'),
                              items: _fitnessGoals
                                  .map(
                                    (f) => DropdownMenuItem(
                                      value: f,
                                      child: Text(f),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _fitnessGoal = v),
                            ),
                          ),
                          _buildField(
                            child: DropdownButtonFormField<String>(
                              initialValue: _emotionalHealth,
                              decoration: _decor('Emotional Health'),
                              items: _emotionalHealthOptions
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _emotionalHealth = v),
                            ),
                          ),
                          _buildField(
                            child: TextFormField(
                              controller: _medicalConditionsController,
                              maxLines: 3,
                              decoration: _decor(
                                'Medical Conditions / Diseases',
                              ),
                            ),
                          ),
                          _buildField(
                            child: TextFormField(
                              controller: _dietPreferencesController,
                              maxLines: 3,
                              decoration: _decor('Diet Preferences'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── MEMBERSHIP DETAILS ───────────────────────────
                      _buildSectionCard(
                        label: 'MEMBERSHIP DETAILS',
                        children: [
                          _buildField(
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<int?>(
                                    initialValue: _selectedPlanId,
                                    decoration: _decor('Plan'),
                                    isExpanded: true,
                                    items: [
                                      const DropdownMenuItem<int?>(
                                        value: null,
                                        child: Text(
                                          'Select Plan',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      ...membershipPlans.map((plan) {
                                        return DropdownMenuItem<int?>(
                                          value: plan.id,
                                          child: Text(
                                            plan.name,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }),
                                    ],
                                    onChanged: (v) =>
                                        setState(() => _selectedPlanId = v),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<int?>(
                                    initialValue: _selectedTrainerId,
                                    decoration: _decor('Trainer'),
                                    isExpanded: true,
                                    items: [
                                      const DropdownMenuItem<int?>(
                                        value: null,
                                        child: Text(
                                          'None',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      ...trainers.map((t) {
                                        return DropdownMenuItem<int?>(
                                          value: t.id,
                                          child: Text(
                                            t.name,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }),
                                    ],
                                    onChanged: (v) =>
                                        setState(() => _selectedTrainerId = v),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildField(
                            child: TextFormField(
                              controller: _preferredTimeController,
                              decoration: _decor('Preferred Time').copyWith(
                                suffixIcon: const Icon(
                                  Icons.access_time_outlined,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              readOnly: true,
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                  builder: (ctx, child) => Theme(
                                    data: Theme.of(ctx).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: AppColors.tealPrimary,
                                      ),
                                    ),
                                    child: child!,
                                  ),
                                );
                                if (picked != null && mounted) {
                                  setState(() {
                                    _preferredTimeController.text = picked
                                        .format(context);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // ── CONFIRM BUTTON ───────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF054446),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _isSubmitting ? null : _handleSubmit,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.person_add_alt_1, size: 22),
                          label: Text(
                            _isSubmitting
                                ? 'Registering...'
                                : 'Confirm Member Registration',
                            style: const TextStyle(
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

  // ── HELPER WIDGETS ─────────────────────────────────────────────────────────

  Widget _buildSectionCard({
    required String label,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Color(0xFF98A2B3),
              ),
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildField({required Widget child}) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: child);
  }

  InputDecoration _decor(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13.5,
        color: Color(0xFF98A2B3),
      ),
      filled: true,
      fillColor: const Color(0xFFFCFCFD),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.tealPrimary, width: 1.5),
      ),
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required String? filePath,
    required VoidCallback onTap,
  }) {
    final bool isUploaded = filePath != null && filePath.isNotEmpty;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isUploaded
                ? AppColors.accentGreen.withValues(alpha: 0.1)
                : AppColors.tealPrimary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUploaded
                  ? AppColors.accentGreen
                  : AppColors.tealPrimary.withValues(alpha: 0.2),
              width: isUploaded ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isUploaded ? Icons.check_circle_rounded : icon,
                color: isUploaded
                    ? AppColors.accentGreen
                    : AppColors.tealPrimary,
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                isUploaded ? 'Attached' : label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: isUploaded ? FontWeight.w700 : FontWeight.w500,
                  color: isUploaded
                      ? AppColors.accentGreen
                      : AppColors.tealPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
