import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/widgets/custom_appbar.dart';
import 'package:bobo/core/consts/widgets/custom_forms.dart';
import 'package:bobo/core/consts/widgets/titled_text.dart';
import 'package:bobo/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bobo/features/auth/presentation/cubit/auth_state.dart';
import 'package:bobo/features/auth/presentation/widgets/dont_have_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  void login() {
    context.read<AuthCubit>().login(
          emailcon.text.trim(),
          passlcon.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CenterLogoAndBackAppbar(),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, AppRoutes.mainNav);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isloading = state is AuthLoading;
            return LayoutBuilder(
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
            );
          },
        ),
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
