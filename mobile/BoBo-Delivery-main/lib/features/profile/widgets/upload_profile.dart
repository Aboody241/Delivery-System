import 'dart:io';
import 'package:bobo/controller/user/cubit/user_cubit.dart';
import 'package:bobo/controller/user/cubit/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class UploadProfilePhoto extends StatelessWidget {
  const UploadProfilePhoto({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        String? imagePath;
        if (state is UserLoaded) {
          imagePath = state.localImagePath;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 90),
          child: Stack(
            children: [
              Center(
                child: CircleAvatar(
                  maxRadius: 70,
                  backgroundColor: const Color.fromARGB(255, 152, 152, 152),
                  backgroundImage: imagePath != null ? FileImage(File(imagePath)) : null,
                  child: imagePath == null
                      ? const Icon(
                          Icons.person_outline_rounded,
                          size: 55,
                          color: Color.fromARGB(255, 254, 254, 254),
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null && context.mounted) {
                      context.read<UserCubit>().updateProfileImage(File(pickedFile.path));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 5),
                      shape: BoxShape.circle,
                      color: const Color.fromARGB(255, 229, 229, 229),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 30,
                      color: Color.fromARGB(255, 141, 141, 141),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
