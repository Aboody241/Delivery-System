import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/widgets/custom_appbar.dart';
import 'package:bobo/core/consts/widgets/custom_forms.dart';
import 'package:bobo/core/consts/widgets/titled_text.dart';
import 'package:bobo/services/auth_service.dart';
import 'package:bobo/features/auth/login/widgets/dont_have_account.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class LoginPageScreen extends StatefulWidget {
  const LoginPageScreen({super.key});

  @override
  State<LoginPageScreen> createState() => _LoginPageScreenState();
}

class _LoginPageScreenState extends State<LoginPageScreen> {
  final TextEditingController emailcon = TextEditingController();
  final TextEditingController passlcon = TextEditingController();

  bool isButtonEnabled = false;

  void validator() {
    setState(() {
      isButtonEnabled =
          emailcon.text.isNotEmpty &&
          passlcon.text.isNotEmpty &&
          emailcon.text.contains('@');
    });
  }

  @override
  void initState() {
    super.initState();
    emailcon.addListener(validator);
    passlcon.addListener(validator);
  }

  @override
  void dispose() {
    emailcon.dispose();
    passlcon.dispose();
    super.dispose();
  }

  final AuthService auth = AuthService();
  bool isloading = false;

  Future<void> login() async {
    if (mounted) {
      setState(() {
        isloading = true;
      });
    }

    try {
      await auth.loginUser(emailcon.text.trim(), passlcon.text.trim());
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.mainNav);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CenterLogoAndBackAppbar(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TitledText(title: 'Log in to your \naccount'),

                      const Gap(20),

                      // Email field (normal text)
                      BasicTextField(
                        controller: emailcon,
                        hintText: 'Email address',
                      ),
                      const Gap(15),

                      // Password field
                      Passwordfields(
                        controller: passlcon,
                        hintText: 'Password',
                      ),

                      // Forget Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.verifyOtpScreen,
                              );
                            },
                            child: Text(
                              'Forget Password',
                              style: AppTextStyle.poppins14.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      _LoginButton(
                        onPressed: (isButtonEnabled && !isloading)
                            ? () {
                                login();
                              }
                            : null,
                        child: isloading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Log in',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                      ),

                      const Gap(5),

                      // Sign up
                      DontHaveAccountWidgets(),
                      const Gap(20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  // ignore: unused_element_parameter
  const _LoginButton({super.key, required this.onPressed, required this.child});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isDisabled
              ? AppColors.darkGrey400
              : AppColors.lightPrimary600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: child,
      ),
    );
  }
}
