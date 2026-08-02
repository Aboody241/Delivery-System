import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _selectedLanguage = 'English';

  void _showLogoutDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.rightSlide,
      title: 'Logout',
      desc: 'Are you sure you want to logout?',
      btnCancelText: 'Cancel',
      btnOkText: 'Logout',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        await AuthService().logout();
        if (mounted) {
          Navigator.of(context, rootNavigator: true)
              .pushReplacementNamed(AppRoutes.onBoardingAuth);
        }
      },
    ).show();
  }

  void _showDeleteAccountDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      title: 'Delete Account',
      desc: 'Warning: This action is permanent. Are you sure you want to delete your account?',
      btnCancelText: 'Cancel',
      btnOkText: 'Delete',
      btnOkColor: AppColors.lightRed,
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        // Implement delete account logic if any, then route
        await AuthService().logout();
        if (mounted) {
          Navigator.of(context, rootNavigator: true)
              .pushReplacementNamed(AppRoutes.onBoardingAuth);
        }
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 16,
          ),
          label: Text(
            'Back',
            style: AppTextStyle.poppins16Bold.copyWith(
              color: Colors.black,
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          "Settings",
          style: AppTextStyle.poppins20Bold.copyWith(
            color: AppColors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= GENERAL SECTION =================
            Text(
              'General',
              style: AppTextStyle.poppins14Bold.copyWith(
                color: AppColors.darkGrey300,
              ),
            ),
            const Gap(12),

            _buildSettingTile(
              icon: Icons.swap_horiz_rounded,
              title: 'Switch Account',
              onTap: () {
                // Switch account action
              },
            ),
            const Gap(12),

            _buildSettingTile(
              icon: Icons.translate_rounded,
              title: 'Language',
              trailingText: _selectedLanguage,
              onTap: () async {
                final newLanguage = await Navigator.pushNamed(
                  context,
                  AppRoutes.language,
                  arguments: _selectedLanguage,
                );
                if (newLanguage != null && newLanguage is String) {
                  setState(() {
                    _selectedLanguage = newLanguage;
                  });
                }
              },
            ),
            const Gap(12),

            _buildSettingSwitchTile(
              icon: Icons.nightlight_outlined,
              title: 'Dark mode',
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
            ),
            const Gap(25),

            // ================= OTHERS SECTION =================
            Text(
              'Others',
              style: AppTextStyle.poppins14Bold.copyWith(
                color: AppColors.darkGrey300,
              ),
            ),
            const Gap(12),

            _buildSettingTile(
              icon: Icons.lock_outline_rounded,
              title: 'Privacy Policy',
              onTap: () {
                // Navigate to Privacy Policy
              },
            ),
            const Gap(12),

            _buildSettingTile(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Customer Support',
              onTap: () {
                // Navigate to Support
              },
            ),
            const Gap(12),

            _buildSettingTile(
              icon: Icons.article_outlined,
              title: 'Terms & Conditions',
              onTap: () {
                // Navigate to Terms
              },
            ),
            const Gap(25),

            // ================= DANGER ACTIONS SECTION =================
            Text(
              'Danger Actions',
              style: AppTextStyle.poppins14Bold.copyWith(
                color: AppColors.darkGrey300,
              ),
            ),
            const Gap(12),

            _buildSettingTile(
              icon: Icons.delete_outline_rounded,
              title: 'Delete Account',
              onTap: _showDeleteAccountDialog,
            ),
            const Gap(12),

            _buildSettingTile(
              icon: Icons.logout_rounded,
              title: 'Log out',
              onTap: _showLogoutDialog,
            ),
            const Gap(30),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.back,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.black87,
              size: 24,
            ),
            const Gap(16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyle.poppins16.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: AppTextStyle.poppins16.copyWith(
                  color: AppColors.darkGrey400,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(8),
            ],
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.darkGrey400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.back,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.black87,
            size: 24,
          ),
          const Gap(16),
          Expanded(
            child: Text(
              title,
              style: AppTextStyle.poppins16.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.lightPrimary500,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
