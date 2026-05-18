import 'dart:io';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class CurrentMedicinesCard extends StatefulWidget {
  final double fontSize;
  final List<Map<String, dynamic>> medicines;
  final Function(int, bool) onToggleTaken;
  final Function(int) onDelete;

  const CurrentMedicinesCard({
    super.key,
    required this.fontSize,
    required this.medicines,
    required this.onToggleTaken,
    required this.onDelete,
  });

  @override
  State<CurrentMedicinesCard> createState() => _CurrentMedicinesCardState();
}

class _CurrentMedicinesCardState extends State<CurrentMedicinesCard> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(covariant CurrentMedicinesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset selection if the medicines list changes externally
    if (widget.medicines.length != oldWidget.medicines.length) {
      _selectedIndex = null;
    }
  }

  String _formatTime(BuildContext context, int minutes) {
    final time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    return time.format(context);
  }

  void _confirmDelete(BuildContext context) {
    if (_selectedIndex == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Medicine?"),
        content: Text(
          "Are you sure you want to remove '${widget.medicines[_selectedIndex!]['name']}'?",
          style: TextStyle(fontSize: widget.fontSize - 2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              widget.onDelete(_selectedIndex!);
              setState(() {
                _selectedIndex = null;
              });
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.medicines.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        ),
        child: Center(
          child: Text(
            'No medicines added yet.',
            style: TextStyle(
              fontSize: widget.fontSize,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              children: [
                const Icon(Icons.list_alt, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Your Medicines',
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                if (_selectedIndex != null)
                  IconButton(
                    tooltip: 'Delete selected',
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _confirmDelete(context),
                  )
                else
                  const SizedBox(height: 48), // Spacer height consistency
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.medicines.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: AppColors.primary.withOpacity(0.1),
            ),
            itemBuilder: (context, index) {
              final med = widget.medicines[index];
              final bool isTaken = med['isTaken'] ?? false;
              final String? imagePath = med['imagePath'];
              final bool isSelected = _selectedIndex == index;

              return ListTile(
                dense: true,
                selected: isSelected,
                selectedTileColor: AppColors.primary.withOpacity(0.05),
                onTap: () {
                  setState(() {
                    _selectedIndex = isSelected ? null : index;
                  });
                },
                leading: _buildImage(imagePath),
                title: Text(
                  med['name'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    decoration: isTaken ? TextDecoration.lineThrough : null,
                    color: isTaken ? AppColors.textSecondary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  _formatTime(context, med['timeMinutes'] ?? 0),
                  style: TextStyle(fontSize: widget.fontSize - 2),
                ),
                trailing: Checkbox(
                  activeColor: AppColors.primary,
                  value: isTaken,
                  onChanged: (val) => widget.onToggleTaken(index, val ?? false),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? imagePath) {
    Widget icon = const Icon(Icons.medication, color: AppColors.primary, size: 20);
    
    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            file,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => icon,
          ),
        );
      }
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: icon,
    );
  }
}
