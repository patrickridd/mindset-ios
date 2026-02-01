# Onboarding Flow Architecture

## 14-Step Flow Breakdown

```
┌─────────────────────────────────────────────────────────────┐
│                    ONBOARDING JOURNEY                        │
│             (Quiz First, Auth Last Strategy)                 │
└─────────────────────────────────────────────────────────────┘

1. INTRO/WELCOME                                    [FeatureOnboarding]
   └─ "5 minutes to build your mindset ritual"
   └─ Set expectations, build excitement
   
2. QUIZ (5 Questions)                               [FeatureOnboarding - ✅ DONE]
   └─ Q1: Headspace (overwhelmed, restless, content, focused)
   └─ Q2: Mental Muscle (resilience, gratitude, clarity, discipline)
   └─ Q3: Response to Setback (freeze, blame, reflect, pivot)
   └─ Q4: Habit Goal (consistency, depth, speed, variety)
   └─ Q5: AI Coach Tone (gentle, direct, inspiring, analytical)
   
3. ANALYZING                                        [FeatureOnboarding - ✅ DONE]
   └─ "Building your Identity Profile..."
   └─ Progress animation (2.5s investment moment)
   └─ Checklist: "Analyzing goals", "Calibrating Archetypes", etc.

4. ARCHETYPE REVEAL ⭐ (Hero Moment)                [NEW - FeatureOnboarding]
   └─ "Your Mindset Archetype: The Stoic Seeker"
   └─ Visual identity card (icon, description, strengths)
   └─ Creates ownership: "This is MY identity"
   └─ Tap to continue

5. PAIN SCREEN 1 (Overwhelm)                        [NEW - FeatureOnboarding]
   └─ Visual: Stressed person, dark clouds
   └─ "Feeling overwhelmed or restless?"
   └─ "You're not alone. 67% of people report daily stress."
   └─ Auto-advance after 3s (or tap to skip)

6. PAIN SCREEN 2 (Stuck)                            [NEW - FeatureOnboarding]
   └─ Visual: Person in maze/loop
   └─ "Stuck in the same mental patterns?"
   └─ "Most self-improvement fails because it's not personalized."
   └─ Auto-advance after 3s

7. PAIN SCREEN 3 (Habit Failure)                    [NEW - FeatureOnboarding]
   └─ Visual: Broken chain
   └─ "Failed to build a daily journaling habit before?"
   └─ "Apps that feel like work don't work. We make it fun."
   └─ Auto-advance after 3s

8. HOW APP CAN HELP                                 [NEW - FeatureOnboarding]
   └─ Feature grid (4 features):
      • Daily 5-min ritual (personalized prompts)
      • AI feedback (Gemini 2.0)
      • Streak tracking + XP
      • Yesterday Bridge (connect to past self)
   └─ Each feature: icon + 1-line description

9. SOCIAL PROOF                                     [NEW - FeatureOnboarding]
   └─ "Join 10,000+ members building their mindset"
   └─ Reviews carousel (3-5 testimonials)
   └─ Stats: "Average 47-day streak" "92% feel calmer"
   └─ App Store rating: ⭐⭐⭐⭐⭐ 4.8

10. AI COACH INTRODUCTION                           [NEW - FeatureOnboarding]
    └─ "Meet Your AI Coach"
    └─ Name: Based on archetype (e.g., "Sophia" for Stoic)
    └─ Avatar/icon
    └─ "Calibrated to your [Gentle/Direct/etc.] tone"
    └─ Sample insight based on quiz answers

11. CUSTOM PLAN                                     [NEW - FeatureOnboarding]
    └─ "Your Daily Mindset Ritual"
    └─ Timeline view (morning routine):
       • 5:00 AM - Wake up prompt
       • 5:02 AM - Gratitude (personalized)
       • 5:03 AM - Stoic reflection
       • 5:04 AM - Goal setting
       • 5:05 AM - AI analysis
    └─ Curated prompt categories based on quiz
    └─ "Start your 7-day free trial" CTA

12. SIGN IN WITH APPLE ⭐                           [FeatureAuth - ✅ DONE]
    └─ "Your Mindset Profile is Ready"
    └─ "Sign in to save progress and sync"
    └─ Benefits:
       • Secure & private with Apple
       • Sync across devices
       • Never lose streak
    └─ Apple Sign In button
    └─ "Continue without account" (anonymous)

13. PAYWALL                                         [FeatureSubscription - ✅ DONE]
    └─ Pricing options (Weekly, Monthly, Annual)
    └─ "7-day free trial, cancel anytime"
    └─ OR: Discounted Paywall (A/B test)
    └─ Purchase → RevenueCat + Firebase sync

14. MAIN APP (Dashboard)                            [FeatureDashboard - ✅ DONE]
    └─ First-time user: Tutorial overlay
    └─ Start daily ritual button
    └─ Streak: 0 days → "Start today!"
```

## Implementation Status

| Step | Screen | Status | Module | Priority |
|------|--------|--------|--------|----------|
| 1 | Intro/Welcome | ❌ TODO | FeatureOnboarding | P2 |
| 2 | Quiz | ✅ DONE | FeatureOnboarding | - |
| 3 | Analyzing | ✅ DONE | FeatureOnboarding | - |
| 4 | Archetype Reveal | ❌ TODO | FeatureOnboarding | **P0** (Hero moment!) |
| 5 | Pain Screen 1 | ❌ TODO | FeatureOnboarding | P1 |
| 6 | Pain Screen 2 | ❌ TODO | FeatureOnboarding | P1 |
| 7 | Pain Screen 3 | ❌ TODO | FeatureOnboarding | P1 |
| 8 | How App Can Help | ❌ TODO | FeatureOnboarding | P1 |
| 9 | Social Proof | ❌ TODO | FeatureOnboarding | P2 |
| 10 | AI Coach Intro | ❌ TODO | FeatureOnboarding | P1 |
| 11 | Custom Plan | ❌ TODO | FeatureOnboarding | P1 |
| 12 | Sign In (Auth) | ✅ DONE | FeatureAuth | - |
| 13 | Paywall | ✅ DONE | FeatureSubscription | - |
| 14 | Dashboard | ✅ DONE | FeatureDashboard | - |

**Priority Key:**
- P0 = Must have (hero moments, critical for conversion)
- P1 = Should have (value demonstration, pain points)
- P2 = Nice to have (polish, social proof)

## Navigation Flow (MainCoordinator)

```swift
enum Route: Hashable {
    case onboarding          // Steps 1-11 (FeatureOnboarding)
    case auth                // Step 12 (FeatureAuth)
    case paywall             // Step 13 (FeatureSubscription)
    case home                // Step 14 (Dashboard)
}

// Flow:
onboarding (quiz → analyzing → archetype → pain → features → plan)
    ↓
auth (Sign in with Apple)
    ↓
paywall (pricing, purchase)
    ↓
home (dashboard, start ritual)
```

## Data Flow

```
Quiz Answers (Local)
    ↓
UserProfile Created (SwiftData)
    ↓
Sign In with Apple (Firebase Auth)
    ↓
Firebase UID Generated
    ↓
Profile Synced to Firestore
    ↓
RevenueCat Login (Firebase UID)
    ↓
Paywall (Purchase)
    ↓
Subscription Status → Firebase + RevenueCat
    ↓
Dashboard (Load Profile + Streak)
```

## Key Design Decisions

### 1. Quiz First, Auth Last
**Why:** Duolingo-style value-first. Users invest time in quiz before friction.
**Result:** Higher conversion (invested users less likely to drop off).

### 2. Archetype Reveal = Hero Moment
**Why:** Creates personal ownership ("This is MY archetype").
**Result:** Differentiation from generic journaling apps.

### 3. Pain Screens Before Paywall
**Why:** Build urgency and emotional connection.
**Result:** Users understand WHY they need this, not just WHAT it is.

### 4. Auth Between Quiz and Paywall
**Why:** Can't purchase without auth anyway; profile ready to sync.
**Result:** Smooth transition, one friction point per stage.

### 5. Anonymous Fallback
**Why:** Lower barrier for trial users.
**Result:** Users can test before committing to account.

## Content Requirements

### Archetypes (Need to Define)
Based on quiz answers, possible archetypes:
- **The Stoic Seeker** - Resilience + reflection
- **The Gratitude Guide** - Appreciation + positivity
- **The Growth Mindset Builder** - Learning + discipline
- **The Clarity Cultivator** - Focus + mindfulness
- **The Purpose Pioneer** - Goals + achievement

Each archetype needs:
- Name
- Icon/visual identity
- 2-3 sentence description
- Key strengths (3-4 traits)
- Sample prompt focus areas

### Pain Screen Copy
Each pain screen needs:
- Visual asset (illustration or SF Symbol composition)
- Headline (question format)
- Stat or social proof line
- Emotional resonance

### AI Coach Names/Personas
Options:
1. **Single coach, multiple tones** - "Atlas" (gender-neutral)
2. **Different coaches per archetype** - Stoic = "Marcus", Gratitude = "Joy"
3. **User chooses name** - Customization moment

### Custom Plan Prompts
Show 3-5 curated prompts based on quiz:
- Headspace: overwhelmed → calming prompts
- Mental Muscle: gratitude → appreciation prompts
- Response: reflect → stoic prompts
- Habit Goal: consistency → daily rituals

## Conversion Funnel Metrics (Future)

Track drop-off at each step:
```
100% → Intro
 90% → Quiz Start
 75% → Quiz Complete (25% drop)
 70% → Archetype Reveal
 65% → Pain Screens
 60% → Features
 55% → Custom Plan
 50% → Auth (50% conversion to sign-in!)
 40% → Paywall
 25% → Purchase (25% final conversion = $100k MRR goal)
```

Target: 25-30% quiz → purchase conversion rate.

## A/B Test Ideas

1. **Archetype Reveal Position**: After quiz vs. after pain screens
2. **Pain Screen Count**: 3 vs. 2 vs. 1
3. **Auth Position**: Before paywall vs. after paywall
4. **Paywall Discount**: Standard vs. 50% off first month
5. **Trial Length**: 7 days vs. 14 days vs. 30 days

## Next Steps

1. ✅ **Firebase Setup** (30 min) - Follow FIREBASE_SETUP.md
2. ✅ **Integrate FeatureAuth** (15 min) - Add to MainCoordinator
3. **Build Archetype Reveal** (2 hours) - P0 hero moment
4. **Build Pain Screens** (3 hours) - P1 emotional connection
5. **Build AI Coach Intro** (2 hours) - P1 personalization
6. **Build Custom Plan** (3 hours) - P1 value demonstration
7. **Test Full Flow** (1 hour) - End-to-end validation

**Total estimated time for complete flow:** ~12 hours of development.

## Questions for Product Discussion

1. What are the 5 archetype names and descriptions?
2. Should AI coach have a name, or stay anonymous ("Your AI Coach")?
3. What's the target trial length? (7 days is standard, but 14 days may convert better)
4. Should pain screens be generic or personalized based on quiz answers?
5. Do you want to A/B test the Archetype Reveal position?
6. Should "Continue without account" allow full access or limited trial?

---

**Ready to build?** Start with Firebase setup, then tackle the hero moment (Archetype Reveal) next!
