import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  int _tapCount = 0;
  DateTime? _firstTapTime;

  void _handleHiddenTap() {
    final now = DateTime.now();

    if (_firstTapTime == null ||
        now.difference(_firstTapTime!).inSeconds > 6) {
      _tapCount = 0;
      _firstTapTime = now;
    }

    _tapCount++;

    if (_tapCount == 15) {
      _tapCount = 0;
      _firstTapTime = null;
      _showDeveloperDialog();
    }
  }

  void _showDeveloperDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('System Info'),
        content: const Text(
          'DEVELOPED BY VALVIX ISSUED TO PROJECT USE ONLY NOT FOR SALE',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About MediTracker'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// App Header (Hidden tap here)
            GestureDetector(
              onTap: _handleHiddenTap,
              child: Column(
                children: [
                  Icon(
                    Icons.medical_services_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'MediTracker',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Smart Medicine Reminder System',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Version 1.2.1',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            /// What is MediTracker
            _infoTile(
              Icons.info_outline,
              'What is MediTracker?',
              'MediTracker is a medicine management system designed for medical shop owners to track customer prescriptions and ensure timely medicine refills.',
            ),

            const SizedBox(height: AppSpacing.md),

            /// Who is it for
            _infoTile(
              Icons.storefront,
              'Who is it for?',
              'This app is built for pharmacies and medical owners who want to improve customer retention and provide better healthcare service.',
            ),

            const SizedBox(height: AppSpacing.md),

            /// How it works
            _infoTile(
              Icons.notifications_active_outlined,
              'How does it work?',
              'The system tracks prescribed medicines and automatically reminds customers via message before their medicine supply finishes.',
            ),

            const SizedBox(height: AppSpacing.md),

            /// Benefits
            _infoTile(
              Icons.trending_up,
              'Why use MediTracker?',
              'Reduce missed refills, increase repeat customers, save time, and provide reliable medicine reminders with minimal effort.',
            ),

            const SizedBox(height: AppSpacing.xl),

            Center(
              child: Text(
                '© ${DateTime.now().year} MediTracker',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
