import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_template/core/constants/app_constant.dart';
import 'package:flutter_template/shared/theme/base/theme_extension.dart';
import 'package:flutter_template/shared/theme/text/app_text.dart';

/// A single settings row: leading icon, title/subtitle, optional trailing
/// widget or tap handler. Shared by [SettingsPortraitView] and
/// [SettingsLandscapeView].
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstant.borderRadius12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstant.horizontalGap16,
          vertical: AppConstant.verticalGap12,
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? theme.primary, size: 22),
            Gap(AppConstant.horizontalGap16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bodyLarge(title, fontWeight: FontWeight.w600),
                  if (subtitle != null) ...[
                    Gap(AppConstant.verticalGap4),
                    AppText.bodySmall(
                      subtitle!,
                      color: theme.onSurface.withAlpha(150),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
