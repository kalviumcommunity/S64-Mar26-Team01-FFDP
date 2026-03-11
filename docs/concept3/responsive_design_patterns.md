# Responsive Design Patterns & Breakpoint Strategy

To ensure our application provides an optimal experience across both mobile and tablet devices, we are adopting a structured breakpoint strategy based on standard screen widths.

## Breakpoint Definitions

We define our breakpoints based on screen width (in logical pixels):

- **Mobile (Small to Standard)**: Width < 600px
  - *Target Devices*: All smartphones (iPhone SE up to Pro Max, standard Android phones).
  - *Layout Strategy*: Single-column layouts. Navigation primarily uses `BottomNavigationBar` or `Drawer`. Elements occupy maximum available width to maximize readability and interaction areas.
- **Tablet (Portrait & Landscape)**: Width >= 600px and < 900px
  - *Target Devices*: iPads (Mini, Standard, Pro 11"), standard Android Tablets.
  - *Layout Strategy*: Multi-column layouts where applicable. Navigation may shift to a `NavigationRail` or persistent side drawer to utilize horizontal real estate. Dialogs instead of full-screen pushing for secondary views. `GridView` components show more items per row to prevent excessive white space.
- **Desktop / Web (Optional Expansion)**: Width >= 900px
  - *Target Devices*: Larger tablets in landscape, Web browsers, Desktop apps.
  - *Layout Strategy*: Prominent sidebar navigation, multi-pane views (e.g., list on left, details on right for master-detail flow). Max-width constraints on central content to prevent extreme stretching and unreadably long text lines.

## Implementation Guidelines
Instead of scattering `MediaQuery` everywhere, we recommend using a dedicated helper class to determine the device type dynamically. This keeps our layout logic clean and centralized:

```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    required this.mobile,
    required this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900 && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= 600) {
          return tablet;
        } else {
          return mobile;
        }
      },
    );
  }
}
```
This isolates the breakpoint logic and allows developers to supply entirely different widget trees if needed for drastic layout shifts (e.g., a standard `ListView` for mobile versus a complex `GridView` or Master-Detail layout for a tablet).
