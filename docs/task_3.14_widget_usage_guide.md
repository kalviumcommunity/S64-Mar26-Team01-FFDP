# Choosing Between Stateless and Stateful Widgets

Understanding when to use a `StatelessWidget` versus a `StatefulWidget` is fundamental to efficient Flutter development and high-performance UI.

## 1. StatelessWidget: The Blueprint
A `StatelessWidget` is immutable. Its configuration is set when it's created and cannot change over time unless the entire widget is replaced by its parent with new data.

### When to use:
- The UI depends solely on info passed through the constructor.
- The widget doesn't need to rebuild itself dynamically.
- Performance is a priority (Stateless widgets are cheaper to build).

### Realistic Scenarios:
- **Static Text Labels:** Displaying a title or a fixed description.
- **Icons & Avatars:** Displaying an image or an icon based on a provided URL or name.
- **Reusable Buttons (Pure UI):** A button that takes an `onPressed` callback but doesn't manage its own internal visual state (like a primary action button).

---

## 2. StatefulWidget: The Dynamic Component
A `StatefulWidget` consists of two classes: the widget itself (immutable) and a `State` object (mutable). The `State` object persists across rebuilds.

### When to use:
- The widget needs to update its appearance based on user interaction.
- You need to manage internal logic (timers, animations, text input).
- You need to trigger local UI updates without affecting the entire screen.

### Realistic Scenarios:
- **Form Inputs:** As the user types, the widget needs to store and validate the text locally.
- **Checkbox/Switch:** Toggling a boolean value and updating the check/switch icon immediately.
- **Animations:** Managing a `Transition` or a `Controller` that changes values frame-by-frame.
- **Like/Favorite Buttons:** Toggling a "liked" state and possibly triggering a heart animation.

## Summary Comparison

| Feature | StatelessWidget | StatefulWidget |
| :--- | :--- | :--- |
| **Persistence** | Rebuilt from scratch every time | `State` object persists across builds |
| **Mutability** | Content is fixed once built | Content changes dynamically via `setState()` |
| **Overhead** | Very Low | Higher (due to State object management) |
| **Ideal for** | Presentational/Value-based UI | Interactive/Behavioral components |

> [!TIP]
> **Performance Rule of Thumb:** Always start with a `StatelessWidget`. Only upgrade to a `StatefulWidget` if the component specifically needs to maintain internal, mutable data or animations.
