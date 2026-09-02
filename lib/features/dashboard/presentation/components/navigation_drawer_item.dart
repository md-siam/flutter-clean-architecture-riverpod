import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_template/core/constants/app_constant.dart';
import 'package:flutter_template/shared/theme/base/theme_extension.dart';
import 'package:flutter_template/shared/theme/text/app_text.dart';

class NavigationDrawerItem extends StatelessWidget {
  const NavigationDrawerItem({
    super.key,
    required this.title,
    required this.onTap,
    required this.isSelected,
    required this.icon,
  });

  final String title;
  final VoidCallback onTap;
  final bool isSelected;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;
    final color = isSelected ? theme.primary : theme.disabled;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstant.horizontalGap12,
        vertical: AppConstant.horizontalGap4,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstant.borderRadius12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppConstant.horizontalGap16,
              vertical: AppConstant.verticalGap12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.primary.withAlpha(23)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppConstant.borderRadius12),
            ),
            child: Row(
              children: [
                Icon(icon, size: AppConstant.iconSize, color: color),
                Gap(AppConstant.horizontalGap16),
                // Flexible so the label ellipsizes instead of overflowing
                // the Row on a narrow drawer.
                Flexible(
                  child: AppText.bodyLarge(
                    title,
                    color: color,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
