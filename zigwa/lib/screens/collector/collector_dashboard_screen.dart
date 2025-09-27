import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trash_provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/app_colors.dart';
import '../../models/trash_report_model.dart';
import '../../services/notification_service.dart';
import '../profile_screen.dart';

class CollectorDashboardScreen extends StatefulWidget {
  const CollectorDashboardScreen({super.key});

  @override
  State<CollectorDashboardScreen> createState() => _CollectorDashboardScreenState();
}

class _CollectorDashboardScreenState extends State<CollectorDashboardScreen> {
  int _currentIndex = 0;
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final trashProvider = Provider.of<TrashProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      await trashProvider.fetchTrashReports(status: TrashStatus.reported);
      await trashProvider.fetchAssignedReports(authProvider.currentUser!.id);
      
      setState(() {
        _statistics = {
          'availableReports': trashProvider.trashReports.where((r) => r.status == TrashStatus.reported).length,
          'assignedReports': trashProvider.assignedReports.length,
          'completedReports': trashProvider.assignedReports.where((r) => r.status == TrashStatus.paid).length,
          'totalEarnings': trashProvider.assignedReports
              .where((r) => r.payment != null)
              .fold(0.0, (sum, r) => sum + r.payment!.collectorAmount),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          _buildAvailableReportsTab(),
          _buildMyTasksTab(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.collectorColor,
        unselectedItemColor: AppColors.textLight,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Available',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'My Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildStatisticsCards(),
              const SizedBox(height: 30),
              _buildQuickActions(),
              const SizedBox(height: 30),
              _buildRecentTasks(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        return Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.collectorColor.withOpacity(0.1),
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'C',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.collectorColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    user?.name ?? 'Collector',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Consumer<NotificationProvider>(
              builder: (context, notificationProvider, child) {
                return Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        // Show notifications
                      },
                      icon: const Icon(Icons.notifications_outlined),
                      color: AppColors.textSecondary,
                    ),
                    if (notificationProvider.unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${notificationProvider.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatisticsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Available',
            '${_statistics['availableReports'] ?? 0}',
            Icons.report,
            AppColors.info,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Assigned',
            '${_statistics['assignedReports'] ?? 0}',
            Icons.assignment,
            AppColors.warning,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Earnings',
            '\$${(_statistics['totalEarnings'] ?? 0.0).toStringAsFixed(2)}',
            Icons.attach_money,
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'View Available',
                'See new trash reports',
                Icons.list,
                AppColors.collectorColor,
                () => setState(() => _currentIndex = 1),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                'My Tasks',
                'Manage assigned tasks',
                Icons.assignment,
                AppColors.info,
                () => setState(() => _currentIndex = 2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTasks() {
    return Consumer<TrashProvider>(
      builder: (context, trashProvider, child) {
        final recentTasks = trashProvider.assignedReports.take(3).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Tasks',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (recentTasks.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() => _currentIndex = 2),
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentTasks.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 48,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No assigned tasks yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check available reports to start collecting',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...recentTasks.map((task) => _buildTaskCard(task)),
          ],
        );
      },
    );
  }

  Widget _buildTaskCard(TrashReportModel report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getStatusColor(report.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(report.status),
              color: _getStatusColor(report.status),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.trashType.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  report.location.address,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  report.status.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(report.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (report.estimatedValue != null)
            Text(
              '\$${report.estimatedValue!.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvailableReportsTab() {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Text(
                  'Available Reports',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  color: AppColors.collectorColor,
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<TrashProvider>(
              builder: (context, trashProvider, child) {
                final availableReports = trashProvider.trashReports
                    .where((r) => r.status == TrashStatus.reported)
                    .toList();

                if (trashProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.collectorColor),
                    ),
                  );
                }

                if (availableReports.isEmpty) {
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
                          'No available reports',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check back later for new trash reports',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24.0),
                    itemCount: availableReports.length,
                    itemBuilder: (context, index) {
                      return _buildAvailableReportCard(availableReports[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableReportCard(TrashReportModel report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.collectorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.trashType.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.collectorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (report.estimatedValue != null)
                Text(
                  'Est. \$${report.estimatedValue!.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
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
          Text(
            report.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _assignTask(report),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.collectorColor,
              ),
              child: const Text('Accept Task'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyTasksTab() {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Text(
                  'My Tasks',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  color: AppColors.collectorColor,
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<TrashProvider>(
              builder: (context, trashProvider, child) {
                final myTasks = trashProvider.assignedReports;

                if (trashProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.collectorColor),
                    ),
                  );
                }

                if (myTasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No assigned tasks',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Accept tasks from available reports',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24.0),
                    itemCount: myTasks.length,
                    itemBuilder: (context, index) {
                      return _buildMyTaskCard(myTasks[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyTaskCard(TrashReportModel report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(report.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.status.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(report.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.collectorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.trashType.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.collectorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
          Text(
            report.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          if (report.status == TrashStatus.assigned)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _markAsCollected(report),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
                child: const Text('Mark as Collected'),
              ),
            ),
          if (report.payment != null)
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
                    'Earned: \$${report.payment!.collectorAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _assignTask(TrashReportModel report) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final trashProvider = Provider.of<TrashProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    final success = await trashProvider.assignTrashReport(
      report.id,
      authProvider.currentUser!.id,
      authProvider.currentUser!.name,
    );

    if (success) {
      // Send notification to user
      await notificationProvider.sendNotificationToUser(
        userId: report.userId,
        title: 'Task Assigned',
        body: 'Your trash report has been assigned to ${authProvider.currentUser!.name}',
        data: {
          'type': 'trash_assigned',
          'reportId': report.id,
          'collectorName': authProvider.currentUser!.name,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task assigned successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to assign task'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _markAsCollected(TrashReportModel report) async {
    final trashProvider = Provider.of<TrashProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    final success = await trashProvider.markAsCollected(report.id);

    if (success) {
      // Send notification to user
      await notificationProvider.sendNotificationToUser(
        userId: report.userId,
        title: 'Trash Collected',
        body: 'Your reported trash has been collected',
        data: {
          'type': 'trash_collected',
          'reportId': report.id,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marked as collected!'),
          backgroundColor: AppColors.success,
        ),
      );
      
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update status'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
