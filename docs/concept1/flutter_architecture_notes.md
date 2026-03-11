# Flutter Architecture Notes

## Core Philosophy
- **Everything is a Widget**: Structural elements (buttons), stylistic elements (fonts), and even layout aspects (padding) are all widgets.
- **Composition**: Complex layouts are created by nesting simple widgets instead of using traditional inheritance models.

## The Three Trees
Flutter's efficiency stems from managing three distinct tree structures:

1. **Widget Tree**: 
   - Immutable blueprints/configurations.
   - Extremely lightweight to create and destroy.
   - Rebuilt frequently during state changes.

2. **Element Tree**: 
   - Represents the logical structure of the UI.
   - Instantiated from widgets.
   - Manages the lifecycle and state (for StatefulWidgets).
   - Updates references when a new widget is provided at the same location.

3. **RenderObject Tree**: 
   - Handles the actual layout (sizes, positions) and painting (pixels on screen).
   - Expensive to create.
   - Caches geometric metrics and only recalculates when specifically informed that an Element has genuinely changed layout constraints or visual properties.

## State Management Basics
- **StatelessWidget**: UI depends only on the configuration information in the object itself. 
- **StatefulWidget**: UI can change dynamically based on internal state or external events. Uses a separate `State` class that persists across `build()` calls.
- **setState()**: Triggers a rebuild of the widget's subtree. Should be used thoughtfully to avoid unnecessary large-scale rebuilds.

## Rendering Pipeline
1. **User Input / Animation Tick**: Event triggers a state change.
2. **Build**: Flutter traverses the widget tree and calls `build()` where state changed.
3. **Layout**: Calculates sizes and positions (Constraints flow down, sizes flow up, parents set positions).
4. **Paint**: Generates rendering instructions.
5. **Composite**: Combines painted layers and sends them to the GPU.
