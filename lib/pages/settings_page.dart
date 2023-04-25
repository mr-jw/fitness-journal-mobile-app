import 'package:fitness_tracker/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return SettingsList(
      sections: [
        SettingsSection(
          title: const Text('Display'),
          tiles: [
            SettingsTile.switchTile(
              leading: const Icon(
                Icons.dark_mode_outlined,
              ),
              title: const Text(
                'Dark Mode',
              ),
              activeSwitchColor: themeProvider.isDarkTheme
                  ? Colors.amber.shade400
                  : Colors.white,
              initialValue: themeProvider.isDarkTheme,
              onToggle: (value) {
                final provider =
                    Provider.of<ThemeProvider>(context, listen: false);
                provider.toggleTheme(value);
              },
            ),
          ],
        ),
        SettingsSection(
          title: const Text('Privacy and Security'),
          tiles: [
            SettingsTile(
              title: const Text('Clear App data'),
              onPressed: (context) {},
              description:
                  const Text("Erase all Activity data stored on this device."),
              leading: const Icon(Icons.data_array_outlined),
            ),
          ],
        ),
      ],
    );
  }
}
