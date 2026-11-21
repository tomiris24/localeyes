import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../state/data_store.dart';
import 'home_shell.dart';

/// The first thing the app does: ask the server for its data.
///
/// Tours, locals, spots and the catalog are four small collections, so the app
/// fetches them once here instead of making every screen deal with "still
/// loading". Until they arrive this is a spinner; if the server is not
/// answering it is a message with a Retry button, which is the whole error
/// handling the traveller ever sees.
class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  @override
  void initState() {
    super.initState();
    // After the first frame: `load` notifies listeners, and notifying while
    // the tree is still building is an error.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final DataStore store = context.read<DataStore>();
      if (store.status == DataStatus.idle) store.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final DataStore store = context.watch<DataStore>();

    return switch (store.status) {
      DataStatus.ready => const HomeShell(),
      DataStatus.failed => _ConnectionFailed(
        message: store.error ?? 'Something went wrong.',
        onRetry: store.load,
      ),
      _ => const _Loading(),
    };
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: context.palette.brand),
      ),
    );
  }
}

class _ConnectionFailed extends StatelessWidget {
  const _ConnectionFailed({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.cloud_off_rounded,
                size: 44,
                color: context.palette.inkMuted,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'LocalEyes cannot reach its server',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 19),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
