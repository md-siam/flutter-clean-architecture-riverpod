import 'package:flutter/material.dart';
import 'package:flutter_template/core/constants/app_constant.dart';
import 'package:flutter_template/shared/theme/base/theme_extension.dart';
import 'package:flutter_template/shared/theme/text/app_text.dart';

/// A titled group of setting rows wrapped in a bordered card. Shared by
/// [SettingsPortraitView] and [SettingsLandscapeView].
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: AppConstant.horizontalGap4,
            bottom: AppConstant.verticalGap8,
          ),
          child: AppText.titleSmall(
            title,
            color: theme.onSurface.withAlpha(150),
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(AppConstant.borderRadius12),
            border: Border.all(color: theme.border.withAlpha(128)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
