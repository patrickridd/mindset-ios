//
//  RitualResult.swift
//  FeatureNavigation
//
//  Created by patrick ridd on 2/10/26.
//

/// Data transfer object (DTO) for the outcome of a completed morning ritual.
///
/// Used by the coordinator to pass ritual-completion data from the mindset flow (e.g. `MorningRitualView` / `MorningRitualViewModel`) into `RitualSuccessView` without FeatureMindset depending on FeatureNavigation or vice versa. The app layer (e.g. `AppViewFactory`) maps this DTO to the view’s parameters.
///
/// **Flow:** FeatureMindset reports success with `(archetype, xp)` → Coordinator stores or forwards a `RitualResult` → AppViewFactory creates `RitualSuccessView(archetype: result.archetype, xpEarned: result.xp, onDismiss: …)`.
///
/// **Conventions:**
/// - `archetype`: The user’s revealed mindset archetype label (e.g. "The Stoic Seeker", "The Explorer") for display as "Today’s Identity".
/// - `xp`: Experience points earned from the ritual; displayed in the success screen as "+N XP" and used for progress/gamification.
///
/// `Hashable` and value semantics support use in coordinator state (e.g. `FullScreenState.ritualSuccess`) and navigation identity.
public struct RitualResult: Hashable, Sendable {
    /// The mindset archetype label revealed for this ritual (e.g. "The Stoic Seeker").
    public let archetype: String
    /// Experience points earned from completing the ritual.
    public let xp: Int

    public init(archetype: String, xp: Int) {
        self.archetype = archetype
        self.xp = xp
    }
}
