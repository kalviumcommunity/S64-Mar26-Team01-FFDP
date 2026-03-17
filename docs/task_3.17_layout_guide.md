# Layout Guide: Responsive Design & Reusable Components

This guide explains how to use the newly created layout and responsiveness utilities to ensure a consistent, adaptable UI across the app.

## 1. ResponsiveGrid
The `ResponsiveGrid` utility dynamically switches its layout strategy based on the available screen width.

### How it works:
- **Mobile (< 600px width):** Children are stacked vertically in a standard `Column`. Spacing is automatically injected between elements.
- **Tablet/Desktop (>= 600px width):** Children flow horizontally in a `Wrap`, automatically bumping down to the next row when horizontal space runs out.

### Usage Example:
```dart
import 'package:your_app/utils/responsive_grid.dart';

// Inside your widget's build method
ResponsiveGrid(
  breakpoint: 600.0, // Optional: defaults to 600
  spacing: 16.0,     // Gap between items
  children: [
    MyDashboardCard(title: "Users", count: 150),
    MyDashboardCard(title: "Revenue", count: 4200),
    MyDashboardCard(title: "Active Tasks", count: 12),
  ],
)
```

## 2. Layout Components

We have defined standardized container wrappers in `lib/widgets/layout_components.dart` to maintain visual consistency.

### PageContentWrapper
Every main screen's `Scaffold.body` should ideally start with this wrapper. It automatically applies a `SafeArea` to avoid system UI overlays (like notches or gesture bars) and applies standardized horizontal padding.

```dart
Scaffold(
  appBar: AppBar(title: Text('Settings')),
  body: PageContentWrapper(
    child: Column( ... ), // Your page content goes securely here
  ),
)
```

### AppCard
Use `AppCard` instead of generic `Container`s when you want to group related information in a visually distinct elevated block. It handles padding, border radius, and Material 3 elevation shadows automatically. It also supports optional `onTap` actions.

```dart
AppCard(
  onTap: () => print("Card Tapped!"), // Optional InkWell ripple effect
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Card Title", style: Theme.of(context).textTheme.titleMedium),
      SizedBox(height: 8),
      Text("Card descriptive body text goes here."),
    ],
  ),
)
```
