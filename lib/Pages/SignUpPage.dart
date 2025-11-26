import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/Widgets/auth/AuthButton.dart';
import 'package:bukidlink/Widgets/SignupandLogin/FirstNameField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/LastNameField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/EmailAddressField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/AddressField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/ContactNumberField.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/Pages/SignUpContinuedPage.dart';
import 'package:bukidlink/services/google_auth.dart';
import 'package:bukidlink/Pages/LoadingPage.dart';
import 'package:bukidlink/Widgets/auth/AuthPageLayout.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ValueNotifier<String> activeTab = ValueNotifier<String>('Consumer');
  String? forceErrorText;
  bool isLoading = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailAddressController.dispose();
    addressController.dispose();
    contactNumberController.dispose();
    super.dispose();
  }

  void onChanged(String value) {
    if (forceErrorText != null) {
      setState(() {
        forceErrorText = null;
      });
    }
  }

  void handleGoogleSignIn(BuildContext context) async {
    setState(() => isLoading = true);
    try {
      final userCredential = await FirebaseService().signInWithGoogle();
      if (context.mounted) {
        setState(() => isLoading = false);
        if (userCredential != null) {
          PageNavigator().goTo(context, LoadingPage(userType: 'Consumer'));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google sign-in failed')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Google sign-in error: $e')));
      }
    }
  }

  void handleSignUp(BuildContext context) {
    final bool isValid = formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    PageNavigator().goToAndKeep(
      context,
      SignUpContinuedPage(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        emailAddress: emailAddressController.text,
        address: addressController.text,
        contactNumber: contactNumberController.text,
        accountType: activeTab.value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundYellow,
      resizeToAvoidBottomInset: false,
      body: AuthPageLayout(
        showBackButton: true,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80.0),
                const Text('Create Account',
                    style: AppTextStyles.HELLO_THERE_TITLE),
                const SizedBox(height: 8.0),
                const Text('Get started on your journey!',
                    style: AppTextStyles.CREATE_ACCOUNT_SUBTITLE),
                const SizedBox(height: 24.0),
                Row(
                  children: [
                    Expanded(
                      child: FirstNameField(controller: firstNameController),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: LastNameField(controller: lastNameController),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                EmailAddressField(controller: emailAddressController),
                const SizedBox(height: 16.0),
                AddressField(
                    controller: addressController, onChanged: onChanged),
                const SizedBox(height: 16.0),
                ContactNumberField(controller: contactNumberController),
                const SizedBox(height: 24.0),
                const Text('I am a...', style: AppTextStyles.FORM_LABEL),
                const SizedBox(height: 12.0),
                _buildAccountTypeToggle(),
                const SizedBox(height: 24.0),
                AuthButton(
                  onPressed: () => handleSignUp(context),
                  label: 'Sign Up',
                ),
                const SizedBox(height: 16.0),
                AuthButton(
                  onPressed: () => handleGoogleSignIn(context),
                  label: 'Continue with Google',
                  isPrimary: false,
                ),
                const SizedBox(height: 32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTypeToggle() {
    return ValueListenableBuilder<String>(
      valueListenable: activeTab,
      builder: (context, value, child) {
        return ToggleButtons(
          isSelected: [value == 'Consumer', value == 'Farmer'],
          onPressed: (index) {
            activeTab.value = index == 0 ? 'Consumer' : 'Farmer';
          },
          borderRadius: BorderRadius.circular(30.0),
          selectedColor: AppColors.BACKGROUND_WHITE,
          fillColor: AppColors.primaryGreen,
          color: AppColors.primaryGreen,
          constraints: const BoxConstraints(minHeight: 48.0, minWidth: 120.0),
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Consumer', style: AppTextStyles.TOGGLE_BUTTON_ACTIVE),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Farmer', style: AppTextStyles.TOGGLE_BUTTON_ACTIVE),
            ),
          ],
        );
      },
    );
  }
}
