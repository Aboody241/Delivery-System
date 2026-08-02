import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  bool _isDefault = false;

  // Controllers
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Listen to changes to toggle bottom action button state
    _titleController.addListener(_validateForm);
    _detailsController.addListener(_validateForm);
    _nameController.addListener(_validateForm);
    _phoneCodeController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _streetController.addListener(_validateForm);
    _cityController.addListener(_validateForm);
    _stateController.addListener(_validateForm);
    _zipController.addListener(_validateForm);
    _countryController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _nameController.dispose();
    _phoneCodeController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _titleController.text.isNotEmpty &&
        _detailsController.text.isNotEmpty &&
        _nameController.text.isNotEmpty &&
        _phoneCodeController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _streetController.text.isNotEmpty &&
        _cityController.text.isNotEmpty &&
        _stateController.text.isNotEmpty &&
        _zipController.text.isNotEmpty &&
        _countryController.text.isNotEmpty;

    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
          "Add Address",
          style: AppTextStyle.poppins20Bold.copyWith(
            color: AppColors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Custom triple dots option menu action
            },
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Colors.black,
              size: 24,
            ),
          ),
          const Gap(10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Gap(15),

            // "Set as default" Toggle Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.back,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Set as default',
                      style: AppTextStyle.poppins16.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Switch.adaptive(
                      value: _isDefault,
                      activeColor: AppColors.lightPrimary500,
                      onChanged: (value) {
                        setState(() {
                          _isDefault = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Gap(20),

            // First Section Divider
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: Color(0xFFECECEC),
                thickness: 1,
              ),
            ),
            const Gap(15),

            // Group 1: Address Labels
            _buildInputField(
              controller: _titleController,
              hintText: 'Home',
            ),
            _buildInputField(
              controller: _detailsController,
              hintText: 'Buzz apartment 4B',
            ),
            const Gap(15),

            // Second Section Divider
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: Color(0xFFECECEC),
                thickness: 1,
              ),
            ),
            const Gap(15),

            // Group 2: Contact & Location details
            _buildInputField(
              controller: _nameController,
              hintText: 'Daniel Jones',
            ),

            // Phone Code & Phone Number row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: _buildInputField(
                      controller: _phoneCodeController,
                      hintText: '405',
                      horizontalPadding: 0,
                      verticalPadding: 0,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: _buildInputField(
                      controller: _phoneController,
                      hintText: '555-0128',
                      horizontalPadding: 0,
                      verticalPadding: 0,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
            ),

            _buildInputField(
              controller: _streetController,
              hintText: '123 Main St, Apt 4B',
            ),

            // City & State row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      controller: _cityController,
                      hintText: 'New York',
                      horizontalPadding: 0,
                      verticalPadding: 0,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: _buildInputField(
                      controller: _stateController,
                      hintText: 'California',
                      horizontalPadding: 0,
                      verticalPadding: 0,
                    ),
                  ),
                ],
              ),
            ),

            // Zip Code & Country row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      controller: _zipController,
                      hintText: '10001',
                      horizontalPadding: 0,
                      verticalPadding: 0,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: _buildInputField(
                      controller: _countryController,
                      hintText: 'United States',
                      horizontalPadding: 0,
                      verticalPadding: 0,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(30),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
        child: GestureDetector(
          onTap: _isFormValid
              ? () {
                  // Pop back with address object containing input details
                  final addressData = {
                    'title': _titleController.text,
                    'details': _detailsController.text,
                    'name': _nameController.text,
                    'phone': '+${_phoneCodeController.text} ${_phoneController.text}',
                    'street': _streetController.text,
                    'city': _cityController.text,
                    'state': _stateController.text,
                    'zip': _zipController.text,
                    'country': _countryController.text,
                    'isDefault': _isDefault,
                  };
                  Navigator.pop(context, addressData);
                }
              : null,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: _isFormValid ? AppColors.lightPrimary500 : const Color(0xFFEBECE9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Add Address',
                style: AppTextStyle.poppins18Bold.copyWith(
                  color: _isFormValid ? Colors.white : const Color(0xFF9EA09C),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    double horizontalPadding = 20,
    double verticalPadding = 7,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
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
}
