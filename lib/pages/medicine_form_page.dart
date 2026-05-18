import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/medicine_database.dart';
import '../services/medicine_notifications.dart';
import 'widgets/medicine_form_action_card.dart';
import 'widgets/medicine_form_fields_card.dart';
import 'widgets/medicine_form_header_card.dart';
import 'widgets/medicine_form_image_card.dart';

class MedicineFormPage extends StatefulWidget {
  const MedicineFormPage({
    super.key,
    required this.fontSize,
    required this.database,
    required this.ownerEmail,
    this.existingMedicine,
  });

  final double fontSize;
  final MedicineDatabase database;
  final String? ownerEmail;
  final Map<String, dynamic>? existingMedicine;

  @override
  State<MedicineFormPage> createState() => _MedicineFormPageState();
}

class _MedicineFormPageState extends State<MedicineFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  TimeOfDay? selectedTime;
  String? imagePath;

  @override
  void initState() {
    super.initState();
    if (widget.existingMedicine != null) {
      Map<String, dynamic> medicine = widget.existingMedicine!;
      _nameController.text = medicine['name'] as String;
      int minutes = medicine['timeMinutes'] as int;
      selectedTime = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
      imagePath = medicine['imagePath'] as String?;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isEditMode => widget.existingMedicine != null;

  Future<void> _pickImage(ImageSource source) async {
    XFile? pickedImage = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (!mounted || pickedImage == null) {
      return;
    }

    setState(() {
      imagePath = pickedImage.path;
    });
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (!mounted || pickedTime == null) {
      return;
    }

    setState(() {
      selectedTime = pickedTime;
    });
  }

  Future<void> _saveMedicine() async {
    String name = _nameController.text.trim();
    if (name.isEmpty || selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a name and time.')));
      return;
    }

    Map<String, dynamic> medicine = <String, dynamic>{
      'name': name,
      'timeMinutes': selectedTime!.hour * 60 + selectedTime!.minute,
      'isTaken': _isEditMode
          ? widget.existingMedicine!['isTaken'] as bool
          : false,
      'imagePath': imagePath,
      'ownerEmail': widget.existingMedicine?['ownerEmail'] ?? widget.ownerEmail,
    };

    if (_isEditMode) {
      medicine['id'] = widget.existingMedicine!['id'];
      await widget.database.updateMedicine(medicine);
    } else {
      medicine['id'] = await widget.database.addMedicine(medicine);
    }

    try {
      await MedicineNotifications.instance.scheduleOrUpdateForMedicine(medicine);
    } catch (error) {
      debugPrint('Failed to update notification for medicine: $error');
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(medicine);
  }

  String get _headerTitle {
    if (_isEditMode) {
      return 'Edit Medicine';
    }

    return 'Add Medicine';
  }

  String get _actionText {
    if (_isEditMode) {
      return 'Update';
    }

    return 'Save';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MedicineFormHeaderCard(
                    fontSize: widget.fontSize,
                    title: _headerTitle,
                    subtitle: 'Fill the details below and add a photo.',
                  ),
                  const SizedBox(height: 12),
                  MedicineFormImageCard(
                    fontSize: widget.fontSize,
                    imagePath: imagePath,
                    onSwipeUp: () => _pickImage(ImageSource.camera),
                    onSwipeDown: () => _pickImage(ImageSource.gallery),
                  ),
                  const SizedBox(height: 12),
                  MedicineFormFieldsCard(
                    fontSize: widget.fontSize,
                    nameController: _nameController,
                    selectedTime: selectedTime,
                    onPickTime: _pickTime,
                  ),
                  const SizedBox(height: 12),
                  MedicineFormActionCard(
                    fontSize: widget.fontSize,
                    buttonText: _actionText,
                    onPressed: _saveMedicine,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
