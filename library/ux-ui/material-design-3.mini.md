# OBEY Material Design 3 by Google

## When to use

Use when designing, implementing, or reviewing Flutter UI that must be accessible, adaptive, visually consistent, and aligned with Google's design language. Applies to every screen, component, theme, and interaction in a Material-based Flutter app.

## Primary bias to correct

Material 3 is not a fresh coat of paint. It is a color-first, tonal-palette-driven system that replaces shadows with surface tinting, replaces hardcoded colors with semantic roles, and replaces legacy components with modern equivalents. Treating it as optional or cosmetic undermines accessibility and adaptive behavior.

## Decision rules

- Enable `useMaterial3: true` (default since Flutter 3.16) and never set it to false as a shortcut. The M2 flag and implementation will be removed.
- Generate the app's `ColorScheme` using `ColorScheme.fromSeed(seedColor: ...)`. Avoid manual `ColorScheme` definitions unless a specific brand palette demands it. Use `ColorScheme.fromImageProvider` for dynamic content-based schemes.
- Use `ColorScheme` roles everywhere (`colorScheme.primary`, `colorScheme.onSurface`, `colorScheme.tertiary`). Never hardcode hex values or `Colors.*` into widgets.
- Use `tertiary` for accent and illustrative elements. Do not overload `primary` with both brand and accent duties.
- Replace legacy navigation: `BottomNavigationBar` with `NavigationBar`, `Drawer` with `NavigationDrawer`, `ToggleButtons` with `SegmentedButton`.
- Replace legacy buttons: `FlatButton` with `TextButton`, `RaisedButton` with `ElevatedButton`, `OutlineButton` with `OutlinedButton`. Use `FilledButton` or `FilledButton.tonal` for medium-emphasis actions without elevation.
- Use `IconButton.filled`, `.filledTonal`, `.outlined` to express emphasis via tone, not only color.
- Rely on `ColorScheme.surfaceTint` for elevation indication, not drop shadows. Override `surfaceTint: Colors.transparent` only with explicit justification.
- Use semantic text styles from `Theme.of(context).textTheme` (`titleLarge`, `bodyMedium`, `labelSmall`). Never use ad hoc font sizes.
- Define component themes using `*ThemeData` classes (`CardThemeData`, `DialogThemeData`, `TabBarThemeData`), not `*Theme` widgets.
- Respect the 48x48 dp minimum touch target. M3 components conform by default; custom widgets must be verified.
- Verify contrast: 4.5:1 for body text, 3:1 for large text and icons. M3 tones help, but overrides can break compliance.
- Respect platform "reduce motion" preferences when adding custom animations.
- Provide both `theme` and `darkTheme` on `MaterialApp`. Use `ThemeMode.system` for automatic switching.
- Test at large accessibility font sizes. M3 text styles scale predictably, but layouts must be validated.
- Do not mix `NavigationBar` and `BottomNavigationBar` in the same app. Standardize on one.
- Do not mix hardcoded legacy colors with M3 tonal roles. Audit and remove all of them.
- Do not over-customize `surfaceTintColor` globally; it fights the tonal hierarchy.
- Prefer component defaults unless there is a specific brand reason. Overriding tints broadly makes the UI feel incoherent.
- Use `ThemeExtension` to add custom design tokens (success, warning, info colors) without hardcoding them into widgets.
- For adaptive apps, respect platform idioms: scrollbars visible on desktop, selectable text on web, button order per platform (Windows vs macOS/Linux).
- Solve touch-first. Layer mouse and keyboard as accelerators, not primary interactions.
- Do not lock orientation. Do not use `MediaQuery` orientation or `OrientationBuilder` near the top of the widget tree. Use `MediaQuery.sizeOf` or `LayoutBuilder` with adaptive breakpoints.
- Avoid checking device type (phone/tablet). Use window size via `MediaQuery` instead.
- Break complex widgets into small `const` widgets. This improves rebuild performance and keeps each widget's complexity manageable.
- Save and restore app state across configuration changes (rotation, resize, fold/unfold).

## Trigger rules

- When creating a new theme or updating `ThemeData`, verify all component properties use `*ThemeData` classes and that `ColorScheme.fromSeed` is the source of truth.
- When adding a new screen, confirm it uses semantic text styles, M3 color roles, and the correct navigation component for its context.
- When adding a custom widget, verify touch target size, contrast ratio, and that it does not introduce hardcoded colors.
- When a button uses `ElevatedButton` without needing elevation, switch to `FilledButton.tonal`.
- When the UI looks "strange" after upgrading Flutter, check for missing M2-to-M3 migration steps: color scheme, navigation components, button types, elevation surface tint.
- When implementing dark mode, verify both light and dark `ColorScheme` are derived from the same seed and that contrast ratios hold.
- When adding animation, check for platform reduced-motion preferences and provide alternatives.
- When adapting for large screens, use `LayoutBuilder` and Material adaptive breakpoints rather than device-type checks.
- When using `MediaQuery`, prefer `MediaQuery.sizeOf(context)` over accessing the full `MediaQueryData` to minimize rebuilds.
- When a component is reused across screens, extract its styling into a component theme rather than repeating inline overrides.

## Final checklist

- `useMaterial3` is true and `ColorScheme.fromSeed` generates the palette?
- All colors come from `ColorScheme` roles, not hardcoded values?
- Legacy components (`BottomNavigationBar`, `Drawer`, `ToggleButtons`, `FlatButton`, `RaisedButton`) fully replaced?
- Component themes use `*ThemeData` classes?
- Elevation indicated by `surfaceTint`, not raw shadows?
- Touch targets at least 48x48 dp?
- Contrast ratios verified (4.5:1 body, 3:1 large/icons)?
- Dark mode and light mode both functional and tested?
- Accessibility font sizes tested without layout breakage?
- No mixing of M2 and M3 patterns in the same app?
- Adaptive layout uses `sizeOf`/`LayoutBuilder`, not device-type checks?
- Platform idioms (scrollbars, button order, selectable text) respected on large screens?
