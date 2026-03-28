# Animations and Transitions Guide

## Our Approach to UX Enhancement

Animations and transitions are more than just visual flair; they are essential for providing feedback, guiding the user's attention, and making the application feel responsive and "alive."

### 1. Micro-interactions

Micro-interactions are small, functional animations that respond to user actions. We use them for:
- **Button Feedback**: Subtle scale or color changes on tap.
- **Toggle States**: Smooth transitions between active and inactive states (e.g., our `AnimatedLikeButton`).
- **Input Validation**: Gentle shakes or color shifts on error.

### 2. Page Transitions

Consistent page transitions help users understand the relationship between different screens.
- **Fade Transitions**: Used for main level navigation to provide a clean, non-obtrusive change.
- **Slide Transitions**: Used for hierarchical navigation (e.g., drilling down into details) to indicate the flow of content.

### 3. Loading States

Loading states should reduce the perceived wait time and reassure the user that the app is still working.
- **Stylized Loaders**: We use themed, visually interesting loaders instead of standard system indicators.
- **Bouncing Animations**: These create a sense of activity and progress.

## Best Practices

- **Keep it Subtle**: Animations should be fast (generally 200-400ms) and not a distraction from the core task.
- **Consistency**: Use the same curves and durations for similar actions across the app.
- **Performance**: Favor `ImplicitAnimations` and optimized `AnimationControllers` to ensure 60fps performance on all devices.
