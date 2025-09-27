import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/user_model.dart';
import 'login_screen.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Header
              Text(
                'Welcome to Zigwa',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Text(
                'Choose your role to get started',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              
              // User Type Cards
              Expanded(
                child: Column(
                  children: [
                    _UserTypeCard(
                      userType: UserType.user,
                      title: 'User',
                      description: 'Report trash and earn rewards',
                      icon: Icons.person,
                      color: AppColors.userColor,
                      onTap: () => _navigateToLogin(context, UserType.user),
                    ),
                    const SizedBox(height: 20),
                    
                    _UserTypeCard(
                      userType: UserType.collectionWorker,
                      title: 'Collection Worker',
                      description: 'Collect trash and earn money',
                      icon: Icons.local_shipping,
                      color: AppColors.collectorColor,
                      onTap: () => _navigateToLogin(context, UserType.collectionWorker),
                    ),
                    const SizedBox(height: 20),
                    
                    _UserTypeCard(
                      userType: UserType.dealer,
                      title: 'Dealer',
                      description: 'Process waste and manage payments',
                      icon: Icons.business,
                      color: AppColors.dealerColor,
                      onTap: () => _navigateToLogin(context, UserType.dealer),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Footer
              Text(
                'Join the circular economy revolution',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context, UserType userType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoginScreen(userType: userType),
      ),
    );
  }
}

class _UserTypeCard extends StatelessWidget {
  final UserType userType;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.userType,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 30,
                color: color,
              ),
            ),
            const SizedBox(width: 20),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
