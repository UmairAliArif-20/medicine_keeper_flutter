import 'dart:io';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class CurrentMedicinesCard extends StatefulWidget {
  final double fontSize;
  final List<Map<String, dynamic>> medicines;
  final Function(int, bool) onToggleTaken;
  final Function(int) onEdit;
  final Function(int) onDelete;

  const CurrentMedicinesCard({
    super.key,
    required this.fontSize,
    required this.medicines,
    required this.onToggleTaken,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<CurrentMedicinesCard> createState() => _CurrentMedicinesCardState();
}

class _CurrentMedicinesCardState extends State<CurrentMedicinesCard> {
  int? _selectedId;

  @override
  void didUpdateWidget(covariant CurrentMedicinesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedId == null) return;

    bool stillExists = widget.medicines.any(
      (med) => (med['id'] as int?) == _selectedId,
    );
    if (!stillExists) {
      _selectedId = null;
    }
  }

  String _formatTime(BuildContext context, int minutes) {
    final time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    return time.format(context);
  }

  int? _selectedIndex() {
    if (_selectedId == null) return null;

    int index = widget.medicines.indexWhere(
      (med) => (med['id'] as int?) == _selectedId,
    );
    return index == -1 ? null : index;
  }

  void _toggleSelection(int index) {
    int? id = widget.medicines[index]['id'] as int?;
    setState(() {
      if (id != null && _selectedId == id) {
        _selectedId = null;
      } else {
        _selectedId = id;
      }
    });
  }

  void _openEdit(int index) {
    widget.onEdit(index);
    setState(() {
      _selectedId = null;
    });
  }

  void _confirmDelete(BuildContext context, int index) {
    if (index < 0 || index >= widget.medicines.length) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Medicine?"),
        content: Text(
          "Are you sure you want to remove '${widget.medicines[index]['name']}'?",
          style: TextStyle(fontSize: widget.fontSize - 2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              widget.onDelete(index);
              setState(() {
                _selectedId = null;
              });
              Navigator.pop(context);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    if (widget.medicines.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Center(
          child: Text(
            'No medicines added yet.',
            style: TextStyle(
              fontSize: widget.fontSize,
              color: scheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    final int? selectedIndex = _selectedIndex();

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
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
                Icon(Icons.list_alt, color: scheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Your Medicines',
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (selectedIndex != null)
                  IconButton(
                    tooltip: 'Delete selected',
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => _confirmDelete(context, selectedIndex),
                  )
                else
                  const SizedBox(height: 48),
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
              color: scheme.outlineVariant,
            ),
            itemBuilder: (context, index) {
              final med = widget.medicines[index];
              final bool isTaken = med['isTaken'] ?? false;
              final String? imagePath = med['imagePath'];
              final bool isSelected = selectedIndex == index;

              return ListTile(
                dense: true,
                selected: isSelected,
                selectedTileColor: scheme.primary.withValues(alpha: 0.08),
                onTap: () {
                  widget.onToggleTaken(index, !isTaken);
                },
                onLongPress: null,
                leading: _buildImage(imagePath),
                title: Text(
                  med['name'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    decoration: isTaken ? TextDecoration.lineThrough : null,
                    color: isTaken ? scheme.onSurfaceVariant : scheme.onSurface,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  _formatTime(context, med['timeMinutes'] ?? 0),
                  style: TextStyle(
                    fontSize: widget.fontSize - 2,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleSelection(index),
                    ),
                    if (isSelected)
                      IconButton(
                        tooltip: 'Edit',
                        icon: Icon(Icons.edit, color: scheme.primary),
                        onPressed: () => _openEdit(index),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? imagePath) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    Widget icon = Icon(Icons.medication, color: scheme.primary, size: 20);

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
        color: scheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: icon,
    );
  }
}
