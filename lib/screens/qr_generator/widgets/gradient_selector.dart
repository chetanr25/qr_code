import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../utils/gradient_colors.dart';

class GradientSelector extends StatelessWidget {
  final String selectedGradient;
  final Function(String) onGradientSelected;

  const GradientSelector({
    Key? key,
    required this.selectedGradient,
    required this.onGradientSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showGradientPicker(context),
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: AppBar().preferredSize.height * 0.7,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(195, 0, 170, 255).withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 20,
              ),
            ],
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: AppBar().preferredSize.height * 0.4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: GradientColors.gradients[selectedGradient]!,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Gradient', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  void _showGradientPicker(BuildContext context) {
    if (Platform.isIOS) {
      _showIOSGradientPicker(context);
    } else {
      _showAndroidGradientPicker(context);
    }
  }

  void _showIOSGradientPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _buildIOSGradientSheet(context),
    );
  }

  void _showAndroidGradientPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildAndroidGradientDialog(context),
    );
  }

  Widget _buildIOSGradientSheet(BuildContext context) {
    return CupertinoActionSheet(
      title: const Text('Change Gradient'),
      actions: GradientColors.gradients.entries.map((entry) {
        return _buildGradientOption(context, entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildAndroidGradientDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Gradient'),
      content: SingleChildScrollView(
        child: Column(
          children: GradientColors.gradients.entries.map((entry) {
            return _buildGradientOption(context, entry.key, entry.value);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGradientOption(
    BuildContext context,
    String name,
    List<Color> colors,
  ) {
    return ListTile(
      title: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      onTap: () {
        onGradientSelected(name);
        Navigator.pop(context);
      },
    );
  }
}
