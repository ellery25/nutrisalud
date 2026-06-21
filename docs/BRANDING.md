# Branding & Design System

The NutriSalud 2.0 visual identity, implemented in `lib/core/themes/` (`app_colors.dart`, `app_theme.dart`, `app_spacing.dart`) and mirrored by the landing page (`landing/index.html`). Usage rules for developers: [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md#project-conventions).

## Brand audit summary (legacy → 2.0)

Legacy 1.x had no design system: at least three competing greens (`#527450`, `#6BA368`, `#3A5A40`) used interchangeably, colors and text styles hardcoded per widget, no dark mode, and no type scale — visual drift on every new screen. 2.0 fixes the root cause: **one seed color, one generated Material 3 `ColorScheme` per brightness, and tokens instead of magic numbers**. Brand constants exist in exactly one file (`AppColors`); everything else reads `Theme.of(context).colorScheme`.

## Brand attributes

Modern · trustworthy · medical · healthy · friendly. The greens were kept from the original identity but recalibrated for WCAG AA contrast on light and dark surfaces.

## Palette

| Name | Hex | Usage |
| --- | --- | --- |
| `brandGreen` | `#3E7C3A` | Primary. **Seed** for `ColorScheme.fromSeed`; primary actions, active states, logo tint |
| `brandGreenDark` | `#2C5E2E` | Deep green for emphasis/gradients (landing hero) |
| `leaf` | `#6BA368` | Legacy light green, retained for continuity in illustrations/accents |
| `lime` | `#A3C9A0` | Soft green for subtle fills and decorative surfaces |
| `apricot` | `#E8A04C` | Warm, food-friendly accent; also semantic **warning** |
| `berry` | `#B6465F` | Secondary accent for highlights (sparingly) |
| `offWhite` | `#FAFAF7` | Light surface / scaffold background; splash background |
| `charcoal` | `#1C1F1C` | Ink/near-black for landing typography |
| `success` | `#3E7C3A` | Positive states (goal completed) |
| `warning` | `#E8A04C` | Caution states |
| `danger` | `#C94F4F` | Destructive/error states |

In-app, prefer scheme roles (`primary`, `primaryContainer`, `surfaceContainerLow`, `error`…) over raw constants — the scheme guarantees readable on-colors in both modes.

## Typography

System font with the Material 3 type scale (no bundled font in-app; the landing page uses Inter, its web analogue). Weight rules:

| Weight | Use |
| --- | --- |
| 400 Regular | Body text, descriptions |
| 600 Semibold | Buttons (`FilledButton` text), emphasized labels |
| 700 Bold | App bar titles, section headers, card titles |
| 800 Extrabold | Hero/display moments only (landing, welcome) |

Never set raw `fontSize`; use `textTheme` styles (`titleLarge`, `titleMedium`, `bodyMedium`, `labelMedium`) with `copyWith` for weight/color.

## Spacing & radius tokens

From `lib/core/themes/app_spacing.dart` — a 4pt scale. No magic numbers in layout code.

| Token | Value | | Token | Value |
| --- | --- | --- | --- | --- |
| `AppSpacing.xs` | 4 | | `AppRadius.sm` | 8 |
| `AppSpacing.sm` | 8 | | `AppRadius.md` | 12 |
| `AppSpacing.md` | 16 | | `AppRadius.lg` | 16 |
| `AppSpacing.lg` | 24 | | `AppRadius.xl` | 28 |
| `AppSpacing.xl` | 32 | | | |
| `AppSpacing.xxl` | 48 | | | |

Defaults baked into `AppTheme`: cards `AppRadius.lg`, buttons/inputs `AppRadius.md`, chips `AppRadius.sm`, search field `AppRadius.xl` (pill).

## Component rules

- **`FilledButton`** is the single primary action per screen (min size 64×48); `OutlinedButton` for secondary actions.
- **Tonal cards**: elevation 0, `surfaceContainerLow` fill, rounded `lg` — depth via tone, not shadows.
- **`NavigationBar`** (M3) for the 5 tabs, labels always shown, `primaryContainer` indicator.
- **Chips / segmented buttons** for filters (Learn topics, Discover search mode) — never dropdowns for ≤6 options.
- **Floating SnackBars** with rounded corners for feedback; `EmptyState`/`ErrorState` widgets for non-happy paths.

## Dark mode

One theme builder serves both modes: `ColorScheme.fromSeed(seedColor: AppColors.brandGreen, brightness: Brightness.dark, surface: Color(0xFF121512))` — a green-tinted near-black instead of pure black, with `offWhite` as the light counterpart. The native splash also pairs `#FAFAF7` / `#121512`. Theme mode (system/light/dark) is user-selectable and persisted (`themeModeProvider`).

## Accessibility commitments

- WCAG AA contrast for text on all surfaces in both modes (the seed-generated scheme provides matched on-colors; brand greens were recalibrated for this).
- Minimum 48dp touch targets (enforced via button `minimumSize` in `AppTheme`).
- Semantics labels/tooltips on icon-only buttons (e.g. Favorites and Clear-search `IconButton`s carry tooltips; `BrandLogo` has `semanticsLabel`).
- Honors platform text scaling and `VisualDensity.adaptivePlatformDensity`.

## Logo usage

Single-color SVG (`assets/svgs/NutrisaludLogo.svg`) rendered by the `BrandLogo` widget (`lib/shared/widgets/brand_logo.dart`), which tints it with `colorScheme.primary` by default — so it adapts to light/dark automatically. Don't ship multi-color or raster variants in-app; pass an explicit `color` only for on-primary contexts.

## Voice & tone

Supportive and plain-language: "Log meal", "No meals found — try a different search term." Avoid clinical jargon and moralizing about food. **Never diagnostic**: content explains, it does not prescribe — every educational article ends with the standard disclaimer pointing readers to qualified healthcare professionals (see `_disclaimer` in `lib/features/educational_content/data/content_repository.dart`).
