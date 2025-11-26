import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/Widgets/auth/AuthButton.dart';
import 'package:bukidlink/Widgets/SignupandLogin/UsernameField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/PasswordField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/ConfirmPasswordField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/FarmAddress.dart';
import 'package:bukidlink/Widgets/SignupandLogin/FarmName.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/Pages/LoadingPage.dart';
import 'package:bukidlink/models/User.dart';
import 'package:bukidlink/models/Farm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/Widgets/auth/AuthPageLayout.dart';

class SignUpContinuedPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String emailAddress;
  final String address;
  final String contactNumber;
  final String accountType;
  const SignUpContinuedPage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.emailAddress,
    required this.address,
    required this.contactNumber,
    required this.accountType,
  });

  @override
  State<SignUpContinuedPage> createState() => _SignUpContinuedPageState();
}

class _SignUpContinuedPageState extends State<SignUpContinuedPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController farmAddressController = TextEditingController();
  final TextEditingController farmNameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? forceErrorText;
  bool isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    farmAddressController.dispose();
    farmNameController.dispose();
    super.dispose();
  }

  void onChanged(String value) {
    if (forceErrorText != null) {
      setState(() {
        forceErrorText = null;
      });
    }
  }

  void handleSignUp(BuildContext context) async {
    final bool isValid = formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = User(
        id: '',
        username: usernameController.text,
        password: passwordController.text,
        firstName: widget.firstName,
        lastName: widget.lastName,
        emailAddress: widget.emailAddress,
        address: widget.address,
        contactNumber: widget.contactNumber,
        profilePic: '/images/default_profile.png',
        type: widget.accountType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final userCredential = widget.accountType == 'Farmer'
          ? await UserService().registerFarm(
              user,
              Farm(
                id: '',
                name: farmNameController.text,
                address: farmAddressController.text,
                ownerId: FirebaseFirestore.instance.doc('users/placeholder'),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            )
          : await UserService().registerUser(user);

      if (context.mounted) {
        setState(() => isLoading = false);
        if (userCredential != null) {
          PageNavigator().goTo(
            context,
            LoadingPage(userType: widget.accountType),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign-up failed. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
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
                const Text('Almost Done!',
                    style: AppTextStyles.HELLO_THERE_TITLE),
                const SizedBox(height: 8.0),
                const Text('Just a few more details',
                    style: AppTextStyles.CREATE_ACCOUNT_SUBTITLE),
                const SizedBox(height: 24.0),
                _buildFields(widget.accountType),
                const SizedBox(height: 24.0),
                AuthButton(
                  onPressed: () => handleSignUp(context),
                  label: 'Create Account',
                ),
                const SizedBox(height: 32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFields(String accountType) {
    return Column(
      children: [
        EmailField(
          controller: usernameController,
          mode: 'SignUp',
          forceErrorText: forceErrorText,
          onChanged: onChanged,
        ),
        const SizedBox(height: 16.0),
        PasswordField(
          controller: passwordController,
          mode: 'SignUp',
          forceErrorText: null,
          onChanged: onChanged,
        ),
        const SizedBox(height: 16.0),
        ConfirmPasswordField(controller: confirmPasswordController),
        if (accountType == 'Farmer') ...[
          const SizedBox(height: 16.0),
          FarmNameField(controller: farmNameController, onChanged: onChanged),
          const SizedBox(height: 16.0),
          FarmAddressField(
            controller: farmAddressController,
            onChanged: onChanged,
          ),
        ],
      ],
    );
  }
}
