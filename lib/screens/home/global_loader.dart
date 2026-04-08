import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class GlobalLoaderScreen extends StatefulWidget {
  final String nextRoute;
  const GlobalLoaderScreen({super.key, required this.nextRoute});

  @override
  State<GlobalLoaderScreen> createState() => _GlobalLoaderScreenState();
}

class _GlobalLoaderScreenState extends State<GlobalLoaderScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        if (widget.nextRoute == '/' || widget.nextRoute == '/login') {
          context.go(widget.nextRoute);
        } else {
          context.pushReplacement(widget.nextRoute);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9C8A8), // Peach background
      body: Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(4, 4),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Lottie.asset(
              'lib/lotties/Baby loading.json',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
