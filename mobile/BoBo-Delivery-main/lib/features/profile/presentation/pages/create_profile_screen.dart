import 'package:bobo/features/profile/presentation/cubit/user_cubit.dart';
import 'package:bobo/features/profile/data/models/user_model.dart';
import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/core/consts/widgets/button_style.dart';
import 'package:bobo/core/consts/widgets/custom_appbar.dart';
import 'package:bobo/core/consts/widgets/custom_buttons.dart';
import 'package:bobo/core/consts/widgets/custom_forms.dart';
import 'package:bobo/core/consts/widgets/titled_text.dart';
import 'package:bobo/features/profile/presentation/widgets/phone_form.dart';
import 'package:bobo/features/profile/presentation/widgets/upload_profile.dart';
import 'package:bobo/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bobo/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:phone_form_field/phone_form_field.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController birthController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  final PhoneController phoneController = PhoneController();
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    birthController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CenterLogoAndBackAppbar(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitledText(title: 'Create profile'),
              const Gap(10),
              Center(child: const UploadProfilePhoto()),
              Gap(20),
              BasicTextField(
                controller: nameController,
                hintText: 'Full Name',
              ),
              Gap(20),
              PhoneForm(controller: phoneController),
              Gap(20),
              BasicTextField(
                controller: birthController,
                keyboardtype: TextInputType.number,
                hintText: 'date of birth',
              ),
              Gap(20),
              BasicTextField(
                controller: addressController,
                hintText: 'Address',
              ),
              Gap(80),
              EnabledButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          final authState = context.read<AuthCubit>().state;
                          String uid = 'guest';
                          String email = '';
                          if (authState is AuthAuthenticated) {
                            uid = authState.uid;
                            email = authState.email;
                          }
                          
                          final userModel = UserModel(
                            uid: uid,
                            name: nameController.text.trim(),
                            email: email,
                            phoneCode: phoneController.value?.countryCode ?? '',
                            phoneNumber: phoneController.value?.nsn ?? '',
                            birthday: birthController.text.trim(),
                            address: addressController.text.trim(),
                            imageUrl: '',
                          );
                          
                          await context.read<UserCubit>().saveUser(userModel);
                          if (mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.mainNav,
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Failed to save profile: $e')),
                            );
                          }
                        }
                      },
                hei: 55,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Continue', style: ButtonTextStyle.button),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
