import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final List<String> windDirections;
  final List<String> selectedDirections;
  final Function(List<String>) onApply;

  const FilterDialog({super.key, 
    required this.windDirections,
    required this.selectedDirections,
    required this.onApply,
  });

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late List<String> tempSelected;
  bool isApplied = false;

  @override
  void initState() {
    super.initState();
    tempSelected = List.from(widget.selectedDirections);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter by Wind Direction',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: widget.windDirections.length,
                  itemBuilder: (context, index) {
                    final direction = widget.windDirections[index];
                    final isSelected = tempSelected.contains(direction);
                    return CheckboxListTile(
                      title: Text(
                        direction,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      value: isSelected,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelected.add(direction);
                          } else {
                            tempSelected.remove(direction);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Border radius set to 10
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 50),
                ElevatedButton(
                  onPressed: () {
                    widget.onApply(tempSelected);
                    setState(() {
                      isApplied = true;
                    });
                    Future.delayed(const Duration(milliseconds: 500), () {
                      Navigator.pop(context);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isApplied
                        ? Colors.green
                        : Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
