import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_template/core/constants/app_constant.dart';
import 'package:flutter_template/core/error/error_localization.dart';
import 'package:flutter_template/core/state_status/base_status.dart';
import 'package:flutter_template/l10n/l10n.dart';
import 'package:flutter_template/shared/base/base_entity.dart';
import 'package:flutter_template/shared/route/app_router.gr.dart';
import 'package:flutter_template/shared/theme/base/theme_extension.dart';
import 'package:flutter_template/shared/theme/text/app_text.dart';
import 'package:flutter_template/shared/widgets/buttons/_primary_button.dart';
import 'package:flutter_template/shared/widgets/input_widget/widgets.dart';
import 'package:gap/gap.dart';

import 'notifier/login_notifier.dart';

class LogInLandscapeView extends ConsumerStatefulWidget {
  const LogInLandscapeView({super.key});

  @override
  ConsumerState<LogInLandscapeView> createState() => _LogInLandscapeViewState();
}

class _LogInLandscapeViewState extends ConsumerState<LogInLandscapeView> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final pinController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    pinController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    emailController.text = 'test@gmail.com';
    pinController.text = '1234';
  }

  Future<void> _onLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref
        .read(loginProvider.notifier)
        .login(
          LoginEntity(
            email: emailController.text.trim(),
            pin: pinController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;

    ref.listen<LoginState>(loginProvider, (previous, next) {
      if (next.loginStatus.isFailure) {
        final error = (next.loginStatus as Failure).responseError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.errorLocalization.responseError(error)),
            backgroundColor: theme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.loginStatus.isSuccess) {
        context.router.replace(const HomeRoute());
      }
    });

    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        children: [
          Positioned(
            top: -110,
            right: -90,
            child: Container(
              height: 260,
              width: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.primary.withAlpha(38),
                    theme.primary.withAlpha(0),
                  ],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstant.horizontalGap20,
              vertical: AppConstant.verticalGap16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Branding — flexible so it shrinks instead of
                // overflowing on narrower landscape widths.
                Flexible(
                  flex: 3,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppConstant.horizontalGap20),
                          decoration: BoxDecoration(
                            color: theme.primary.withAlpha(26),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lock_person_rounded,
                            size: 52,
                            color: theme.primary,
                          ),
                        ),
                        Gap(AppConstant.verticalGap20),
                        AppText.displayMedium(
                          context.l10n.loginWelcomeTitle,
                          style: context.textStyle.displaySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.onBackground,
                          ),
                        ),
                        Gap(AppConstant.verticalGap8),
                        AppText.bodyMedium(
                          context.l10n.loginSubtitle,
                          style: context.textStyle.bodyMedium.copyWith(
                            color: theme.onSurface.withAlpha(153),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Login Card — flexible with a max width so it shrinks
                // instead of overflowing on narrower landscape widths.
                Flexible(
                  flex: 4,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: Container(
                      padding: EdgeInsets.all(AppConstant.horizontalGap20 + 4),
                      decoration: BoxDecoration(
                        color: theme.surfaceElevated,
                        borderRadius: BorderRadius.circular(
                          AppConstant.borderRadius20,
                        ),
                        border: Border.all(color: theme.border),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadow.withAlpha(40),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText.labelLarge(
                              context.l10n.email,
                              style: context.textStyle.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Gap(AppConstant.verticalGap8),
                            AppTextField(
                              controller: emailController,
                              hint: context.l10n.loginEmailHint,
                              textFieldType: AppTextFieldType.email,
                              fillColor: context.colors.background,
                            ),
                            Gap(AppConstant.verticalGap20),
                            AppText.labelLarge(
                              context.l10n.pin,
                              style: context.textStyle.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Gap(AppConstant.verticalGap8),
                            AppTextField(
                              controller: pinController,
                              hint: context.l10n.loginPinHint,
                              textFieldType: AppTextFieldType.number,
                              fillColor: context.colors.background,
                            ),
                            Gap(AppConstant.verticalGap20 * 1.5),
                            SizedBox(
                              width: double.infinity,
                              child: PrimaryButton(
                                onPressed: _onLogin,
                                title: context.l10n.login,
                              ),
                            ),
                            Gap(AppConstant.verticalGap12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppConstant.horizontalGap8,
                                    vertical: AppConstant.verticalGap4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.primary.withAlpha(23),
                                    borderRadius: BorderRadius.circular(
                                      AppConstant.borderRadius8,
                                    ),
                                  ),
                                  child: AppText.labelSmall(
                                    context.l10n.demoBadge,
                                    color: theme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Gap(AppConstant.horizontalGap8),
                                Flexible(
                                  child: AppText.bodySmall(
                                    context.l10n.loginDemoCredentials,
                                    color: theme.onSurface.withAlpha(140),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
