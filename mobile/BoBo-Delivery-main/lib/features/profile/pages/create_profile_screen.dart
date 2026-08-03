import 'package:bobo/controller/user/cubit/user_cubit.dart';
import 'package:bobo/controller/user/models/user_model.dart';
import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/core/consts/widgets/button_style.dart';
import 'package:bobo/core/consts/widgets/custom_appbar.dart';
import 'package:bobo/core/consts/widgets/custom_buttons.dart';
import 'package:bobo/core/consts/widgets/custom_forms.dart';
import 'package:bobo/core/consts/widgets/titled_text.dart';
import 'package:bobo/features/profile/widgets/phone_form.dart';
import 'package:bobo/features/profile/widgets/upload_profile.dart';
import 'package:bobo/services/auth_service.dart';
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
  PhoneController phoneController = PhoneController();

  bool isvalid = false;
  bool _isLoading = false;

  // void validator() {
  //   setState(() {
  //     isvalid =
  //         nameController.text.isNotEmpty &&
  //         birthController.text.isNotEmpty &&
  //         addressController.text.isNotEmpty &&
  //         phoneController.value.toString().isNotEmpty &&
  //         nameController.text.contains(' ');
  //   });
  // }

  @override
  void initState() {
    // nameController.addListener(validator);
    // phoneController.addListener(validator);
    // birthController.addListener(validator);
    // addressController.addListener(validator);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CenterandLeadingLogoAppbar(
          leading: TextButton(
            onPressed: () {},
            child: Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitledText(title: 'Create your new \nprofile'),
              Gap(20),
              UploadProfilePhoto(),
              Gap(22),
              BasicTextField(controller: nameController, hintText: 'full name'),
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
                          final authService = AuthService();
                          final uid = await authService.getCurrentUserUid() ?? 'guest';
                          final email = await authService.getCurrentUserEmail() ?? '';
                          
                          final userModel = UserModel(
                            uid: uid,
                            name: nameController.text.trim(),
                            email: email,
                            phoneCode: phoneController.value.countryCode,
                            phoneNumber: phoneController.value.nsn,
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
