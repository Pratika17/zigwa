import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trash_provider.dart';
import '../../utils/app_colors.dart';
import '../../models/trash_report_model.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  TrashStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final trashProvider = Provider.of<TrashProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      await trashProvider.fetchMyReports(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterChips(),
            Expanded(child: _buildReportsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Text(
            'My Reports',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _loadReports,
            icon: const Icon(Icons.refresh),
            color: AppColors.userColor,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All', null),
          const SizedBox(width: 12),
          _buildFilterChip('Reported', TrashStatus.reported),
          const SizedBox(width: 12),
          _buildFilterChip('Assigned', TrashStatus.assigned),
          const SizedBox(width: 12),
          _buildFilterChip('Collected', TrashStatus.collected),
          const SizedBox(width: 12),
          _buildFilterChip('Processed', TrashStatus.processed),
          const SizedBox(width: 12),
          _buildFilterChip('Paid', TrashStatus.paid),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, TrashStatus? status) {
    final isSelected = _selectedFilter == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? status : null;
        });
      },
      selectedColor: AppColors.userColor.withOpacity(0.2),
      checkmarkColor: AppColors.userColor,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.userColor : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildReportsList() {
    return Consumer<TrashProvider>(
      builder: (context, trashProvider, child) {
        if (trashProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.userColor),
            ),
          );
        }

        var reports = trashProvider.myReports;
        
        // Apply filter
        if (_selectedFilter != null) {
          reports = reports.where((report) => report.status == _selectedFilter).toList();
        }

        if (reports.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _loadReports,
          child: ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              return _buildReportCard(reports[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.report_outlined,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == null ? 'No reports yet' : 'No ${_selectedFilter!.displayName.toLowerCase()} reports',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == null 
                ? 'Start by reporting your first trash location'
                : 'Try changing the filter to see more reports',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(TrashReportModel report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(report.status).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(report.status),
                  color: _getStatusColor(report.status),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  report.status.displayName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: _getStatusColor(report.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM dd, yyyy').format(report.reportedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trash type and location
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.userColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        report.trashType.displayName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.userColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (report.estimatedValue != null)
                      Text(
                        'Est. \$${report.estimatedValue!.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Location
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        report.location.address,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Description
                Text(
                  report.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Progress indicators
                if (report.status != TrashStatus.reported) ...[
                  const SizedBox(height: 16),
                  _buildProgressIndicators(report),
                ],
                
                // Payment info
                if (report.payment != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Payment Received: \$${report.payment!.userAmount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicators(TrashReportModel report) {
    final steps = [
      {'status': TrashStatus.reported, 'label': 'Reported', 'icon': Icons.report},
      {'status': TrashStatus.assigned, 'label': 'Assigned', 'icon': Icons.assignment},
      {'status': TrashStatus.collected, 'label': 'Collected', 'icon': Icons.local_shipping},
      {'status': TrashStatus.processed, 'label': 'Processed', 'icon': Icons.settings},
      {'status': TrashStatus.paid, 'label': 'Paid', 'icon': Icons.check_circle},
    ];

    return Row(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final status = step['status'] as TrashStatus;
        final isCompleted = _isStatusCompleted(report.status, status);
        final isCurrent = report.status == status;

        return Expanded(
          child: Row(
            children: [
              // Step indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted || isCurrent 
                      ? _getStatusColor(status) 
                      : AppColors.greyLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  step['icon'] as IconData,
                  size: 12,
                  color: isCompleted || isCurrent ? Colors.white : AppColors.textLight,
                ),
              ),
              
              // Connector line (except for last item)
              if (index < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: _isStatusCompleted(report.status, steps[index + 1]['status'] as TrashStatus)
                        ? _getStatusColor(steps[index + 1]['status'] as TrashStatus)
                        : AppColors.greyLight,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  bool _isStatusCompleted(TrashStatus currentStatus, TrashStatus checkStatus) {
    final statusOrder = [
      TrashStatus.reported,
      TrashStatus.assigned,
      TrashStatus.collected,
      TrashStatus.processed,
      TrashStatus.paid,
    ];
    
    final currentIndex = statusOrder.indexOf(currentStatus);
    final checkIndex = statusOrder.indexOf(checkStatus);
    
    return currentIndex >= checkIndex;
  }

  Color _getStatusColor(TrashStatus status) {
    switch (status) {
      case TrashStatus.reported:
        return AppColors.warning;
      case TrashStatus.assigned:
        return AppColors.info;
      case TrashStatus.collected:
        return AppColors.primary;
      case TrashStatus.processed:
        return AppColors.secondary;
      case TrashStatus.paid:
        return AppColors.success;
    }
  }

  IconData _getStatusIcon(TrashStatus status) {
    switch (status) {
      case TrashStatus.reported:
        return Icons.report;
      case TrashStatus.assigned:
        return Icons.assignment;
      case TrashStatus.collected:
        return Icons.local_shipping;
      case TrashStatus.processed:
        return Icons.settings;
      case TrashStatus.paid:
        return Icons.check_circle;
    }
  }
}
