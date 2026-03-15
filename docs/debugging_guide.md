# NanheNest — Debugging Guide

A comprehensive guide to Hot Reload, the Debug Console, and Flutter DevTools for the NanheNest development team.

---

## 1. Flutter Hot Reload

Flutter Hot Reload injects updated source code into the running Dart VM. The framework automatically rebuilds the widget tree so you can see the effect of your changes almost instantly — without losing the current app state.

### Hot Reload vs Hot Restart vs Full Restart

| Feature | Hot Reload | Hot Restart | Full Restart |
|---|---|---|---|
| **Trigger** | Save file (Ctrl+S / Cmd+S) or `r` in terminal | `R` in terminal / IDE button | Stop & re-run the app |
| **Speed** | Sub-second | A few seconds | 10+ seconds |
| **App State** | **Preserved** | **Reset** | **Reset** |
| **Use When** | Changing UI, styles, build() methods | Changing `initState`, static fields, global state | Changing native code, plugins, main() |

> **Tip:** If a Hot Reload does not appear to work, try a Hot Restart. Changes to `initState`, enums, generic types, or static fields require a restart.

---

## 2. Using the Debug Console

The Debug Console (visible in VS Code's bottom panel during a debug session) lets you:

- View `debugPrint()` and `print()` output
- Evaluate Dart expressions at runtime
- Inspect variables and objects
- Execute code in the current stack frame context

### How to open

1. Start the app via **Run > Start Debugging** (F5) or select a launch configuration.
2. Open the Debug Console tab in the bottom panel (`Ctrl+Shift+Y` / `Cmd+Shift+Y`).

### Useful Debug Console expressions

```dart
// Check widget rebuild count
debugPrint('Build called at ${DateTime.now()}');

// Inspect a variable (type its name in the console)
_counter

// Evaluate an expression
MediaQuery.of(context).size
```

### Using AppLogger

The project includes a logging utility at `lib/utils/logger.dart`:

```dart
import 'package:nanhenest/utils/logger.dart';

AppLogger.debugLog('Counter value', tag: 'HOME');
AppLogger.infoLog('Screen opened');
AppLogger.errorLog('Failed to load', error: e, stackTrace: stack);
```

All messages include timestamps and tags for easy filtering in the Debug Console.

---

## 3. Launching Flutter DevTools

### From VS Code

1. Start a debug session (F5).
2. Open the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`).
3. Run **Dart: Open DevTools** or **Flutter: Open DevTools**.
4. Alternatively, use the launch configuration **"Flutter Debug + DevTools"** in `.vscode/launch.json` — DevTools opens automatically.

### From the terminal

```bash
# While the app is running via `flutter run`:
# Press `v` to open DevTools in the browser

# Or launch manually:
dart devtools
```

---

## 4. DevTools Features

### 4.1 Widget Inspector

Inspect the widget tree, view properties, and identify layout issues.

1. Open DevTools > **Widget Inspector** tab.
2. Click **Select Widget Mode** (crosshair icon) to tap on a widget in the app and highlight it in the tree.
3. View the **Details Tree** on the right to see properties, constraints, and render object info.

### 4.2 Layout Explorer

Debug layout and constraint issues visually.

1. In the Widget Inspector, select a Flex widget (`Row`, `Column`, `Flex`).
2. The **Layout Explorer** panel appears showing flex properties, main axis alignment, and cross axis alignment.
3. Modify properties live to experiment with layouts.

### 4.3 Performance Profiling

Identify jank and slow frames.

1. Open DevTools > **Performance** tab.
2. Interact with the app — each frame is plotted on the timeline.
3. Frames exceeding 16ms (60fps threshold) are highlighted in red.
4. Click a frame to see the build, layout, and paint phases.
5. Use **Profile mode** (`Flutter Profile` launch config) for accurate measurements — debug mode includes overhead.

### 4.4 Memory View

Track memory usage, identify leaks, and analyse allocations.

1. Open DevTools > **Memory** tab.
2. View the real-time memory usage chart (Dart heap, external, RSS).
3. Click **Snapshot** to take a heap snapshot and inspect live objects.
4. Use **Diff Snapshots** to compare two snapshots and find objects that were allocated but not freed.

### 4.5 Network Inspector

Monitor HTTP requests and responses.

1. Open DevTools > **Network** tab.
2. All HTTP traffic is listed with method, URL, status, and timing.
3. Click a request to view headers, request body, and response body.
4. Useful for debugging Firestore REST calls and other API interactions.

---

## 5. Debugging Riverpod State Changes

### Using Riverpod's ProviderObserver

Add a custom observer to log every state change:

```dart
class RiverpodLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    AppLogger.debugLog(
      '${provider.name ?? provider.runtimeType}: $previousValue -> $newValue',
      tag: 'RIVERPOD',
    );
  }

  @override
  void didDisposeProvider(
    ProviderBase provider,
    ProviderContainer container,
  ) {
    AppLogger.debugLog(
      '${provider.name ?? provider.runtimeType} disposed',
      tag: 'RIVERPOD',
    );
  }
}
```

Register it in `main()`:

```dart
runApp(
  ProviderScope(
    observers: [RiverpodLogger()],
    child: const NanheNestApp(),
  ),
);
```

### Tips

- **Name your providers** using the `name` parameter so logs are readable.
- Use the Debug Console filter to search for `RIVERPOD` tagged messages.

---

## 6. Debugging Firestore Streams

### Common issues

| Symptom | Cause | Fix |
|---|---|---|
| Stream never emits | Missing index or wrong query | Check Firestore console for index prompts |
| Stream emits once then stops | Using `.get()` instead of `.snapshots()` | Switch to `.snapshots()` |
| Duplicate events | Multiple listeners on the same query | Use `ref.watch` with Riverpod to share streams |

### Logging Firestore streams

```dart
FirebaseFirestore.instance
    .collection('bookings')
    .snapshots()
    .listen(
      (snapshot) => AppLogger.debugLog(
        'Bookings updated: ${snapshot.docs.length} docs',
        tag: 'FIRESTORE',
      ),
      onError: (e) => AppLogger.errorLog(
        'Bookings stream error',
        tag: 'FIRESTORE',
        error: e,
      ),
    );
```

---

## 7. UI Rebuild Debugging

### Detecting unnecessary rebuilds

Add logging inside `build()` methods:

```dart
@override
Widget build(BuildContext context) {
  AppLogger.debugLog('MyWidget build()', tag: 'REBUILD');
  // ...
}
```

### Using the Widget Inspector

1. Open DevTools > Widget Inspector.
2. Enable **Track Widget Rebuilds** (paint icon) — widgets flash when they rebuild.
3. Minimize rebuilds by:
   - Using `const` constructors wherever possible.
   - Breaking large widgets into smaller sub-widgets.
   - Using `select` with Riverpod to watch only the fields you need.

---

## 8. Memory Leak Debugging

### Common Flutter memory leaks

- **Unreleased StreamSubscriptions** — always cancel in `dispose()`.
- **Uncancelled Timers** — cancel periodic timers in `dispose()`.
- **Holding BuildContext across async gaps** — check `mounted` before calling `setState`.

### How to detect

1. Open DevTools > **Memory** tab.
2. Navigate back and forth between screens several times.
3. Take a **heap snapshot** and look for objects that should have been garbage-collected.
4. Compare snapshots with **Diff** to identify growing allocations.

### Prevention checklist

```dart
@override
void dispose() {
  _subscription?.cancel();   // Cancel stream subscriptions
  _timer?.cancel();           // Cancel timers
  _controller.dispose();      // Dispose controllers
  super.dispose();
}
```

---

## 9. Widget Rebuild Tracking with Performance Overlay

Enable the performance overlay to see real-time frame rendering:

```dart
MaterialApp(
  showPerformanceOverlay: true, // Toggle for debugging
  // ...
);
```

Or from the terminal while running: press `P` to toggle the performance overlay.

### What to look for

- **Red bars in the UI thread** — expensive `build()` methods. Optimize widget tree.
- **Red bars in the raster thread** — complex painting. Reduce use of `ClipRRect`, shadows, or large images.

---

## Quick Reference

| Action | Shortcut / Command |
|---|---|
| Hot Reload | `Ctrl+S` / `Cmd+S` (on save), `r` in terminal |
| Hot Restart | `Shift+R` in terminal, IDE restart button |
| Open DevTools | `Ctrl+Shift+P` > "Dart: Open DevTools" |
| Debug Console | `Ctrl+Shift+Y` / `Cmd+Shift+Y` |
| Toggle Performance Overlay | `P` in terminal |
| Screenshot | `s` in terminal |
| Toggle Platform | `o` in terminal |
