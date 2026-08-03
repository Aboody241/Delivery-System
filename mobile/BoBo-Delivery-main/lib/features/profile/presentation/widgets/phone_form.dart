import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';

class PhoneForm extends StatelessWidget {
  const PhoneForm({super.key, required this.controller});

  final PhoneController? controller;

  @override
  Widget build(BuildContext context) {
    return PhoneFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'phone number',
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: const Color.fromARGB(255, 219, 219, 219),
            width: 1.3, // usually 4 is quite thick for a text field
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: AppColors.darkGradientDark, // color when focused
            width: 2,
          ),
        ),
        hintStyle: AppTextStyle.poppins14.copyWith(
          color: AppColors.darkGrey300,
        ),
      ),
      // initialValue: PhoneNumber.parse('+33'), // or use the controller
      // validator: PhoneValidator.compose(
      //     [PhoneValidator.required(), PhoneValidator.validMobile()]),
      countrySelectorNavigator: const CountrySelectorNavigator.page(),
      onChanged: (phoneNumber) => {},
      enabled: true,
      isCountrySelectionEnabled: true,
      isCountryButtonPersistent: true,
      countryButtonStyle: const CountryButtonStyle(
        showDialCode: true,
        showIsoCode: true,
        showFlag: true,
        flagSize: 16,
      ),
    );
  }
}
