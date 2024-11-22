import 'package:flutter/material.dart';

class AppBanner extends StatelessWidget {
  const AppBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 94.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.blue,
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Colors.blue,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Text(
        'GMBOOK',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 50,
          fontFamily: 'Anton',
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
