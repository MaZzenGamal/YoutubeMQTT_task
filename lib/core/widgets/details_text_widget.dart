import 'package:flutter/material.dart';

class DetailsTextWidget extends StatelessWidget {
  const DetailsTextWidget({super.key, required this.title, required this.value});

  final String title;
  final String value;
  @override
  Widget build(BuildContext context) {
    return  RichText(
      text: TextSpan(
        text: '$title: ',
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
