# Nested Navigation with StatefulShellRoute

## Overview

In Task 3.45, we implemented a robust navigation system using `go_router`'s `StatefulShellRoute`. This allows for a persistent `BottomNavigationBar` while maintaining the state of each tab independently.

## Logic Breakdown

### 1. The Main Scaffold (`lib/screens/main_scaffold.dart`)
The `MainScaffold` is our primary layout shell. It takes a `StatefulNavigationShell` which contains the current branch's state. 
- **Persistence**: When switching tabs, the branches are not rebuilt from scratch. Instead, their state is preserved in an `IndexedStack`.
- **Navigation**: The `onTap` handler uses `navigationShell.goBranch(index)` to switch between the 5 main tabs (Home, Search, Map, Chat, Profile).

### 2. The Router Configuration (`lib/config/router.dart`)
The router defines 5 independent `StatefulShellBranch` objects within a `StatefulShellRoute`. Each branch acts as its own navigator stack.
- **Independent Stacks**: If a user navigates deep into a "Search" detail page and then switches to "Home" and back to "Search", they will still be on the "Search" detail page.
- **Clean Structure**: This approach cleanly separates the navigation logic from the UI components.

## How to use in the App

1. **Adding a new tab**: Add a new `StatefulShellBranch` in `router.dart` and a corresponding `BottomNavigationBarItem` in `main_scaffold.dart`.
2. **Deep Linking**: `go_router` handles URLs automatically for each branch (e.g., `/search`, `/profile`).
3. **Preserving Scroll State**: Because branches are preserved in Memory, list scroll positions are naturally maintained when switching tabs.

## Best Practices

- **Avoid Global Keys**: Let `go_router` handle the navigation state.
- **Initial Location**: We use `initialLocation: index == navigationShell.currentIndex` in the `_onTap` method to reset the branch if the user taps the same tab icon again (standard behavior for reset-to-root).
