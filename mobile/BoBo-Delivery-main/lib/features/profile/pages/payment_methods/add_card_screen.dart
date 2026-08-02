import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  bool _isDefault = false;

  // Controllers
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Listen to changes to toggle Save button state
    _nameController.addListener(_validateForm);
    _numberController.addListener(_validateForm);
    _expiryController.addListener(_validateForm);
    _cvvController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _nameController.text.isNotEmpty &&
        _numberController.text.isNotEmpty &&
        _expiryController.text.isNotEmpty &&
        _cvvController.text.isNotEmpty;
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
          "Add a card",
          style: AppTextStyle.poppins20Bold.copyWith(
            color: AppColors.black,
          ),
        ),
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

            // Section Divider
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: Color(0xFFECECEC),
                thickness: 1,
              ),
            ),
            const Gap(20),

            // Input Fields
            _buildInputField(
              controller: _nameController,
              hintText: 'Cardholder name',
            ),
            _buildInputField(
              controller: _numberController,
              hintText: 'Card number',
              keyboardType: TextInputType.number,
            ),
            _buildInputField(
              controller: _expiryController,
              hintText: 'Expiration date',
              keyboardType: TextInputType.datetime,
            ),
            _buildInputField(
              controller: _cvvController,
              hintText: 'CVV',
              keyboardType: TextInputType.number,
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
                  // Save action, pop with card details
                  final card = {
                    'title': 'Mastercard - ${_nameController.text}',
                  };
                  Navigator.pop(context, card);
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
                'Save',
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
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
