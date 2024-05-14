import 'package:flutter/material.dart';

class Tag extends StatelessWidget {
  final String text;
  const Tag({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height:37,
        decoration: BoxDecoration(
          color: Colors.grey[500],
          borderRadius: const BorderRadius.all(Radius.circular(30)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12,8,12,8),
          child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
    );
  }
}
