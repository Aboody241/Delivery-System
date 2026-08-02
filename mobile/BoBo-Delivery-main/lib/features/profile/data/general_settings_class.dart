import 'package:flutter/material.dart';

class GeneralSettingsClass {
  final IconData icon;
  final String title;
  final VoidCallback? navigation;

  GeneralSettingsClass({
    required this.icon,
    required this.title,
    this.navigation,
  });
}
