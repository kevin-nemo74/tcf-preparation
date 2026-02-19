import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Appearance",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _ThemeRadioTile(
              title: "System Default",
              value: ThemeMode.system,
              groupValue: themeController.themeMode,
              onChanged: themeController.setThemeMode,
            ),
            _ThemeRadioTile(
              title: "Light",
              value: ThemeMode.light,
              groupValue: themeController.themeMode,
              onChanged: themeController.setThemeMode,
            ),
            _ThemeRadioTile(
              title: "Dark",
              value: ThemeMode.dark,
              groupValue: themeController.themeMode,
              onChanged: themeController.setThemeMode,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeRadioTile extends StatelessWidget {
  final String title;
  final ThemeMode value;
  final ThemeMode groupValue;
  final Future<void> Function(ThemeMode) onChanged;

  const _ThemeRadioTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ThemeMode>(
      title: Text(title),
      value: value,
      groupValue: groupValue,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
