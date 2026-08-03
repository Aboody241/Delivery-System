import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/features/profile/presentation/cubit/user_cubit.dart';
import 'package:bobo/features/profile/presentation/cubit/user_state.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeAppbar extends StatelessWidget {
  const HomeAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 1,
      title: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (state is UserLoading || state is UserInitial) {
            return const SizedBox(
              height: 40,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }

          String userName = 'User';
          String? imagePath;
          String? imageUrl;
          if (state is UserLoaded) {
            userName = state.user.name;
            imagePath = state.localImagePath;
            imageUrl = state.user.imageUrl;
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hi $userName',
                    style: AppTextStyle.poppins18,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('What are you craving?', style: AppTextStyle.poppins20),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .pushNamed(AppRoutes.userProfileScreen);
                },
                child: CircleAvatar(
                  maxRadius: 25,
                  backgroundColor: Colors.blueAccent,
                  backgroundImage: imagePath != null
                      ? FileImage(File(imagePath))
                      : (imageUrl != null && imageUrl.isNotEmpty)
                          ? NetworkImage(imageUrl)
                          : null,
                  child: (imagePath == null && (imageUrl == null || imageUrl.isEmpty))
                      ? const Icon(Icons.person, color: Colors.white, size: 28)
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
