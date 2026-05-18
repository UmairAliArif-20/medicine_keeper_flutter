import 'package:flutter/material.dart';
import '../data/medicine_database.dart';
import '../services/medicine_notifications.dart';
import 'medicine_form_page.dart';
import 'widgets/current_medicines_card.dart';
import 'widgets/welcome_card.dart';
import 'widgets/stat_card.dart';
import 'widgets/reminder_card.dart';

// --- PAGE 2: HOME ---
class HomePage extends StatefulWidget {
  final double fontSize;
  final String? ownerEmail;
  const HomePage({super.key, required this.fontSize, required this.ownerEmail});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MedicineDatabase _database = MedicineDatabase.instance;
  final List<Map<String, dynamic>> _medicines = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ownerEmail != widget.ownerEmail) {
      _loadMedicines();
    }
  }

  Future<void> _loadMedicines() async {
    List<Map<String, dynamic>> loadedMedicines = await _database.getMedicines(
      ownerEmail: widget.ownerEmail,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _medicines
        ..clear()
        ..addAll(loadedMedicines);
    });

    await MedicineNotifications.instance.syncDailySchedules(_medicines);
  }

  Future<void> _toggleTaken(int index, bool isTaken) async {
    int? id = _medicines[index]['id'] as int?;
    if (id != null) {
      setState(() {
        _medicines[index]['isTaken'] = isTaken;
      });
      await _database.setMedicineTaken(id, isTaken);
      await _loadMedicines();
    }
  }

  Future<void> _deleteMedicine(int index) async {
    int? id = _medicines[index]['id'] as int?;
    if (id != null) {
      await _database.deleteMedicine(id);
      await _loadMedicines();
    }
  }

  Future<void> _openAddMedicinePage() async {
    Map<String, dynamic>? savedMedicine = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MedicineFormPage(
          fontSize: widget.fontSize,
          database: _database,
          ownerEmail: widget.ownerEmail,
        ),
      ),
    );

    if (savedMedicine != null) {
      await _loadMedicines();
    }
  }

  Future<void> _openEditMedicinePage(int index) async {
    Map<String, dynamic> existingMedicine = _medicines[index];
    Map<String, dynamic>? updatedMedicine = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MedicineFormPage(
          fontSize: widget.fontSize,
          database: _database,
          existingMedicine: existingMedicine,
          ownerEmail: widget.ownerEmail,
        ),
      ),
    );

    if (updatedMedicine != null) {
      await _loadMedicines();
    }
  }

  TimeOfDay _minutesToTime(int minutes) {
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  String _formatTime(BuildContext context, int minutes) {
    return _minutesToTime(minutes).format(context);
  }

  Map<String, dynamic> _getSummary(BuildContext context) {
    int dueCount = 0;
    int takenCount = 0;
    Map<String, dynamic>? nextReminder;

    for (Map<String, dynamic> medicine in _medicines) {
      if (medicine['isTaken'] == true) {
        takenCount++;
      } else {
        dueCount++;
        if (nextReminder == null ||
            (medicine['timeMinutes'] as int) <
                (nextReminder['timeMinutes'] as int)) {
          nextReminder = medicine;
        }
      }
    }

    String reminderMessage = 'No upcoming reminders yet.';
    if (nextReminder != null) {
      int timeMinutes = nextReminder['timeMinutes'] as int;
      String name = nextReminder['name'] as String;
      reminderMessage =
          'Next reminder at ${_formatTime(context, timeMinutes)} for $name.';
    }

    return <String, dynamic>{
      'dueCount': dueCount,
      'takenCount': takenCount,
      'reminderMessage': reminderMessage,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    Map<String, dynamic> summary = _getSummary(context);
    final TextStyle headingStyle = TextStyle(
      fontSize: widget.fontSize + 6,
      fontWeight: FontWeight.bold,
      color: scheme.primary,
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WelcomeCard(fontSize: widget.fontSize),
                  const SizedBox(height: 20),
                  Text('Today', style: headingStyle),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      StatCard(
                        label: 'Due',
                        value: summary['dueCount'].toString(),
                        color: scheme.primary,
                        fontSize: widget.fontSize,
                      ),
                      const SizedBox(width: 12),
                      StatCard(
                        label: 'Taken',
                        value: summary['takenCount'].toString(),
                        color: scheme.secondary,
                        fontSize: widget.fontSize,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ReminderCard(
                    message: summary['reminderMessage'] as String,
                    fontSize: widget.fontSize,
                  ),
                  const SizedBox(height: 24),
                  Text('Current Medications', style: headingStyle),
                  const SizedBox(height: 12),
                  CurrentMedicinesCard(
                    fontSize: widget.fontSize,
                    medicines: _medicines,
                    onToggleTaken: _toggleTaken,
                    onEdit: _openEditMedicinePage,
                    onDelete: _deleteMedicine,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openAddMedicinePage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add),
              label: Text(
                'Add Medicine',
                style: TextStyle(fontSize: widget.fontSize),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
