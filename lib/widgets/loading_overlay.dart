import 'package:flutter/material.dart';
import 'custom_loaders.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final double opacity;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.opacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Stack(
            children: [
              // Modal Barrier to prevent interactions
              ModalBarrier(
                dismissible: false,
                color: Colors.black.withOpacity(opacity),
              ),
              // Loader and Message
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomLoader(size: 80),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
