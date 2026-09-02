import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_template/features/user/presentation/home_landscape_view.dart';
import 'package:flutter_template/features/user/presentation/notifier/user_notifier.dart';

import 'package:flutter_template/shared/widgets/widgets.dart';
import 'home_portrait_view.dart';

@RoutePage()
class HomeScreen extends Screen {
  const HomeScreen({super.key});

  @override
  Widget buildViewWrapper({required Widget child}) {
    return _UserListLoader(child: child);
  }

  @override
  Widget buildMobilePortraitView(BuildContext context) {
    return const HomePortraitView();
  }

  @override
  Widget buildMobileLandscapeView(BuildContext context) {
    return const HomeLandscapeView();
  }
}

/// Triggers the initial user-list fetch once, when the Home screen mounts —
/// a Riverpod-side effect equivalent to `ref.read(userProvider.notifier)`
/// being kicked off from a `StatefulWidget.initState`.
class _UserListLoader extends ConsumerStatefulWidget {
  const _UserListLoader({required this.child});

  final Widget child;

  @override
  ConsumerState<_UserListLoader> createState() => _UserListLoaderState();
}

class _UserListLoaderState extends ConsumerState<_UserListLoader> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(userProvider.notifier).getUserList());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
