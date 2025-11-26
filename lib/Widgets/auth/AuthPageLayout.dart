import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/Widgets/CustomBackButton.dart';
import 'package:bukidlink/utils/PageNavigator.dart';

class AuthPageLayout extends StatelessWidget {
  final Widget child;
  final bool showBackButton;

  const AuthPageLayout({
    super.key,
    required this.child,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Stack(
        children: [
          // Form Container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              decoration: const BoxDecoration(
                color: AppColors.containerWhite,
              ),
              child: child,
            ),
          ),
          if (showBackButton)
            Positioned(
              top: 20.0,
              left: 10.0,
              child: CustomBackButton(
                onPressed: () => PageNavigator().goBack(context),
              ),
            ),
        ],
      ),
    );
  }
}
