# Handoff: Lama Lama Rangers — Field Ops App

## Overview
A mobile-first field operations app for Indigenous rangers managing Lantana weed infestations on Cape York country (Port Stewart, QLD). The app works **offline-first** — no internet required on core views — and uses **device-to-device mesh sync** at end of day. It's built for outdoor use in direct sunlight with large tap targets and high-contrast type.

Target stack: **SwiftUI + iOS 18** (native). A React Native / Expo build is an acceptable fallback if native isn't viable. Do not introduce third-party UI libraries — use system components for native feel.

## About the Design Files
The files in `prototype/` are **design references** — a working HTML/React prototype built to communicate intended look, layout, and behavior. They are **not production code to copy**. Your task is to **recreate these designs in SwiftUI** using Apple's native components (`NavigationStack`, `TabView`, `Sheet`, `List`, `Form`, `Map`, etc.), patterns (`@State`, `@Observable`, `SwiftData` for offline storage), and Human Interface Guidelines — while matching the visual design (colors, type, layout, interactions) shown in the prototype.

Open `prototype/Lama Lama Rangers.html` in a browser to interact with the reference. The `prototype/screens/*.jsx` files contain detailed React implementations of each screen you can read for reference.

## Fidelity
**High-fidelity.** All colors, type scale, spacing, layouts, and interactions are final and should be reproduced pixel-close. The app's identity is the earthy palette, the ochre accent for actions, and the calm/grounded copy voice — preserve these carefully.

---

## Design Tokens

### Colors
```swift
// Surfaces
paper        #F4EFE4   // primary background (sunbleached parchment)
paperDeep    #EAE1D0   // recessed / muted surface
card         #FFFBF2   // elevated card
line         rgba(58,50,32,0.12)   // hairline divider
lineStrong   rgba(58,50,32,0.22)   // stronger divider / border

// Primary — deep eucalyptus
euc          #2E4634
eucDark      #1E2F22
eucLight     #4A6951
eucSoft      #DCE3D8

// Accent — burnt ochre (all CTAs, active tab)
ochre        #C26A2A
ochreDeep    #9B4F1C
ochreSoft    #F3DEC5

// Bark
bark         #5A4632
barkSoft     #A89178

// Status (zone)
active       #B8322A     activeSoft   #F2D7D3
treat        #C89231     treatSoft    #F5E2BE
cleared      #4A7A4A     clearedSoft  #D6E4CF

// Sync
synced       #4A7A4A (green)
pending      #C89231 (amber)
conflict     #B8322A (red)

// Ink (text)
ink          #1F1A10   // primary text
ink2         #3A3220   // secondary
ink3         #6B5F4A   // tertiary / captions
inkMute      #8F8471

// Lantana variants (pin + swatch color)
pink         #D46E8E   orange  #E08A3C   red     #B8322A
yellow       #D9B03A   white   #E8DFCE   pale    #E8B6B9
```

### Typography
Use SF Pro system font. Three faces:
- **Body / UI:** `-apple-system` (`SF Pro Text`) — 11–17pt
- **Display / titles:** `SF Pro Display` — 15–30pt, weight 600–800
- **Rounded (PIN pad digits, playful moments):** `SF Pro Rounded`
- **Monospace (GPS coords, dates, timer):** `SF Mono` / `ui-monospace`

Scale used (px values from prototype; map 1:1 to pt in SwiftUI):
| Use | Size | Weight | Tracking |
|---|---|---|---|
| Large screen title | 28pt | 700 | -0.6 |
| Wordmark (Login) | 30pt | 800 | -0.8 |
| Card title | 15–18pt | 700 | -0.3 |
| Body | 13–14pt | 500–600 | -0.2 |
| Caption | 11–12pt | 500–600 | 0 |
| Label ALL-CAPS | 10–12pt | 600–700 | +0.4 to +2.2 (ALL CAPS) |
| Pin digits | 28pt | 500 rounded |  |
| Patrol timer | 42pt | 600 monospace |  |

### Spacing
Base scale: **4, 6, 8, 10, 12, 14, 16, 18, 20, 24, 40**. Card inner padding = 14 or 16. Screen horizontal padding = 16.

### Border radius
- Chip / pill: `9999` (full)
- Small tag: 8–10
- Card: 14–18
- Large card / modal: 18–22
- Sheet top: 22
- PIN button: 18

### Shadows
- Card: `0 1px 2px rgba(40,30,10,0.04)`
- Floating button / selected map card: `0 6px 20px rgba(155,79,28,0.45), 0 2px 4px rgba(0,0,0,0.12)`
- Sheet: `0 -8px 24px rgba(0,0,0,0.22)`
- Modal/toast: `0 8px 24px rgba(0,0,0,0.3)`

### Tap targets
**Minimum 44×44pt** — outdoor field use in sunlight. PIN digits are 64pt. FAB is 60pt.

---

## Screens (11)

### 1. Login / PIN Entry (`screens/login.jsx`)
**Purpose:** Offline-first ranger sign-on.
- Top ~160pt header: stylized Cape York coastline motif (topographic contour SVG + ridge silhouettes + sun). Not a literal map — decorative.
- Wordmark "Lama Lama" (euc) / "Rangers" (ochre), 30pt 800.
- **Step 1:** Ranger card list (avatar-dot + name + role + chevron). Tap → step 2.
- **Step 2:** Back button, ranger summary row, 4 PIN dots, numeric 3×4 keypad. On 4 digits, auto-submit. `0000` triggers a horizontal shake animation (0.45s) and resets.

### 2. Dashboard / Home (`screens/dashboard.jsx`)
**Purpose:** At-a-glance status after sign-on.
- Greeting: "G'day, {firstName}." + season/status subline.
- Sightings line chart card: 6 months × 6 variant lines (each variant's signature color, 1.8pt stroke, 2.4r dot markers at each data point). Grid: 3 dashed horizontal lines. Legend below in 3-column grid with small color bar + variant name.
- Zone status donut (118pt) + 3 stat rows (active/treating/cleared) **alongside** two stacked stat cards (Open tasks, Treatments this month).
- "Recent sightings" (3 items) list card with "See all" link — tappable rows route to detail.

### 3. Map View (`screens/map.jsx`)
**Purpose:** Primary situational awareness.
- Full-bleed map. Two modes: **satellite** (procedural earth-tone SVG backdrop) and **standard** (light tan with road lines). In SwiftUI use `Map` with `MKMapType.hybrid` / `.standard`.
- **Pins:** variant-colored drop markers with white inner dot + white outline. Tap → selected card at bottom.
- **Zone polygons:** semi-transparent fill (32% opacity) + dashed 1.6pt stroke, colored by status (active/treat/cleared).
- **Top chrome:** location chip top-left (Port Stewart, lat/lng); two stacked icon buttons top-right (map type toggle, layers toggle).
- **Layer panel:** dropdown card with 3 checkboxes (Sightings / Zones / Patrol routes).
- **FAB:** bottom-right, 60pt, ochre, `+` icon → opens Log Sighting sheet.
- **Legend:** three small pill chips bottom-left.

### 4. Log New Sighting — Bottom Sheet (`screens/sightings.jsx` → `LogSightingSheet`)
**Purpose:** Fastest-possible capture in the field.
- Slide-up sheet, 22pt top radius, with grabber.
- **GPS badge row:** mono lat/lng + "accuracy ±4 m" + green "Good" chip.
- **Variant picker:** 3×2 grid of variant cards. Selected card goes solid (variant color bg + white text).
- **Size picker:** 3-segment (Small `<1m²`, Medium `1–10m²`, Large `>10m²`). Selected = euc filled.
- **Photos:** up to 3 striped placeholders + dashed "Take photo" tile.
- **Notes:** 76pt textarea.
- **Submit** (ochre, full-width, disabled until variant+size picked) with "Saved locally, will sync later" caption.

### 5. Sightings List (`screens/sightings.jsx` → `SightingsListScreen`)
- Large title + subline ("N records · X not yet synced").
- **Filter bar:** horizontal scroll chips. "All" + 6 variant chips (variant color dot, active = variant-color fill).
- **Cards:** 5pt variant-color left stripe + title row (variant name + size chip) + meta row (ranger · zone · when) + sync badge.

### 6. Sighting Detail (`screens/sightings.jsx` → `SightingDetailScreen`)
- TopBar (chevron back, "Sighting", ellipsis).
- 140pt map thumbnail with pin.
- Facts card: icon + variant name + size/zone + sync badge; 2×2 grid of labeled facts (Logged by, When, GPS mono, Accuracy); notes block in recessed `paperDeep`.
- Treatments accordion (expandable): per-treatment row with drop icon + method + date/by; "Add treatment" button at bottom.

### 7. Variant Guide (`screens/guide.jsx`)
- Large title "Lantana guide".
- **Biocontrol banner** (Nov–Mar, Pink variant): ochre-soft card with alert icon, "Don't apply foliar spray on flowering pink plants" message.
- 2-column grid of 6 variant cards: header band with variant gradient + leaf icon + optional "Biocontrol" tag; footer with name + "Lantana camara".
- **Variant detail screen:** 200pt gradient hero with variant name in display type + leaf icon circle; biocontrol sub-banner if Pink; "How to spot it" feature list; "Control methods" numbered steps (1,2,3 in euc-soft circles); "Seasonal note".

### 8. Pesticide Inventory (`screens/guide.jsx` → `InventoryScreen`)
- List of herbicides as cards. Each card:
  - Icon tile (drop) colored by stock level (green / amber / red)
  - Title + kind + amount remaining / total
  - Low/Getting low pill on the right if applicable
  - Progress bar (8pt, paperDeep track, tone-colored fill)
  - "View usage log" text link + "Log usage" filled button
- Expanded drawer shows last 3 uses (mono date, ranger · location, volume).

### 9. Tasks (`screens/ops.jsx` → `TasksScreen`)
- TopBar with + button; filter chips (All · N / Mine / Done).
- Cards with 26pt circle checkbox + title + 3 meta chips: priority (High=red / Med=amber / Low=green soft), due date chip with calendar icon, ranger initials chip.
- **Swipe-to-complete:** tap card reveals 84pt green "Done" action behind; in SwiftUI use `.swipeActions`.
- Completed tasks: strike-through, muted bg.

### 10. Patrol (`screens/ops.jsx` → `PatrolScreen`)
- Calendar strip: 7 days, today filled in euc, bottom dot in ochre for patrol days.
- **Idle state:** pre-departure checklist (5 items, ticked checkboxes), zone picker dropdown, "Start patrol" button (dark, disabled until all ticked).
- **Active state:** euc header with mono HH:MM:SS timer (42pt), "2.1 km covered · 3 sightings logged" meta; field notes textarea; red "End patrol" button.

### 11. Mesh Sync (`screens/ops.jsx` → `MeshSyncScreen`)
- TopBar with "End-of-day sync" title + "No internet needed · device-to-device" subtitle.
- **Discovery phase:** dark eucalyptus card with central ochre avatar (current device), 3 radiating ring animations at 0s/0.8s/1.6s delays scaling 0.4→2.2 over 2.4s. Peer list below — tap a peer to start sync.
- **Syncing phase:** rotating sync icon next to selected peer, "Syncing…" label.
- **Conflict phase:** "Which version to keep?" — 2-column diff card showing both versions (label, size, ranger+when, note). Selected version gets euc-soft bg + top border. "Keep this version" button.
- **Done:** check icon + "All caught up" + 3 stat tiles (Sent / Received / Resolved).

### More screen
- Ranger profile card (avatar, name, role, Offline pill).
- 2×2 grid of shortcut tiles (Mesh sync, Tasks, Pesticide stock, Sighting history).
- Help & About list. Sign off (ghost button).

---

## Tab Bar
Fixed bottom, 5 tabs: **Map / Sightings / Patrol / Guide / More**. Active tint = ochre. Icon line weight thickens slightly on active (2.2 vs 1.8). Label 10.5pt, 700 when active. Use SwiftUI `TabView` with `.tint(.ochre)`. Hide on detail / modal routes.

## Navigation
- Auth gate (no ranger → Login).
- Authenticated root = `TabView`.
- Stack routes layered over tabs: Sighting detail, Variant detail, Tasks, Inventory, Mesh sync.
- Log Sighting is a sheet, not a stack push.

## State Management
Model using SwiftData (or Core Data) — all data is **local-first**:
- `Ranger { id, name, role, initials, toneHex }`
- `Zone { id, name, status: active|treat|cleared, areaHa, primaryVariantId }`
- `Sighting { id, variantId, rangerId, timestamp, zoneId, size: small|medium|large, syncStatus: synced|pending|conflict, lat, lng, accuracyM, notes, photos: [URL] }`
- `Treatment { id, sightingId, method, date, rangerId, productId, volume }`
- `Task { id, title, priority: high|med|low, dueDate, assignedRangerId, done }`
- `Herbicide { id, name, kind, stockFraction, totalCapacity, unit, usageLog: [Usage] }`
- `Patrol { id, rangerId, startedAt, endedAt?, zone, checklist, notes }`

Mesh sync uses **MultipeerConnectivity** for device discovery; conflict resolution uses last-write-wins unless both sides edited within a tolerance window, in which case surface the conflict UI.

## Interactions & Animations
- **PIN shake:** 0.45s ease, ±8px horizontal oscillation.
- **Sheet open:** translateY 100% → 0, 0.28s ease; scrim fade 0.18s.
- **Mesh sync rings:** scale 0.4→2.2 + opacity 0.7→0, 2.4s loop, 3 rings at staggered 0.8s offsets.
- **Sync icon spin:** 1.2s linear infinite rotate.
- **Swipe reveal:** 0.2s ease translateX(-84px).

## Copy voice
Warm, plain-English, local Queensland voice. Key phrases used:
- "G'day, {name}."
- "Who's signing on today?"
- "Good to see you."
- "5 rangers on country · offline mode"
- "Saved locally, will sync later"
- "All caught up"
- "What's on country today?"
- Status words: "Active / Treating / Cleared" (not "In Progress / Complete")

## Icons
All icons in the prototype are **inline SVG line icons** (see `atoms.jsx` `Icon` component). In SwiftUI use **SF Symbols** — direct mappings:
| Prototype | SF Symbol |
|---|---|
| map | `map` |
| eye | `eye` |
| foot | `figure.walk` |
| book | `book` |
| more | `ellipsis` |
| plus | `plus` |
| x | `xmark` |
| check | `checkmark` |
| chev-right/left/down | `chevron.right/.left/.down` |
| filter | `line.3.horizontal.decrease` |
| camera | `camera` |
| pin | `mappin` |
| clock | `clock` |
| alert | `exclamationmark.triangle` |
| wifi-off | `wifi.slash` |
| sync | `arrow.triangle.2.circlepath` |
| leaf | `leaf` |
| drop | `drop` |
| layers | `square.stack.3d.up` |
| target | `scope` |
| calendar | `calendar` |
| play/stop | `play.fill` / `stop.fill` |
| search | `magnifyingglass` |
| radio | `dot.radiowaves.left.and.right` |
| user | `person.crop.circle` |

## Assets
No raster images used — the prototype is entirely SVG + type. **Replace** the striped placeholder tiles (`Placeholder` component) with real ranger photos once captured.

The Cape York coastline motif on Login is a stylized SVG (topographic contour lines + ridge silhouettes + sun) — reproduce in SwiftUI using `Canvas` or a `Path`-based `View`. Not a literal geographic outline.

## Files in this bundle
- `prototype/Lama Lama Rangers.html` — entry point. Open in a modern browser.
- `prototype/tokens.jsx` — design tokens (colors, seeded demo data).
- `prototype/atoms.jsx` — shared primitives (Icon, Button, Card, Chip, TabBar, etc.).
- `prototype/ios-frame.jsx` — iOS device bezel used for presentation.
- `prototype/screens/login.jsx`
- `prototype/screens/dashboard.jsx`
- `prototype/screens/map.jsx`
- `prototype/screens/sightings.jsx`
- `prototype/screens/guide.jsx`
- `prototype/screens/ops.jsx`

## Implementation order (suggested)
1. Design system: colors + `Font` extensions + reusable `Card`, `Chip`, `SyncBadge`, `Placeholder`.
2. Data models + SwiftData schema + seed data.
3. Login + PIN + auth gate.
4. TabView + Dashboard.
5. Map + pin rendering + log-sighting sheet.
6. Sightings list + detail.
7. Guide + variant detail + biocontrol banner.
8. Tasks, Inventory, Patrol.
9. Mesh sync (MultipeerConnectivity).
10. Polish: haptics on PIN, animations, sunlight-readable contrast pass.
