import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:logger/logger.dart';
import 'package:flutter_template/core/constants/app_constant.dart';
import 'package:flutter_template/core/notifier/device_status/device_status_notifier.dart';
import 'package:flutter_template/l10n/l10n.dart';
import 'package:flutter_template/presentation/theme/base/theme_extension.dart';
import 'package:flutter_template/presentation/theme/text/app_text.dart';

class InternetOverlay extends ConsumerWidget {
  const InternetOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deviceStatusProvider);
    final connected = state.hasInternet;
    Logger().e("Internet Connection $connected");

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          child,
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 500),
              offset: !connected ? Offset.zero : const Offset(0, 1),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: !connected ? 1.0 : 0.0,
                child: SizedBox(
                  width: double.maxFinite,
                  child: ColoredBox(
                    color: context.colors.error,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstant.horizontalGap16,
                        vertical: AppConstant.verticalGap8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: AppConstant.horizontalGap20,
                          ),
                          Gap(AppConstant.horizontalGap12),
                          AppText.labelLarge(context.l10n.noInternetConnection),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
