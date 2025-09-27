import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trash_provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/app_colors.dart';
import '../../models/trash_report_model.dart';
import '../profile_screen.dart';

class DealerDashboardScreen extends StatefulWidget {
  const DealerDashboardScreen({super.key});

  @override
  State<DealerDashboardScreen> createState() => _DealerDashboardScreenState();
}

class _DealerDashboardScreenState extends State<DealerDashboardScreen> {
  int _currentIndex = 0;
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final trashProvider = Provider.of<TrashProvider>(context, listen: false);
    
    await trashProvider.fetchTrashReports(status: TrashStatus.collected);
    
    setState(() {
      _statistics = {
        'collectedReports': trashProvider.trashReports.where((r) => r.status == TrashStatus.collected).length,
        'processedReports': trashProvider.trashReports.where((r) => r.status == TrashStatus.processed).length,
        'totalValue': trashProvider.trashReports
            .where((r) => r.actualValue != null)
            .fold(0.0, (sum, r) => sum + r.actualValue!),
        'platformEarnings': trashProvider.trashReports
            .where((r) => r.payment != null)
            .fold(0.0, (sum, r) => sum + r.payment!.platformFee),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          _buildCollectedTrashTab(),
          _buildProcessedTab(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.dealerColor,
        unselectedItemColor: AppColors.textLight,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Collected'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Processed'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
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
              _buildRecentItems(),
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
              backgroundColor: AppColors.dealerColor.withOpacity(0.1),
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'D',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dealerColor,
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
                    user?.name ?? 'Dealer',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
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
            'To Process',
            '${_statistics['collectedReports'] ?? 0}',
            Icons.inventory,
            AppColors.warning,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Processed',
            '${_statistics['processedReports'] ?? 0}',
            Icons.check_circle,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Value',
            '\$${(_statistics['totalValue'] ?? 0.0).toStringAsFixed(2)}',
            Icons.attach_money,
            AppColors.info,
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
                'Process Trash',
                'Review collected items',
                Icons.inventory,
                AppColors.dealerColor,
                () => setState(() => _currentIndex = 1),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                'View Processed',
                'Check completed items',
                Icons.check_circle,
                AppColors.success,
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

  Widget _buildRecentItems() {
    return Consumer<TrashProvider>(
      builder: (context, trashProvider, child) {
        final recentItems = trashProvider.trashReports
            .where((r) => r.status == TrashStatus.collected)
            .take(3)
            .toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Collections',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (recentItems.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() => _currentIndex = 1),
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentItems.isEmpty)
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
                      Icons.inventory_outlined,
                      size: 48,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No items to process',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Collected items will appear here',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...recentItems.map((item) => _buildItemCard(item)),
          ],
        );
      },
    );
  }

  Widget _buildItemCard(TrashReportModel report) {
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
              color: AppColors.dealerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.inventory,
              color: AppColors.dealerColor,
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
                  'Collected by ${report.collectorName ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
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
    );
  }

  Widget _buildCollectedTrashTab() {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Text(
                  'Collected Trash',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  color: AppColors.dealerColor,
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<TrashProvider>(
              builder: (context, trashProvider, child) {
                final collectedItems = trashProvider.trashReports
                    .where((r) => r.status == TrashStatus.collected)
                    .toList();

                if (trashProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.dealerColor),
                    ),
                  );
                }

                if (collectedItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_outlined,
                          size: 64,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No collected items',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Items will appear here when collected',
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
                    itemCount: collectedItems.length,
                    itemBuilder: (context, index) {
                      return _buildCollectedItemCard(collectedItems[index]);
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

  Widget _buildCollectedItemCard(TrashReportModel report) {
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
                  color: AppColors.dealerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.trashType.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.dealerColor,
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
          Text(
            'Collected by: ${report.collectorName ?? 'Unknown'}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
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
              onPressed: () => _showProcessDialog(report),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dealerColor,
              ),
              child: const Text('Process & Set Value'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessedTab() {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Text(
                  'Processed Items',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  color: AppColors.dealerColor,
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<TrashProvider>(
              builder: (context, trashProvider, child) {
                final processedItems = trashProvider.trashReports
                    .where((r) => r.status == TrashStatus.processed || r.status == TrashStatus.paid)
                    .toList();

                if (processedItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No processed items',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24.0),
                  itemCount: processedItems.length,
                  itemBuilder: (context, index) {
                    return _buildProcessedItemCard(processedItems[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessedItemCard(TrashReportModel report) {
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
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.status.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.dealerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.trashType.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.dealerColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (report.actualValue != null)
            Text(
              'Processed Value: \$${report.actualValue!.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
          const SizedBox(height: 8),
          if (report.payment != null) ...[
            Text(
              'Payment Distribution:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '• User (25%): \$${report.payment!.userAmount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '• Collector (65%): \$${report.payment!.collectorAmount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '• Platform (10%): \$${report.payment!.platformFee.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (report.status == TrashStatus.processed) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _processPayment(report),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
                child: const Text('Process Payment'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showProcessDialog(TrashReportModel report) {
    final valueController = TextEditingController(
      text: report.estimatedValue?.toStringAsFixed(2) ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Trash'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Set the actual value for this ${report.trashType.displayName} waste:'),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Actual Value (\$)',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(valueController.text);
              if (value != null && value > 0) {
                Navigator.of(context).pop();
                _processTrash(report, value);
              }
            },
            child: const Text('Process'),
          ),
        ],
      ),
    );
  }

  Future<void> _processTrash(TrashReportModel report, double actualValue) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final trashProvider = Provider.of<TrashProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    final success = await trashProvider.processTrash(
      report.id,
      authProvider.currentUser!.id,
      authProvider.currentUser!.name,
      actualValue,
    );

    if (success) {
      // Send notifications
      await notificationProvider.sendNotificationToUser(
        userId: report.userId,
        title: 'Trash Processed',
        body: 'Your trash has been processed. Value: \$${actualValue.toStringAsFixed(2)}',
        data: {
          'type': 'trash_processed',
          'reportId': report.id,
          'value': actualValue,
        },
      );

      if (report.collectorId != null) {
        await notificationProvider.sendNotificationToUser(
          userId: report.collectorId!,
          title: 'Trash Processed',
          body: 'Collected trash has been processed. Value: \$${actualValue.toStringAsFixed(2)}',
          data: {
            'type': 'trash_processed',
            'reportId': report.id,
            'value': actualValue,
          },
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trash processed successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to process trash'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _processPayment(TrashReportModel report) async {
    if (report.actualValue == null) return;

    final trashProvider = Provider.of<TrashProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    final success = await trashProvider.processPayment(report.id, report.actualValue!);

    if (success) {
      // Calculate payment amounts
      final userAmount = report.actualValue! * 0.25;
      final collectorAmount = report.actualValue! * 0.65;

      // Send payment notifications
      await notificationProvider.sendNotificationToUser(
        userId: report.userId,
        title: 'Payment Received',
        body: 'You have received \$${userAmount.toStringAsFixed(2)} for your contribution',
        data: {
          'type': 'payment_received',
          'reportId': report.id,
          'amount': userAmount,
        },
      );

      if (report.collectorId != null) {
        await notificationProvider.sendNotificationToUser(
          userId: report.collectorId!,
          title: 'Payment Received',
          body: 'You have received \$${collectorAmount.toStringAsFixed(2)} for collection',
          data: {
            'type': 'payment_received',
            'reportId': report.id,
            'amount': collectorAmount,
          },
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment processed successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to process payment'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
