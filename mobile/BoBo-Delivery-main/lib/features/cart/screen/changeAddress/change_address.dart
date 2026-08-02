import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ChangeAddress extends StatefulWidget {
  const ChangeAddress({super.key});

  @override
  State<ChangeAddress> createState() => _ChangeAddressState();
}

class _ChangeAddressState extends State<ChangeAddress> {
  String? _selectedAddressTitle = 'Home';
  bool _isInitialized = false;

  final List<Map<String, String>> addresses = [
    {
      'title': 'Home',
      'address': 'Home - 123 Main St, Apt 4B',
    },
    {
      'title': "Grandma's house",
      'address': "Grandma's house - 456 Oak Ave, Apt 2C",
    },
    {
      'title': "Mama's house",
      'address': "Mama's house - 789 Elm St",
    },
    {
      'title': 'Office',
      'address': 'Office - 101 Tech Way, Suite 500',
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is String) {
        setState(() {
          _selectedAddressTitle = args;
        });
      }
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CancelSaveAppBar(
        title: 'Change address',
        onSave: () {
          final selected = addresses.firstWhere(
            (addr) => addr['title'] == _selectedAddressTitle,
            orElse: () => addresses.first,
          );
          Navigator.pop(context, selected);
        },
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 15),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final addr = addresses[index];
          final isSelected = _selectedAddressTitle == addr['title'];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAddressTitle = addr['title'];
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAF8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        addr['title']!,
                        style: AppTextStyle.poppins16.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Gap(15),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.lightPrimary500 : const Color(0xFFEBECE9),
                          width: 2,
                        ),
                        color: Colors.transparent,
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.lightPrimary500,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
