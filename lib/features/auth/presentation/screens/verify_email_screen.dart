import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/auth/application/providers/auth_providers.dart';
import 'package:expense_tracker/core/widgets/network_banner.dart';
import 'package:expense_tracker/core/network/network_banner_provider.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen>
    with WidgetsBindingObserver {
  int _countdown = 60;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startCountdown();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(authNotifierProvider.notifier).reloadUser();
    }
  }

  void _startCountdown() {
    _countdown = 60;
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bannerAsync = ref.watch(networkBannerProvider);
    final notifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Column(
        children: [
          NetworkBanner(bannerAsync: bannerAsync),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mark_email_unread, size: 80),
                  const SizedBox(height: 24),
                  const Text(
                    "A verification link has been sent to your email.\n\n"
                    "After verifying, return to the app.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () async {
                      await notifier.reloadUser();
                    },
                    child: const Text("I've Verified My Email"),
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: _countdown == 0
                        ? () async {
                            await notifier.resendVerificationEmail();
                            _startCountdown();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Verification email sent"),
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      _countdown == 0
                          ? "Resend Email"
                          : "Resend in $_countdown seconds",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
