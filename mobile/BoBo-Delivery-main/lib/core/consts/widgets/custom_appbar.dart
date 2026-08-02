import 'package:bobo/core/consts/widgets/logo.dart';
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CenterLogoAndBackAppbar extends StatelessWidget {
  const CenterLogoAndBackAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: MainLogo(height: 60, wedth: 60),
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 28),
      ),
    );
  }
}

//////////////////////////////////////////////////
class CenterLogoAppbar extends StatelessWidget {
  const CenterLogoAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: MainLogo(height: 60, wedth: 60),
      centerTitle: true,
    );
  }
}

/////////////////////////////////////////////////
class CenterandLeadingLogoAppbar extends StatelessWidget {
  const CenterandLeadingLogoAppbar({super.key, required this.leading});

  final Widget leading;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: MainLogo(height: 60, wedth: 60),
      centerTitle: true,
      leading: leading,
    );
  }
}

// MainLogo(height: 40, wedth: 40),

class CenterWidgetAppbar extends StatelessWidget {
  const CenterWidgetAppbar({super.key, required this.title});

  final Widget title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: title,
      centerTitle: true,
    );
  }
}

class CenterChildAndBackAppbar extends StatelessWidget {
  const CenterChildAndBackAppbar({
    super.key,
    required this.title,
    required this.leading,
  });

  final Widget title;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    return AppBar(title: title, leading: leading, centerTitle: true);
  }
}

class CancelSaveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CancelSaveAppBar({
    super.key,
    required this.title,
    required this.onSave,
    this.onCancel, this.lead,
  });

  final String title;
  final Widget? lead;
  final VoidCallback onSave;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: 90,
      leading: TextButton(
        onPressed: onCancel ?? () => Navigator.pop(context),
        child:lead??  Text(
          'Cancel',
          style: AppTextStyle.poppins18Bold.copyWith(
            color: AppColors.lightTypography200,
          ),
        )  ,
      ),
      centerTitle: true,
      title: Text(
        title,
        style: AppTextStyle.poppins20Bold.copyWith(
          color: AppColors.black,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onSave,
          child: Text(
            "Save",
            style: AppTextStyle.poppins18Bold.copyWith(
              color: AppColors.lightPrimary500,
            ),
          ),
        ),
        const Gap(10),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
