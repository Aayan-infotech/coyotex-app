import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final List<String> windDirections;
  final List<String> selectedDirections;
  final Function(List<String>) onApply;

  FilterDialog({
    required this.windDirections,
    required this.selectedDirections,
    required this.onApply,
  });

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late List<String> tempSelected;

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
            Text(
              'Filter by Wind Direction',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
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
                        style: TextStyle(
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
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onApply(tempSelected);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Apply Filters',
                    style: TextStyle(fontSize: 14),
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
