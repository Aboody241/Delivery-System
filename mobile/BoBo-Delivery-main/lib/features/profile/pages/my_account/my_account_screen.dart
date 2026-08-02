import 'dart:io';
import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/widgets/custom_appbar.dart';
import 'package:bobo/controller/user/cubit/user_cubit.dart';
import 'package:bobo/controller/user/cubit/user_state.dart';
import 'package:bobo/controller/user/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  bool _isEditing = false;
  bool _isSaving = false;

  // Text editing controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneCodeController;
  late TextEditingController _phoneNumController;
  late TextEditingController _birthdayController;

  String _selectedAddressTitle = '';
  
  // Keep track of the current user to initialize controllers
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneCodeController = TextEditingController();
    _phoneNumController = TextEditingController();
    _birthdayController = TextEditingController();
    
    // We expect the user to be loaded already by the global Cubit, 
    // but just in case, we'll fetch again.
    context.read<UserCubit>().fetchUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneCodeController.dispose();
    _phoneNumController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  void _initControllers(UserModel user) {
    if (_currentUser == null || _currentUser!.uid != user.uid || !_isEditing) {
      _nameController.text = user.name;
      _phoneCodeController.text = user.phoneCode;
      _phoneNumController.text = user.phoneNumber;
      _birthdayController.text = user.birthday;
      _selectedAddressTitle = user.address;
      _currentUser = user;
    }
  }

  Future<void> _saveUserData() async {
    if (_currentUser == null) return;
    
    setState(() {
      _isSaving = true;
    });

    try {
      final updatedUser = _currentUser!.copyWith(
        name: _nameController.text,
        phoneCode: _phoneCodeController.text,
        phoneNumber: _phoneNumController.text,
        birthday: _birthdayController.text,
        address: _selectedAddressTitle,
      );

      await context.read<UserCubit>().saveUser(updatedUser);

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is UserLoading || state is UserInitial) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.lightPrimary500,
              ),
            ),
          );
        }

        String? imagePath;
        if (state is UserLoaded) {
          _initControllers(state.user);
          imagePath = state.localImagePath;
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _isEditing
              ? CancelSaveAppBar(
                  title: 'My Account',
                  onCancel: () {
                    setState(() {
                      if (_currentUser != null) {
                        _nameController.text = _currentUser!.name;
                        _phoneCodeController.text = _currentUser!.phoneCode;
                        _phoneNumController.text = _currentUser!.phoneNumber;
                        _birthdayController.text = _currentUser!.birthday;
                        _selectedAddressTitle = _currentUser!.address;
                      }
                      _isEditing = false;
                    });
                  },
                  onSave: _saveUserData,
                )
              : AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  automaticallyImplyLeading: false,
                  leadingWidth: 100,
                  leading: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black,
                      size: 16,
                    ),
                    label: Text(
                      'Back',
                      style: AppTextStyle.poppins16Bold.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  centerTitle: true,
                  title: Text(
                    "My Account",
                    style: AppTextStyle.poppins20Bold.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      child: Text(
                        "Edit",
                        style: AppTextStyle.poppins18Bold.copyWith(
                          color: AppColors.lightPrimary500,
                        ),
                      ),
                    ),
                    const Gap(10),
                  ],
                ),
          body: _isSaving 
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.lightPrimary500,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Gap(25),
                      // Profile Picture
                      Center(
                        child: GestureDetector(
                          onTap: _isEditing ? () async {
                            final picker = ImagePicker();
                            final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                            if (pickedFile != null && context.mounted) {
                              context.read<UserCubit>().updateProfileImage(File(pickedFile.path));
                            }
                          } : null,
                          child: Stack(
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFECECEC),
                                    width: 2.5,
                                  ),
                                  image: imagePath != null
                                      ? DecorationImage(
                                          image: FileImage(File(imagePath)),
                                          fit: BoxFit.cover,
                                        )
                                      : const DecorationImage(
                                          image: NetworkImage(
                                            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=256',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              if (_isEditing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF0F1EE),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.black54,
                                      size: 20,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(25),

                      // Toggle Editing View vs Readonly View
                      if (!_isEditing && _currentUser != null) ...[
                        // Readonly view
                        Text(
                          _currentUser!.name,
                          style: AppTextStyle.poppins24Bold.copyWith(
                            color: Colors.black,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          _currentUser!.email,
                          style: AppTextStyle.poppins14.copyWith(
                            color: AppColors.darkGrey300,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Gap(6),
                        Text(
                          _currentUser!.phoneCode.isNotEmpty
                              ? '+${_currentUser!.phoneCode} ${_currentUser!.phoneNumber}'
                              : _currentUser!.phoneNumber,
                          style: AppTextStyle.poppins16Bold.copyWith(
                            color: AppColors.darkGrey300,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Gap(35),

              // Navigation Cards List
              _buildNavigationCard(
                title: 'Addresses',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.addresses);
                },
              ),
              _buildNavigationCard(
                title: 'Payment',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.paymentMethods);
                },
              ),
              _buildNavigationCard(
                title: 'My Orders',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.myOrdersScreen);
                },
              ),
              _buildNavigationCard(
                title: 'Settings',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.settings);
                },
              ),
            ] else ...[
              // Editing view
              _buildTextField(
                controller: _nameController,
                hintText: 'Name',
              ),
              _buildPhoneRow(),
              _buildTextField(
                controller: _birthdayController,
                hintText: 'Birthdate',
              ),
              _buildAddressSelectField(),
            ],
            const Gap(30),
          ],
        ),
      ),
    );
    },
  );
  }

  Widget _buildAddressSelectField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.pushNamed(
            context,
            AppRoutes.changeAddress,
            arguments: _selectedAddressTitle,
          );
          if (result != null && result is Map<String, String>) {
            setState(() {
              _selectedAddressTitle = result['title']!;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFECECEC),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedAddressTitle.isNotEmpty
                      ? 'Address - $_selectedAddressTitle'
                      : 'Select Address',
                  style: AppTextStyle.poppins16.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.darkGrey400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          hintText: hintText,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFECECEC),
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.lightPrimary500,
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: AppTextStyle.poppins16.copyWith(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPhoneRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: Row(
        children: [
          // Code code
          SizedBox(
            width: 80,
            child: TextField(
              controller: _phoneCodeController,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFECECEC),
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.lightPrimary500,
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: AppTextStyle.poppins16.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Gap(10),
          // Number
          Expanded(
            child: TextField(
              controller: _phoneNumController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFECECEC),
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.lightPrimary500,
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: AppTextStyle.poppins16.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildNavigationCard({
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.back,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyle.poppins16.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.darkGrey400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
