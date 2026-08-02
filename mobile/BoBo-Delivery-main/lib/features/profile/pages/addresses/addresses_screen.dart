import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final List<Map<String, dynamic>> _addresses = [
    {
      'title': 'Home',
      'details': 'Buzz apartment 4B',
      'isDefault': true,
    },
    {
      'title': "Grandma's house",
      'details': '123 Main St, Apt 4B',
      'isDefault': false,
    },
    {
      'title': "Mama's house",
      'details': '123 Main St, Apt 4B',
      'isDefault': false,
    },
    {
      'title': 'Office',
      'details': '123 Main St, Apt 4B',
      'isDefault': false,
    },
  ];

  Future<void> _navigateToAddAddress() async {
    final newAddress = await Navigator.pushNamed(context, AppRoutes.addAddress);
    if (newAddress != null && newAddress is Map<String, dynamic>) {
      setState(() {
        if (newAddress['isDefault'] == true) {
          // Unset other default addresses
          for (var addr in _addresses) {
            addr['isDefault'] = false;
          }
        }
        _addresses.add(newAddress);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Separate default and non-default addresses
    final defaultAddresses = _addresses.where((addr) => addr['isDefault'] == true).toList();
    final otherAddresses = _addresses.where((addr) => addr['isDefault'] != true).toList();

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
          "Addresses",
          style: AppTextStyle.poppins20Bold.copyWith(
            color: AppColors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _navigateToAddAddress,
            icon: const Icon(
              Icons.add,
              color: Colors.black,
              size: 26,
            ),
          ),
          const Gap(10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (defaultAddresses.isNotEmpty) ...[
              // Default Section Header
              Text(
                'Default',
                style: AppTextStyle.poppins14Bold.copyWith(
                  color: AppColors.darkGrey300,
                ),
              ),
              const Gap(12),

              // Render Default Addresses
              ...defaultAddresses.map((addr) => _buildAddressCard(addr)),
              const Gap(25),

              // Section Divider
              const Divider(
                color: Color(0xFFECECEC),
                thickness: 1,
              ),
              const Gap(25),
            ],

            if (otherAddresses.isNotEmpty) ...[
              // Others Section Header
              Text(
                'Others',
                style: AppTextStyle.poppins14Bold.copyWith(
                  color: AppColors.darkGrey300,
                ),
              ),
              const Gap(12),

              // Render Other Addresses
              ...otherAddresses.map((addr) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _buildAddressCard(addr),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> addr) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.back,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  addr['title'] ?? '',
                  style: AppTextStyle.poppins16.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (addr['details'] != null && addr['details'].toString().isNotEmpty) ...[
                  const Gap(4),
                  Text(
                    addr['details'],
                    style: AppTextStyle.poppins14.copyWith(
                      color: AppColors.darkGrey400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.darkGrey400,
            size: 16,
          ),
        ],
      ),
    );
  }
}
