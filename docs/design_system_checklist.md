# Design System Checklist

Use this checklist during UI implementation and review for all high-traffic flows.

## Visual Consistency

- Use `DesignTokens` for spacing, corner radii, and shared card styles.
- Keep primary card surfaces on `ColorScheme.surface`.
- Use `outlineVariant` with subtle opacity for non-emphasis borders.
- Keep action hierarchy clear: one primary CTA per screen section.

## Typography

- Page title: `headlineSmall` / strong weight.
- Section title: `titleLarge` or `titleMedium`.
- Metadata/supporting text: `bodyMedium` with reduced opacity.
- Avoid multiple text styles with close visual weight in the same section.

## Interaction States

- Selected, correct, and error states must be distinguishable in both themes.
- Important toggles and segmented controls should remain explicit with labels.
- Primary actions should remain discoverable without scrolling where possible.

## Theme Parity

- Validate each changed screen in light and dark mode.
- Ensure selected chips/buttons preserve contrast in dark theme.
- Avoid hardcoded colors unless semantic (`error`, `primary`, success state).

## Quality Gate Before Merge

- Run `flutter analyze`.
- Run `flutter test`.
- Confirm no overflow/clip issues on narrow layout.
- Confirm localized strings still fit in key buttons and headers.
