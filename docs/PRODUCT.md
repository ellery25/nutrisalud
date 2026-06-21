# Product Overview

NutriSalud 2.0 — product vision, personas, feature inventory and growth levers. Technical counterpart: [ARCHITECTURE.md](ARCHITECTURE.md). Forward plan: [ROADMAP.md](ROADMAP.md).

## Vision

A **personalized nutrition ecosystem** for people who want to eat well *and* feel well — anchored in the underserved **digestive-health niche**. Most nutrition apps optimize calories; NutriSalud optimizes comfort: it connects what you eat (Discover/Recipes), how you feel afterwards (Journal), the habits you build (Goals), what you learn (Digestive Health Center) and who you share it with (Community). The long-term arc: from self-tracking companion → insight engine (food↔symptom correlations) → trusted bridge to verified professionals.

## Personas

**1. Dani — lives with IBS / digestive discomfort (primary).** Gets bloating/reflux after meals but can't pin down triggers; overwhelmed by contradictory internet advice. Needs: a frictionless way to log meals + symptoms, plain-language education (what IBS is, what low-FODMAP actually means), and gut-friendly recipe ideas. Success: spots a pattern within 2–3 weeks of journaling and feels in control.

**2. Sam — health-conscious home cook.** No diagnosis, just wants variety and better habits. Needs: fast meal discovery by ingredient ("what can I make with chicken?"), saved favorites, and light habit tracking (water, fruits & veg, home-cooked meals) with streaks for motivation. Success: cooks at home more and keeps a streak alive.

## Feature inventory & flows

- **Meal discovery (Discover tab)** — open Discover → type a query (debounced) or toggle *By name / By ingredient* → or browse category chips → tap a meal card → recipe details. Powered by TheMealDB.
- **Recipe center** — recipe screen shows hero image, category/area/tags, ingredients with measures, numbered steps, related meals from the same category, YouTube/source links → heart icon saves to Favorites (offline, local).
- **Food & symptom journal (Journal tab)** — open tab → FAB "Log meal" → pick meal type (breakfast/lunch/dinner/snack), describe the meal, tag digestive symptoms (bloating, heartburn, nausea, cramps, constipation, diarrhea) + severity 0–3, optional notes → entry appears in the timeline; weekly card shows meals logged, symptom days and a 7-day bar chart (`week_bar_chart.dart`).
- **Nutrition goals & streaks (Home → Goals)** — FAB "New goal" → choose type (water, fruits & veg, home-cooked meals, mindful eating, custom) + daily target → check in with +/− during the day → streak days and 7-day completion ring/bars; today's goals surface on Home.
- **Digestive Health Center (Learn tab)** — browse curated articles filtered by topic chips (digestive health, IBS-friendly, gut health, intolerances, nutrition basics, habits) → article view with read time, author profile link and an always-on educational disclaimer → specialist profiles list their topics and authored articles.
- **Community (Community tab)** — feed of member posts (text + optional photo, compressed before upload) → FAB to post → delete your own posts. Backed by the legacy Flask API.
- **Onboarding & auth** — welcome → register/login (JWT) → 3-step intro carousel → home. Route guards make the flow non-skippable but one-time.
- **Profile & settings** — display name, theme mode (system/light/dark), meal & hydration reminder toggles, logout.

## What replaced the legacy "Doctors" section — and why

Legacy NutriSalud listed "doctors" with no verification, no credentials and no booking — a liability for a health app. 2.0 reframes it as the **Learn hub**: educational specialist *profiles* (`SpecialistProfile` with explicit kinds: nutritionist, gastroenterologist, fitness coach, institution, creator, plus a `verified` flag) that author curated articles. The honest framing today is education, not referral. The architecture is already prepared for the upgrade: UI consumes the **`ContentRepository` interface** (`lib/features/educational_content/data/content_repository.dart`), so a remote **verified practitioner directory** can replace `CuratedContentRepository` without UI changes, and booking UI is pre-gated behind the `specialists_booking_enabled` remote-config flag.

## Monetization readiness

- A **`premium_enabled` flag already exists** in `ConfigFlags` (`lib/core/services/remote_config_service.dart`, default `false`) — premium gating can be turned on server-side once `RemoteConfigService` is backed by a real flags source.
- Natural premium surface: journal insights/correlations, recipe collections, specialist booking; free tier keeps discovery, basic journal and Learn content.
- Billing itself (e.g. RevenueCat) is a [Later roadmap item](ROADMAP.md).

## KPIs (instrument via `AnalyticsService`)

`AnalyticsService` (`lib/core/services/analytics_service.dart`) is already called for `login` and `register`; extend with:

| KPI | Event(s) |
| --- | --- |
| Activation | onboarding completed; first journal entry within 48 h |
| Journal engagement (core) | `journal_entry_added` — entries/user/week, % entries with symptoms |
| Discovery engagement | `recipe_viewed`, `meal_favorited`, search count per session |
| Habit retention | `goal_checkin` — streak length distribution, D7/D30 retention |
| Education depth | `article_opened` + read-through, topic popularity |
| Community health | `post_created` per WAU, photo attach rate |
| Reminder opt-in | notification toggles enabled (proxy for re-engagement potential) |
