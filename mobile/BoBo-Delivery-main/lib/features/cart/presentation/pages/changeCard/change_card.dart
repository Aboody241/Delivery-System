import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ChangeCardScreen extends StatefulWidget {
  const ChangeCardScreen({super.key});

  @override
  State<ChangeCardScreen> createState() => _ChangeCardScreenState();
}

class _ChangeCardScreenState extends State<ChangeCardScreen> {
  String? _selectedCardTitle = 'Mastercard - Daniel Jones';
  bool _isInitialized = false;

  final List<Map<String, String>> cards = [
    {
      'title': 'Mastercard - Daniel Jones',
    },
    {
      'title': 'Mastercard - Emily Jones',
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is String) {
        setState(() {
          _selectedCardTitle = args;
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
        title: 'Change card',
        onSave: () {
          final selected = cards.firstWhere(
            (c) => c['title'] == _selectedCardTitle,
            orElse: () => cards.first,
          );
          Navigator.pop(context, selected);
        },
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 15),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          final isSelected = _selectedCardTitle == card['title'];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCardTitle = card['title'];
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
                        card['title']!,
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
