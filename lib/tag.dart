import 'package:flutter/material.dart';

class Tag extends StatelessWidget {
  final String? text;
  final VoidCallback? onTap;
  Tag({
    Key? key,
    this.text,
    this.onTap,
  });

  // @override
  Widget build(BuildContext context) {
    return InkWell(
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: FittedBox(
        child: Container(
          margin: const EdgeInsets.only(right: 6, bottom: 6),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            "$text",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class ConsumerWidget {}
