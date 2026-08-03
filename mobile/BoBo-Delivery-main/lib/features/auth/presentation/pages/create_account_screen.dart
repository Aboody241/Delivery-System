import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/widgets/button_style.dart';
import 'package:bobo/core/consts/widgets/custom_appbar.dart';
import 'package:bobo/core/consts/widgets/custom_buttons.dart';
import 'package:bobo/core/consts/widgets/custom_forms.dart';
import 'package:bobo/core/consts/widgets/titled_text.dart';
import 'package:bobo/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bobo/features/auth/presentation/cubit/auth_state.dart';
import 'package:bobo/features/auth/presentation/widgets/have_account_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isvalid = false;
  bool isagreed = false;

  void validator() {
    setState(() {
      isvalid =
          emailController.text.isNotEmpty &&
          passwordController.text.length > 5 &&
          isagreed;
    });
  }

  @override
  void initState() {
    emailController.addListener(validator);
    passwordController.addListener(validator);
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void regstire() {
    context.read<AuthCubit>().register(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CenterLogoAndBackAppbar(),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, AppRoutes.createProfileScreen);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isloading = state is AuthLoading;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitledText(title: 'Create a new \naccount'),
                  Gap(25),

                  BasicTextField(
                    controller: emailController,
                    hintText: 'email address',
                  ),
                  Gap(20),
                  Passwordfields(
                    controller: passwordController,
                    hintText: 'password',
                  ),
                  Gap(8),

                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isagreed = !isagreed;
                            validator(); // تحديث validator فورًا عند تغيير checkbox
                          });
                        },
                        icon: isagreed
                            ? Icon(
                                Icons.check_box,
                                color: AppColors.darkGradientLight,
                              )
                            : Icon(
                                Icons.check_box_outline_blank,
                                color: AppColors.darkGradientLight,
                              ),
                      ),
                      Text(
                        'I agree to terms & conditions',
                        style: AppTextStyle.poppins16.copyWith(
                          color: AppColors.darkGrey300,
                        ),
                      ),
                    ],
                  ),

                  Spacer(),

                  EnabledButton(
                    onPressed: (isvalid && !isloading) ? regstire : null,
                    hei: 55,
                    child: isloading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('Register', style: ButtonTextStyle.button),
                  ),

                  HaveAccountWidget(),

                  Gap(20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
