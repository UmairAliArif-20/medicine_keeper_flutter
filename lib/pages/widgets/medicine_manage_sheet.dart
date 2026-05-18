import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/medicine_database.dart';
import '../../services/medicine_notifications.dart';
import '../medicine_form_page.dart';

class MedicineManageSheet extends StatefulWidget {
  const MedicineManageSheet({
    super.key,
    required this.fontSize,
    required this.database,
    required this.medicines,
    required this.onChanged,
  });

  final double fontSize;
  final MedicineDatabase database;
  final List<Map<String, dynamic>> medicines;
  final VoidCallback onChanged;

  @override
  State<MedicineManageSheet> createState() => _MedicineManageSheetState();
}

class _MedicineManageSheetState extends State<MedicineManageSheet> {
  Future<void> _editMedicine(int index) async {
    Map<String, dynamic> existing = widget.medicines[index];
    Map<String, dynamic>? updated = await Navigator.of(context).push(
      MaterialPageRoute<Map<String, dynamic>>(
        builder: (_) => MedicineFormPage(
          fontSize: widget.fontSize,
          database: widget.database,
          existingMedicine: existing,
          ownerEmail: existing['ownerEmail'] as String?,
        ),
      ),
    );
    if (updated != null) {
      setState(() => widget.medicines[index] = updated);
      widget.onChanged();
      await MedicineNotifications.instance.scheduleOrUpdateForMedicine(updated);
    }
  }

  Future<void> _deleteMedicine(int index) async {
    int? id = widget.medicines[index]['id'] as int?;
    if (id != null) {
      await widget.database.deleteMedicine(id);
      await MedicineNotifications.instance.cancelById(id);
      setState(() => widget.medicines.removeAt(index));
      widget.onChanged();
    }
  }

  Future<void> _toggleTaken(int index, bool isTaken) async {
    int? id = widget.medicines[index]['id'] as int?;
    if (id != null) {
      await widget.database.setMedicineTaken(id, isTaken);
      setState(() => widget.medicines[index]['isTaken'] = isTaken);
      widget.onChanged();
    }
  }

  TimeOfDay _minutesToTime(int minutes) {
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  String _formatTime(BuildContext context, int minutes) {
    return _minutesToTime(minutes).format(context);
  }

  @override
  Widget build(BuildContext context) {
    double maxHeight = MediaQuery.of(context).size.height * 0.75;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.medication, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Medicines',
                  style: TextStyle(
                    fontSize: widget.fontSize + 4,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: widget.medicines.isEmpty
                  ? Center(
                      child: Text(
                        'No medicines yet.',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.separated(
                      itemCount: widget.medicines.length,
                      separatorBuilder: (context, index) =>
                          Divider(color: scheme.outlineVariant),
                      itemBuilder: _buildMedicineTile,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineTile(BuildContext context, int index) {
    Map<String, dynamic> medicine = widget.medicines[index];
    String name = medicine['name'] as String;
    int timeMinutes = medicine['timeMinutes'] as int;
    bool isTaken = medicine['isTaken'] as bool;
    String? imagePath = medicine['imagePath'] as String?;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _medicineImage(imagePath),
      title: Text(name, style: TextStyle(fontSize: widget.fontSize)),
      subtitle: Text(
        'Time: ${_formatTime(context, timeMinutes)}',
        style: TextStyle(
          fontSize: widget.fontSize - 2,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Checkbox(
            value: isTaken,
            onChanged: (value) {
              _toggleTaken(index, value ?? false);
            },
          ),
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit),
            onPressed: () => _editMedicine(index),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteMedicine(index),
          ),
        ],
      ),
    );
  }

  Widget _medicineImage(String? imagePath) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.medication, color: scheme.primary),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(imagePath),
        width: 48,
        height: 48,
        fit: BoxFit.cover,
      ),
    );
  }
}
