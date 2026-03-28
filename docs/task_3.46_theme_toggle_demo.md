# Theme Toggling with themeProvider

## Overview

We use Riverpod to manage the application's theme state. This allows any widget to toggle between Light, Dark, and System modes seamlessly.

## Code Snippet: Theme Toggle Switch

Here is a simple example of how to implement a theme toggle in a settings screen using a `SwitchListTile`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nanhenest/providers/theme_provider.dart';

class ThemeSettingsItem extends ConsumerWidget {
  const ThemeSettingsItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return SwitchListTile(
      title: const Text('Dark Mode'),
      subtitle: Text(
        themeMode == ThemeMode.system 
            ? 'Currently following system' 
            : 'Manual override active'
      ),
      secondary: Icon(
        isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).colorScheme.primary,
      ),
      value: isDarkMode,
      onChanged: (bool value) {
        // Toggle the theme state
        ref.read(themeProvider.notifier).setThemeMode(
          value ? ThemeMode.dark : ThemeMode.light
        );
      },
    );
  }
}
```

## Best Practices

- **Use ref.watch**: Always use `ref.watch(themeProvider)` in your `build` method to ensure the UI rebuilds when the theme changes.
- **ProviderScope**: Ensure that `ProviderScope` is at the root of your app in `main.dart` (this has already been set up).
- **System Theme**: By default, the app follows the system theme (`ThemeMode.system`).
