import 'dart:io';
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/controller/user/cubit/user_cubit.dart';
import 'package:bobo/controller/user/cubit/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class UserInformationWidget extends StatelessWidget {
  const UserInformationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state is UserLoading || state is UserInitial) {
          return const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        String userName = 'User';
        String userEmail = 'user@example.com';
        String? imagePath;
        
        if (state is UserLoaded) {
          userName = state.user.name;
          userEmail = state.user.email;
          imagePath = state.localImagePath;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null && context.mounted) {
                    context.read<UserCubit>().updateProfileImage(File(pickedFile.path));
                  }
                },
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(1000),
                      child: imagePath != null
                          ? Image.file(
                              File(imagePath),
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            )
                          : Image.asset(
                              'assets/consts/avataar.jpeg',
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.lightPrimary500,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userName, style: AppTextStyle.poppins22Bold),
                  const Gap(3),
                  Text(
                    userEmail,
                    style: AppTextStyle.poppins12.copyWith(
                      color: AppColors.darkGrey300,
                    ),
                  ),
                  const Gap(10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.lightYellow),
                        const Gap(5),
                        Text(
                          'Premium',
                          style: AppTextStyle.poppins14.copyWith(
                            color: AppColors.darkGrey200,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
