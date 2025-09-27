import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../models/user_model.dart';
import 'auth/user_type_selection_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.currentUser;
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildHeader(context, user),
                  const SizedBox(height: 30),
                  _buildStatsCards(user),
                  const SizedBox(height: 30),
                  _buildProfileOptions(context, authProvider),
                  const SizedBox(height: 30),
                  _buildLogoutButton(context, authProvider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user) {
    Color userTypeColor;
    switch (user.userType) {
      case UserType.user:
        userTypeColor = AppColors.userColor;
        break;
      case UserType.collectionWorker:
        userTypeColor = AppColors.collectorColor;
        break;
      case UserType.dealer:
        userTypeColor = AppColors.dealerColor;
        break;
    }

    return Column(
      children: [
        // Profile Picture
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: userTypeColor.withOpacity(0.1),
              child: user.profileImage != null
                  ? ClipOval(
                      child: Image.network(
                        user.profileImage!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar(user, userTypeColor);
                        },
                      ),
                    )
                  : _buildDefaultAvatar(user, userTypeColor),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: userTypeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Name and User Type
        Text(
          user.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: userTypeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            user.userType.displayName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: userTypeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user.email,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(UserModel user, Color color) {
    return Text(
      user.name.substring(0, 1).toUpperCase(),
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildStatsCards(UserModel user) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Earnings',
            '\$${(user.totalEarnings ?? 0.0).toStringAsFixed(2)}',
            Icons.attach_money,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Completed Tasks',
            '${user.completedTasks ?? 0}',
            Icons.task_alt,
            AppColors.info,
          ),
        ),
        if (user.rating != null) ...[
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Rating',
              '${user.rating!.toStringAsFixed(1)} ⭐',
              Icons.star,
              AppColors.warning,
            ),
          ),
        ],
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context, AuthProvider authProvider) {
    return Column(
      children: [
        _buildOptionTile(
          context,
          'Edit Profile',
          'Update your personal information',
          Icons.edit,
          () => _showEditProfileDialog(context, authProvider),
        ),
        _buildOptionTile(
          context,
          'Notifications',
          'Manage notification preferences',
          Icons.notifications,
          () => _showNotificationSettings(context),
        ),
        _buildOptionTile(
          context,
          'Payment History',
          'View your payment transactions',
          Icons.payment,
          () => _showPaymentHistory(context),
        ),
        _buildOptionTile(
          context,
          'Help & Support',
          'Get help and contact support',
          Icons.help,
          () => _showHelpSupport(context),
        ),
        _buildOptionTile(
          context,
          'About',
          'App version and information',
          Icons.info,
          () => _showAboutDialog(context),
        ),
      ],
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textLight,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () => _handleLogout(context, authProvider),
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser!;
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
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
              final updatedUser = user.copyWith(
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
              );
              authProvider.updateProfile(updatedUser);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Push Notifications'),
              subtitle: Text('Receive notifications about your reports'),
              value: true,
              onChanged: null, // Would be implemented in a real app
            ),
            SwitchListTile(
              title: Text('Email Notifications'),
              subtitle: Text('Receive email updates'),
              value: false,
              onChanged: null, // Would be implemented in a real app
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPaymentHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment History'),
        content: const Text('Payment history feature would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact us:'),
            SizedBox(height: 16),
            Text('📧 support@zigwa.com'),
            Text('📞 +1 (555) 123-4567'),
            Text('🌐 www.zigwa.com/help'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Zigwa',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.recycling,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: const [
        Text('Smart Waste Management Platform'),
        SizedBox(height: 16),
        Text('Join the circular economy revolution and help make the world cleaner, one report at a time.'),
      ],
    );
  }

  void _handleLogout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const UserTypeSelectionScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
