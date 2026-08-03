import 'package:bobo/core/consts/routes/routes.dart';
import 'package:flutter/material.dart';

class DontHaveAccountWidgets extends StatelessWidget {
  const DontHaveAccountWidgets({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Don’t have an account?'),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.createAccount,
            );
          },
          child: const Text(
            'Sign up',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
