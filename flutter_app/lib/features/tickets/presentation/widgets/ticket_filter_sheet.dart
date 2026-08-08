import 'package:flutter/material.dart';

class TicketFilterSheet extends StatefulWidget {
  final String? initialStatus;
  final String? initialPriority;
  final Function(String? status, String? priority) onApply;

  const TicketFilterSheet({
    super.key,
    this.initialStatus,
    this.initialPriority,
    required this.onApply,
  });

  @override
  State<TicketFilterSheet> createState() => _TicketFilterSheetState();
}

class _TicketFilterSheetState extends State<TicketFilterSheet> {
  String? _selectedStatus;
  String? _selectedPriority;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _selectedPriority = widget.initialPriority;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Tickets',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Status', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildChoiceChip(
                'All',
                _selectedStatus == null,
                () => setState(() => _selectedStatus = null),
              ),
              _buildChoiceChip(
                'Open',
                _selectedStatus == 'open',
                () => setState(() => _selectedStatus = 'open'),
              ),
              _buildChoiceChip(
                'In Progress',
                _selectedStatus == 'in-progress',
                () => setState(() => _selectedStatus = 'in-progress'),
              ),
              _buildChoiceChip(
                'Review',
                _selectedStatus == 'pending-review',
                () => setState(() => _selectedStatus = 'pending-review'),
              ),
              _buildChoiceChip(
                'Completed',
                _selectedStatus == 'completed',
                () => setState(() => _selectedStatus = 'completed'),
              ),
              _buildChoiceChip(
                'Closed',
                _selectedStatus == 'closed',
                () => setState(() => _selectedStatus = 'closed'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Priority', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildChoiceChip(
                'All',
                _selectedPriority == null,
                () => setState(() => _selectedPriority = null),
              ),
              _buildChoiceChip(
                'High',
                _selectedPriority == 'high',
                () => setState(() => _selectedPriority = 'high'),
              ),
              _buildChoiceChip(
                'Medium',
                _selectedPriority == 'medium',
                () => setState(() => _selectedPriority = 'medium'),
              ),
              _buildChoiceChip(
                'Low',
                _selectedPriority == 'low',
                () => setState(() => _selectedPriority = 'low'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_selectedStatus, _selectedPriority);
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(
    String label,
    bool isSelected,
    VoidCallback onSelected,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
    );
  }
}
