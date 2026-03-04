# ConfirmationSheet detents — manual check

This project uses a **content-measured detent** for `ConfirmationSheet` with an accessibility fallback.

## Quick simulator checklist

- **Sign Out sheet**
  - Navigate: Profile → Settings → Sign Out
  - Expected:
    - Sheet height fits content (no awkward empty space below buttons)
    - Drag indicator is visible
    - Corners match `MindsetLayout.radiusCardLarge`
    - Pulling up can expand to `.large`

- **Delete Account sheet**
  - Navigate: Profile → Settings → Delete Account
  - Expected:
    - Same fit/expand behavior as Sign Out
    - Confirm button uses destructive styling

- **Dynamic Type**
  - Settings app → Accessibility → Display & Text Size → Larger Text
  - Set to an **Accessibility** size (e.g. AX3)
  - Re-test both sheets
  - Expected:
    - Sheet uses `.large` detent (no clipped title/subtitle/buttons)
    - Text wraps without overlapping buttons

- **Small device**
  - Run on a smaller simulator (e.g. iPhone SE)
  - Expected:
    - Detent clamps below full height (no layout overflow)
    - Content remains reachable (drag to expand if needed)

