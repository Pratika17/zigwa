import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trash_provider.dart';
import '../../utils/app_colors.dart';
import '../../models/trash_report_model.dart';
import 'report_trash_screen.dart';
import 'my_reports_screen.dart';
import '../profile_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
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
      await trashProvider.fetchMyReports(authProvider.currentUser!.id);
      setState(() {
        _statistics = {
          'totalReports': trashProvider.myReports.length,
          'completedReports': trashProvider.myReports.where((r) => r.status == TrashStatus.paid).length,
          'totalEarnings': trashProvider.myReports
              .where((r) => r.payment != null)
              .fold(0.0, (sum, r) => sum + r.payment!.userAmount),
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
          const MyReportsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.userColor,
        unselectedItemColor: AppColors.textLight,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'My Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _navigateToReportTrash(),
              backgroundColor: AppColors.userColor,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Report Trash'),
            )
          : null,
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
              _buildRecentReports(),
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
              backgroundColor: AppColors.userColor.withOpacity(0.1),
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.userColor,
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
                    user?.name ?? 'User',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                // Notifications would be implemented here
              },
              icon: const Icon(Icons.notifications_outlined),
              color: AppColors.textSecondary,
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
            'Total Reports',
            '${_statistics['totalReports'] ?? 0}',
            Icons.report,
            AppColors.info,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Completed',
            '${_statistics['completedReports'] ?? 0}',
            Icons.check_circle,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Earnings',
            '\$${(_statistics['totalEarnings'] ?? 0.0).toStringAsFixed(2)}',
            Icons.attach_money,
            AppColors.warning,
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
                'Report Trash',
                'Take a photo and report waste',
                Icons.camera_alt,
                AppColors.userColor,
                () => _navigateToReportTrash(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                'My Reports',
                'View your trash reports',
                Icons.list_alt,
                AppColors.info,
                () => setState(() => _currentIndex = 1),
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

  Widget _buildRecentReports() {
    return Consumer<TrashProvider>(
      builder: (context, trashProvider, child) {
        final recentReports = trashProvider.myReports.take(3).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Reports',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (recentReports.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() => _currentIndex = 1),
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentReports.isEmpty)
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
                      Icons.report_outlined,
                      size: 48,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No reports yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start by reporting your first trash location',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...recentReports.map((report) => _buildReportCard(report)),
          ],
        );
      },
    );
  }

  Widget _buildReportCard(TrashReportModel report) {
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
          if (report.payment != null)
            Text(
              '\$${report.payment!.userAmount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
        ],
      ),
    );
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

  void _navigateToReportTrash() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ReportTrashScreen(),
      ),
    ).then((_) => _loadData());
  }
}
