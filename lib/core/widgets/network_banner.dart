import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/network_banner_provider.dart';

class NetworkBanner extends StatelessWidget {
  final AsyncValue<NetworkBannerType> bannerAsync;

  const NetworkBanner({super.key, required this.bannerAsync});

  @override
  Widget build(BuildContext context) {
    final type = bannerAsync.when(
      data: (value) => value,
      loading: () => NetworkBannerType.hidden,
      error: (_, __) => NetworkBannerType.hidden,
    );

    final isVisible = type != NetworkBannerType.hidden;

    Color backgroundColor;
    String message;

    switch (type) {
      case NetworkBannerType.offline:
        backgroundColor = Colors.red;
        message = "You are offline";
        break;
      case NetworkBannerType.online:
        backgroundColor = Colors.green;
        message = "Back online";
        break;
      case NetworkBannerType.hidden:
        backgroundColor = Colors.transparent;
        message = "";
        break;
    }

    return AnimatedSlide(
      offset: isVisible ? Offset.zero : const Offset(0, -1),
      duration: const Duration(milliseconds: 300),
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        child: Container(
          width: double.infinity,
          color: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SafeArea(
            bottom: false,
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
