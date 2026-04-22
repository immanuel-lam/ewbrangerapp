# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## What this project is

An iOS field app for the Lama Lama Rangers of Yintjingga Aboriginal Corporation (YAC), Port Stewart, Cape York Peninsula, QLD. Rangers track invasive plant infestations (Lantana camara and 5 other species), coordinate treatment, and sync records peer-to-peer — all without a reliable internet connection.

**Academic context:** EWB Challenge 2026, unit 31265 Communications for IT Professionals, UTS Autumn 2026.

The active demo branch is **`demov3`** — a fully functional offline app with local-only CoreData persistence, Bluetooth mesh sync (MultipeerConnectivity), 5-tab UI, and 12 new field-safety/data-quality features added on top of `demov2`. No cloud backend is implemented.

---

## Repository layout

```
/Users/immanuellam/Documents/ewbapp/
├── ewbapp/          ← iOS Xcode project (THIS repo)
├── showcase/        ← React/Vite showcase website (sibling directory, separate from iOS)
└── ewbapp-android/  ← Android port (separate)
```

**Git remote:** `https://github.com/immanuel-lam/ewbrangerapp.git`

---

## Branch lineage

| Branch | Purpose |
|---|---|
| `v1-poc` | Original proof-of-concept — Lantana only, 3 tabs (archived) |
| `main` | Production build — clean start, real GPS, real peer sync |
| `demonewui` | Intermediate — new design system merged into demo, not the full V2 |
| `demov2` | Full V2 demo — multi-species, complete redesign, all core features, pre-seeded data |
| `demov3` | **Active** — `demov2` + 12 new features. This is what to work on. |

`demov3` branches directly from `demov2` (confirmed via `git merge-base`). Do not describe it as built on `demonewui`.

---

## Build command

```bash
xcodebuild -scheme ewbapp -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -configuration Debug build
```

- No test target in the scheme (test files exist in `ewbappTests/` and `LamaLamaRangersTests/` but are not wired to a CI target).
- No linter configured.

---

## Project identifiers

- **Bundle ID:** `com.immanuel.ewbapp`
- **Xcode project:** `ewbapp.xcodeproj` (source root: `ewbapp/ewbapp/`)
- **iOS deployment target:** 26.2
- **Swift:** no third-party dependencies — SwiftUI + CoreData + MapKit + MultipeerConnectivity + AVFoundation only

---

## Critical Xcode constraints — read before touching Swift files

1. **`PBXFileSystemSynchronizedRootGroup`** — never edit `.pbxproj` manually. Every `.swift` file on disk is auto-included in the target. Just create/delete files; Xcode picks them up.

2. **`SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES`** — any file using `@Published`, `ObservableObject`, `Combine` operators, or `Timer` **must** have `import Combine` explicitly at the top. The compiler will error without it even if Foundation or SwiftUI are imported.

3. **`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`** — all types are `@MainActor` by default. Actor-isolated types (`SyncEngine`, `MeshSyncEngine`) **must** be declared `actor` explicitly, or they'll inherit MainActor isolation unintentionally and cause concurrency errors.

---

## Architecture

MVVM + Repository. Dependency graph flows strictly downward — never skip a layer:

```
SwiftUI Views
  └── ViewModels  (@MainActor ObservableObject, held as @StateObject in views)
        └── Repositories  (synchronous CoreData reads, async writes)
              └── PersistenceController  (NSPersistentContainer)
                    ├── mainContext        — UI reads only (never write here)
                    └── backgroundContext  — all writes (shared lazy instance)
```

### Dependency injection root

`AppEnvironment.swift` — `@MainActor ObservableObject` singleton (`AppEnvironment.shared`) holding:
- `persistence: PersistenceController`
- `syncEngine: SyncEngine`
- `locationManager: LocationManager`
- `authManager: AuthManager`

Injected via `.environmentObject()` at the SwiftUI root. Accessed via `@EnvironmentObject` in views. Inside ViewModel `init()`, use `AppEnvironment.shared` directly (because `@EnvironmentObject` isn't available during `init`).

### App entry point

`ewbappApp.swift` — holds two additional `@StateObject`s injected as `.environmentObject()`:
- `AppThemeViewModel` — provides `.preferredColorScheme`, drives `RedLightModifier`
- `SafetyCheckInViewModel` — shared instance consumed by the Safety tab

---

## CoreData

- Model file: `CoreData/LamaLamaRangers.xcdatamodeld`
- **No Xcode codegen** — all `NSManagedObject` subclasses are hand-written in `CoreData/ManagedObjects.swift`. When adding a new entity, add it both in the `.xcdatamodeld` file and in `ManagedObjects.swift`.
- `SafetyCheckIn` is the exception — it has separate generated files: `CoreData/SafetyCheckIn+CoreDataClass.swift` and `CoreData/SafetyCheckIn+CoreDataProperties.swift`.
- Helper methods: `context.fetchFirst(_:predicate:)` and `context.fetchAll(_:predicate:sortDescriptors:)` — defined in `CoreData/CoreDataHelpers.swift`.
- `backgroundContext` merge policy: `NSMergeByPropertyObjectTrumpMergePolicy`
- `mainContext` merge policy: `NSMergeByPropertyStoreTrumpMergePolicy`
- After any background save, wait ~150 ms before calling `load()` on a ViewModel — `automaticallyMergesChangesFromParent` fires asynchronously.

### Entity reference

| Entity | Key attributes / relationships |
|---|---|
| `SightingLog` | `variant` (String — species), `latitude`, `longitude`, `photoPath`, `voiceNotePath`, `infestationAreaEstimate` (Double) → `RangerProfile`, → `InfestationZone` (optional), ↔ `TreatmentRecord` (to-many) |
| `TreatmentRecord` | `method`, `herbicide`, `outcomeNotes`, `followUpDate` → `SightingLog`, → `RangerProfile`, → `RangerTask` (followUpTask, optional) |
| `RangerTask` | `title`, `priority`, `dueDate`, `isComplete` → `RangerProfile`, → `TreatmentRecord` (sourceTreatment, optional) |
| `RangerProfile` | `name`, `role`, `pin` (unused — PIN is shared via Keychain) |
| `InfestationZone` | `name`, `status` ↔ `InfestationZoneSnapshot` (ordered, to-many), ↔ `SightingLog` (to-many) |
| `InfestationZoneSnapshot` | `polygonCoordinates` as `NSArray` of `[[Double]]` (lat/lon pairs), `createdAt` |
| `PatrolRecord` | `areaName`, `startTime`, `endTime`, `notes`, `checklistItems` as `NSData` (JSON-encoded `[PatrolChecklistItem]`) → `RangerProfile` |
| `PesticideStock` | `productName`, `quantity`, `unit`, `threshold` ↔ `PesticideUsageRecord` (to-many) |
| `PesticideUsageRecord` | `amount`, `date` → `PesticideStock` |
| `SyncQueue` | `entityType`, `entityID`, `action`, `createdAt` — created atomically on every save via `SyncQueueManager.enqueue(...)` |
| `Equipment` | `name`, `type`, `purchaseDate`, `nextServiceDate` ↔ `MaintenanceRecord` (to-many via `maintenanceRecords`) |
| `MaintenanceRecord` | `date`, `notes`, `technicianName` → `Equipment` |
| `SafetyCheckIn` | `interval` (TimeInterval), `lastCheckIn` (Date), `isActive` (Bool) — standalone, no relationships |
| `HazardLog` | `latitude`, `longitude`, `hazardType`, `severity`, `notes`, `photoPath`, `syncedToCloud` (Bool) — standalone |

**Important:** `InfestationZone.snapshots` is `NSOrderedSet?` — always access as `zone.snapshots?.array as? [InfestationZoneSnapshot]`, never cast directly.

---

## Auth

Single shared PIN stored as a bcrypt hash in Keychain (`KeychainService`). First login with any PIN sets it for all rangers on the device. Demo PIN: `1234`. Rangers seeded on first launch: Alice Johnson (Senior Ranger), Bob Smith (Ranger), Carol White (Ranger). `AuthManager.changePIN(oldPIN:newPIN:)` validates the old hash before updating.

---

## Species model

`InvasiveSpecies` enum — `Models/Enums/InvasiveSpecies.swift`. Cases:
- `lantana`, `rubberVine`, `pricklyAcacia`, `sicklepod`, `giantRatsTailGrass`, `pondApple`, `unknown`

`InvasiveSpecies.from(legacyVariant:)` maps old Lantana variant strings → `.lantana`. CoreData stores species as `String` via the `variant` attribute — no schema migration needed for the enum change.

---

## Sync

### Mesh sync (implemented — demov2+)
`MeshSyncEngine` (`Services/Sync/MeshSyncEngine.swift`) is a Swift `actor` using `MultipeerConnectivity`, service type `"yac-lantana"`.

Flow: connect → exchange manifest (`[ManifestEntry]` with entity type + ID + updatedAt) → request diff IDs → `sendRequestedRecords` serialises SightingLog/TreatmentRecord/RangerTask as JSON → `receiveRecords` applies Last-Write-Wins (LWW) by `updatedAt`. Photos are **excluded** from mesh sync.

### Cloud sync (not implemented — V3 scope)
`SyncEngine.triggerSync()` is a **no-op**. `SyncQueue` entries accumulate locally but are never uploaded. `SyncEngine` monitors connectivity via `NWPathMonitor` and calls `triggerSync()` on reconnect (still a no-op). Do not add real API calls or Supabase integration — that is future V3 scope with no ETA.

`Services/API/` files are all stubs. The "Cloud Sync" view in Hub (`Demo/DemoLiveSyncView.swift`) is a pure simulation.

---

## Map

- `MapView` (`Views/Map/MapView.swift`) — `UIViewRepresentable` wrapping `MKMapView`. Callbacks pass a `CGPoint` screen-space anchor alongside the tapped object so `MapActionCard` can position itself near the pin.
- Zone overlays: `ZonePolygonOverlay: MKPolygon` when a snapshot exists; `ZoneCircleOverlay: MKCircle` fallback derived from sighting centroid.
- Draw mode in `MapContainerView`: user taps vertices → `drawVertices: [CLLocationCoordinate2D]` → `ZoneRepository.addSnapshot(...)`.
- Polygon hit-testing: `renderer.point(for: mapPoint)` then `renderer.path.contains(...)` — **not** map coordinate comparison.
- `MapActionCard` is a floating bubble anchored to pin's screen coordinate, not a bottom sheet.
- Offline tiles: `LocalTileOverlay` / `OfflineTileManager` — no tile files bundled, falls back gracefully to blank tiles.
- Patrol area coordinates hardcoded in `Resources/PortStewartZones.swift` (10 named areas).
- GPS in simulator: 8-second timeout falls back to Port Stewart coords `(-14.7019, 143.7075)`.

---

## Tab structure (demov3)

`MainTabView` — **5 tabs:**

| Tab | Root view | Notes |
|---|---|---|
| Map | `MapContainerView` | Satellite/standard, zones, sightings, draw mode |
| Activity | `ActivityView` | Segmented: Sightings / Patrols / Tasks |
| Guide | `SpeciesGuideView` | Reference cards for all 6 species |
| Safety | `SafetyCheckInView` | Countdown ring, "I'm Safe" reset, UNNotification |
| Hub | `HubView` | Tile grid → Dashboard, Supplies, Day Sync, Zones, Cloud Sync, Handover, Equipment, Hazards, Settings |

---

## Design system

`Views/DesignSystem.swift` — warm Australian bushland palette. Key tokens:

| Token | Value |
|---|---|
| `Color.dsPrimary` | `#2A5C3F` (deep forest green) |
| `Color.dsAccent` | `#C4692A` (terracotta amber) |
| `Color.dsBackground` | `#F7F3EC` (warm cream) |

- `DSFont.*`: largeTitle / title / headline / subhead / body / callout / footnote / caption / badge / mono
- `DSSpace.*`: xs / sm / md / lg / xl / xxxl
- `DSRadius.*`: xs / sm / md / lg
- View modifiers: `.dsCard()` / `.dsElevatedCard()`

---

## Complete file map

```
ewbapp/ewbapp/
├── ewbappApp.swift                         ← App entry point, @StateObject injections
├── AppEnvironment.swift                    ← DI root singleton
│
├── Config/
│   ├── AppConfig.swift
│   ├── PhenologyAlerts.swift               ← PhenologyAlertStore, Cape York phenology data
│   ├── SeasonalAlertConfig.swift
│   └── SyncConfig.swift
│
├── CoreData/
│   ├── CoreDataHelpers.swift               ← fetchFirst / fetchAll helpers
│   ├── ManagedObjects.swift                ← ALL NSManagedObject subclasses (hand-written)
│   ├── PersistenceController.swift         ← NSPersistentContainer, mainContext, backgroundContext
│   ├── SafetyCheckIn+CoreDataClass.swift   ← Generated (exception to hand-written rule)
│   └── SafetyCheckIn+CoreDataProperties.swift
│
├── Demo/
│   ├── DemoLiveSyncView.swift              ← Fake Supabase + S3 sync dashboard
│   ├── DemoMeshSyncView.swift              ← Animated Bluetooth mesh sync demo
│   ├── DemoSeeder.swift                    ← Seeds 6 zones, 28 sightings, 10 patrols etc.
│   └── DeveloperSettings.swift             ← GPS spoof, reset data
│
├── Models/
│   ├── Domain/
│   │   ├── PatrolChecklistItem.swift       ← includes timeEstimateMins: Int
│   │   ├── RangerStatus.swift              ← Status enum for mesh broadcast
│   │   └── SeasonalAlert.swift
│   ├── DTOs/                               ← Data transfer objects per entity
│   └── Enums/
│       ├── InfestationSize.swift
│       ├── InvasiveSpecies.swift           ← 6 species + unknown
│       ├── RangerRole.swift
│       ├── RegrowthLevel.swift             ← none/light/moderate/heavy
│       ├── SyncStatus.swift
│       ├── TaskPriority.swift
│       └── TreatmentMethod.swift           ← foliar/cutStump/basalBark/mechanical/stemInjection/fire
│
├── Repositories/
│   ├── Protocols/                          ← Repository protocols
│   ├── PatrolRepository.swift
│   ├── RangerRepository.swift
│   ├── SightingRepository.swift
│   ├── TaskRepository.swift
│   ├── TreatmentRepository.swift
│   └── ZoneRepository.swift
│
├── Resources/
│   ├── AreaChecklists.swift                ← Per-area checklist templates
│   ├── HerbicideDatabase.swift             ← Product/species/method compatibility data
│   ├── InvasiveSpeciesContent.swift        ← Guide content for all 6 species
│   └── PortStewartZones.swift              ← 10 named patrol areas + defaultChecklist
│
├── Services/
│   ├── API/                                ← All stubs — no real network calls
│   │   ├── SupabaseClient.swift
│   │   ├── SightingAPIService.swift
│   │   ├── PatrolAPIService.swift
│   │   ├── PesticideAPIService.swift
│   │   ├── RangerAPIService.swift
│   │   └── ZoneAPIService.swift
│   ├── Auth/
│   │   ├── AuthManager.swift
│   │   └── KeychainService.swift
│   ├── Location/
│   │   └── LocationManager.swift           ← CLLocationManager wrapper, 8s simulator fallback
│   ├── Map/
│   │   ├── LocalTileOverlay.swift
│   │   └── OfflineTileManager.swift
│   └── Sync/
│       ├── ConflictResolver.swift
│       ├── MeshSyncEngine.swift            ← Swift actor, MultipeerConnectivity
│       ├── PhotoUploadManager.swift        ← Stub
│       ├── SyncEngine.swift                ← triggerSync() is a no-op
│       └── SyncQueueManager.swift
│
├── ViewModels/
│   ├── AppThemeViewModel.swift             ← AppTheme enum, preferredColorScheme
│   ├── DashboardViewModel.swift
│   ├── EquipmentViewModel.swift
│   ├── HazardViewModel.swift
│   ├── LoginViewModel.swift
│   ├── LogSightingViewModel.swift          ← BiocontrolObservation enum
│   ├── MapViewModel.swift
│   ├── MeshSyncViewModel.swift
│   ├── PatrolChecklistViewModel.swift
│   ├── PatrolViewModel.swift               ← plannedMinutes, elapsedMinutes
│   ├── PatrolViewModel+Checklist.swift
│   ├── PesticideViewModel.swift
│   ├── RangerStatusViewModel.swift
│   ├── SafetyCheckInViewModel.swift
│   ├── SettingsViewModel.swift
│   ├── SightingDetailViewModel.swift
│   ├── SightingListViewModel.swift
│   ├── TaskListViewModel.swift
│   └── TreatmentEffectivenessViewModel.swift
│
└── Views/
    ├── Activity/ActivityView.swift         ← Segmented: Sightings/Patrols/Tasks
    ├── App/
    │   ├── ContentView.swift
    │   └── MainTabView.swift               ← 5 tabs
    ├── Components/
    │   ├── LargeButton.swift
    │   ├── OfflineIndicatorView.swift
    │   ├── RedLightOverlay.swift           ← RedLightModifier (colour-multiply)
    │   ├── SeasonalAlertBanner.swift
    │   ├── SizeEstimationOverlay.swift     ← Draggable rect, area in m²
    │   ├── SpeciesIndicator.swift
    │   ├── SyncStatusBadge.swift
    │   └── VoiceNoteRecorder.swift         ← AVAudioRecorder/Player, 3 states
    ├── Dashboard/DashboardView.swift
    ├── DesignSystem.swift                  ← All design tokens, DSFont, DSSpace, DSRadius
    ├── Equipment/
    │   ├── AddEquipmentView.swift
    │   ├── AddMaintenanceRecordView.swift
    │   └── EquipmentListView.swift
    ├── Guide/
    │   ├── SpeciesDetailView.swift
    │   └── SpeciesGuideView.swift
    ├── Hazard/
    │   ├── HazardLogView.swift
    │   └── LogHazardView.swift
    ├── Hub/
    │   ├── ConflictResolverView.swift      ← Demo: 3 fake zone conflicts, Keep/Merge
    │   ├── HubView.swift
    │   └── ShiftHandoverView.swift         ← Live CoreData counts, ShareLink export
    ├── Login/
    │   ├── LoginView.swift
    │   └── PINEntryView.swift
    ├── Map/
    │   ├── AddZoneView.swift
    │   ├── BloomCalendarButton.swift
    │   ├── BloomCalendarView.swift         ← Per-month risk: HIGH/MODERATE/Low
    │   ├── LayerToggleView.swift
    │   ├── MapActionCard.swift             ← Floating bubble anchored to pin
    │   ├── MapContainerView.swift          ← Draw mode, layer state
    │   ├── MapView.swift                   ← UIViewRepresentable wrapping MKMapView
    │   ├── PatrolAnnotation.swift
    │   ├── SightingPinAnnotation.swift
    │   ├── TimelineScrubberView.swift
    │   ├── ZoneDetailView.swift
    │   └── ZoneListView.swift
    ├── Mesh/RangerStatusView.swift         ← Ranger status over mesh
    ├── MeshSync/MeshSyncView.swift
    ├── Patrol/
    │   ├── ActivePatrolView.swift          ← Two-tone stamina bar, 85% warning
    │   ├── AreaChecklistView.swift
    │   ├── PatrolListView.swift
    │   └── PatrolView.swift
    ├── Pesticide/
    │   ├── LogUsageView.swift
    │   ├── PesticideAlertBanner.swift      ← Surfaces on Dashboard for critical stock
    │   ├── PesticideDetailView.swift
    │   └── PesticideListView.swift
    ├── Protocol/ControlProtocolView.swift
    ├── Safety/SafetyCheckInView.swift
    ├── Settings/SettingsView.swift         ← Theme picker (Night Mode), GPS spoof, reset
    ├── Sighting/
    │   ├── ControlRecommendationView.swift
    │   ├── GPSCaptureView.swift
    │   ├── LogSightingView.swift           ← Biocontrol prompt, phenology banner, voice note, size overlay
    │   ├── PhotoCaptureView.swift
    │   ├── SightingDetailView.swift        ← BeforeAfterCard detection, TreatmentFollowUp
    │   ├── SightingListView.swift
    │   ├── SizePickerView.swift
    │   ├── TreatmentEntryView.swift        ← After photos → outcomeNotes prefix
    │   ├── TreatmentFollowUpView.swift
    │   └── VariantPickerView.swift
    ├── Tasks/
    │   ├── AddTaskView.swift
    │   └── TaskListView.swift
    └── Treatment/
        └── HerbicideCheckerView.swift
```

---

## demov2 features (the V2 base)

All features that exist in `demov2` and are inherited by `demov3`:

| Feature | Key detail |
|---|---|
| Multi-species | 6 invasive species via `InvasiveSpecies` enum |
| Design system | `DesignSystem.swift` — dsBackground, dsPrimary, dsAccent, DSFont, DSSpace, DSRadius |
| Map | Satellite/standard, colour-coded sighting pins, zone polygons, patrol markers, layer toggles |
| Bloom Calendar | `BloomCalendarView.swift` — per-month HIGH/MODERATE/Low risk for all 6 species |
| Sighting Log | GPS, species picker, size picker, photos, full history |
| Lantana Biocontrol Prompt | `BiocontrolPromptCard` in `LogSightingView` — Observed/Not Seen/Unsure; warns against foliar spray if biocontrol observed |
| Treatment Records | 6 methods, herbicide, outcome notes, follow-up date |
| Before/After Photos | `TreatmentEntryView` appends `"📷 After: N photo(s). "` to outcomeNotes; `SightingDetailView` detects prefix and renders `BeforeAfterCard` |
| Patrol | Checklist, area, duration, notes, calendar view |
| Patrol Stamina Metric | `timeEstimateMins` per `PatrolChecklistItem`; `ActivePatrolView` two-tone bar; 85% "Running long" warning |
| Species Guide | `SpeciesGuideView` — ID features, control methods, seasonal notes |
| Pesticide Inventory | Stock tracking, usage logging, low-stock alerts |
| Tasks | Priority + due date, filtered by logged-in ranger |
| Hub | Tile grid |
| Dashboard | Sightings-per-month bar chart, zone status, sightings by ranger, open tasks |
| Day Sync (Mesh) | `MeshSyncEngine` actor, `MultipeerConnectivity`, LWW by `updatedAt` |
| Zone Conflict Resolver | `ConflictResolverView` — demo: 3 fake conflicts, Keep Mine / Keep Theirs / Merge |
| Shift Handover Card | `ShiftHandoverView` — live CoreData counts, ShareLink text export |
| Cloud Sync demo | `DemoLiveSyncView` — fake Supabase+S3, jittery upload speed, pg_dump simulation |
| Pre-seeded demo data | `DemoSeeder` — 6 zones, 28 sightings, 10 patrols, pesticide stocks, tasks |

---

## demov3 additions (12 features on top of demov2)

| # | Feature | Key files |
|---|---|---|
| 1 | **Safety Check-In** | `SafetyCheckInView.swift`, `SafetyCheckInViewModel.swift` — countdown ring, UNNotification, "I'm Safe" reset |
| 2 | **Hazard Logger** | `HazardLogView.swift`, `LogHazardView.swift`, `HazardViewModel.swift` — GPS hazard records with type, severity, photo |
| 3 | **Voice Notes** | `VoiceNoteRecorder.swift` — AVAudioRecorder/AVAudioPlayer, 3 states: idle/recording/recorded; saved to `SightingLog.voiceNotePath` |
| 4 | **Photo Size Estimation** | `SizeEstimationOverlay.swift` — draggable rect, reference object picker, area in m²; saves to `SightingLog.infestationAreaEstimate` |
| 5 | **Phenology Alerts** | `PhenologyAlerts.swift` (`PhenologyAlertStore`) — Cape York phenology for all 6 species; auto-fires banner in `LogSightingView` |
| 6 | **Herbicide Checker** | `HerbicideCheckerView.swift`, `HerbicideDatabase.swift` — product/species/method compatibility matrix |
| 7 | **Treatment Effectiveness** | `TreatmentFollowUpView.swift`, `TreatmentEffectivenessViewModel.swift` — `RegrowthLevel` enum, timeline |
| 8 | **Per-Area Patrol Checklists** | `AreaChecklistView.swift`, `PatrolViewModel+Checklist.swift`, `AreaChecklists.swift` |
| 9 | **Pesticide Stock Alerts** | `PesticideAlertBanner.swift` — surfaces on `DashboardView` when any stock is critical |
| 10 | **Equipment Maintenance Log** | `EquipmentListView.swift`, `AddEquipmentView.swift`, `AddMaintenanceRecordView.swift`, `EquipmentViewModel.swift` |
| 11 | **Ranger Status Broadcast** | `RangerStatusView.swift`, `RangerStatusViewModel.swift`, `RangerStatus.swift` — status over mesh |
| 12 | **Night Mode (Red Light)** | `AppThemeViewModel.swift` (`AppTheme` enum), `RedLightOverlay.swift` (`RedLightModifier`) — colour-multiply overlay, no view changes required |

### New CoreData entities added in demov3

- `Equipment` — tracked field equipment with service dates and maintenance history
- `MaintenanceRecord` — individual service events linked to `Equipment`
- `SafetyCheckIn` — persisted check-in sessions (standalone, no relationships)
- `HazardLog` — GPS-tagged hazard records (standalone, no relationships)

---

## Demo data

`Demo/DemoSeeder.swift` seeds on first launch (guard: checks if any `RangerProfile` exists):
- 3 rangers: Alice Johnson (Senior Ranger), Bob Smith (Ranger), Carol White (Ranger)
- 6 infestation zones with polygon snapshots
- 28 sightings across all 6 invasive species
- 10 patrol records
- Pesticide stocks and usage records
- Open and overdue tasks

Reset data: Settings → Reset App Data (calls `DemoSeeder.reset()`).

GPS spoof: Settings → Developer → Spoof Location (defined in `Demo/DeveloperSettings.swift`).

---

## What NOT to do

- **Never add real Supabase API calls, S3 uploads, or live network features.** `Services/API/` is all stubs. Cloud sync is V3 scope with no ETA.
- **Never edit `.pbxproj` manually.** `PBXFileSystemSynchronizedRootGroup` auto-includes all `.swift` files.
- **Never write on `mainContext`.** All CoreData writes go through `backgroundContext`.
- **Never skip `import Combine`** in any file using `@Published`, `ObservableObject`, or `Timer`.
- **Never describe demov3 as based on `demonewui`.** It is based on `demov2`.
- **Do not add a `Co-Authored-By` trailer to any git commit message.**
- **Never use MapKit paid tiers** (e.g., MapKit JS, paid tile services).

---

## Showcase website (sibling project)

A separate React/Vite showcase site lives in `/Users/immanuellam/Documents/ewbapp/showcase/`. It is **not** part of the Xcode project — it's a standalone web app.

### Tech stack
- React 18 + Vite 5
- Single file: `src/App.jsx` (all components) + `src/App.css` (all styles)
- Google Fonts: **Gloock** (serif display) + **Epilogue** (sans body)
- No component library — pure CSS with custom properties

### CSS design tokens (App.css)
```css
--font-display: 'Gloock', Georgia, serif;
--font-body:    'Epilogue', -apple-system, system-ui, sans-serif;
--green-900: oklch(17% 0.038 153)   /* dark hero backgrounds */
--green-700: oklch(34% 0.090 153)
--green-500: oklch(46% 0.095 153)
--cream:     oklch(96.5% 0.013 84)  /* page background */
--amber:     oklch(59% 0.152 50)    /* accent */
--ink:       oklch(15% 0.028 153)   /* body text */
--ease-out:  cubic-bezier(0.16, 1, 0.3, 1)
```

### Key components in App.jsx
- `useParallax(refs, multipliers)` — rAF loop for hero; **skips on touch devices** via `matchMedia('(hover: none)')`
- `ParallaxWrapper` — rAF loop for feature section phone frames; also skips on touch devices
- `Reveal` — IntersectionObserver entrance animation (opacity + translateY)
- `useInView(threshold, { repeat })` — underlying IntersectionObserver hook
- `useCountUp(target, duration)` — animated number count-up
- `PhoneFrame` — iOS phone mockup wrapper
- `Accordion` — `grid-template-rows: 0fr → 1fr` height animation
- `SectionTag` — amber pip + uppercase label

### Screenshots used in showcase
All in `showcase/src/assets/screenshots/`:
`map.png`, `bloom.png`, `log-sighting.png`, `bicontrol.png`, `treatment.png`, `patrol.png`, `checklist.png`, `day-sync.png`, `conflict.png`, `species-guide.png`, `hub.png`

### Deploy workflow (GitHub Pages)
The showcase deploys to the `gh-pages` branch of `https://github.com/immanuel-lam/ewbrangerapp.git`. Live URL: `https://immanuel-lam.github.io/ewbrangerapp/`

Vite base is `/ewbrangerapp/` (set in `vite.config.js`).

**Deploy steps — always follow exactly:**

```bash
# 1. Build
cd /Users/immanuellam/Documents/ewbapp/showcase
npm run build

# 2. Check out gh-pages as a worktree
git -C /Users/immanuellam/Documents/ewbapp/ewbapp worktree add /tmp/ghpages gh-pages

# 3. Copy dist into worktree
cp -r dist/assets /tmp/ghpages/
cp dist/index.html /tmp/ghpages/

# 4. Commit and push
git -C /tmp/ghpages add -A
git -C /tmp/ghpages commit -m "deploy(showcase): <description>"
git -C /tmp/ghpages push origin gh-pages

# 5. Clean up
git -C /Users/immanuellam/Documents/ewbapp/ewbapp worktree remove /tmp/ghpages
```

**Note:** The iOS Xcode project is the git repo. The showcase is a sibling directory (`/Users/immanuellam/Documents/ewbapp/showcase/`) with no separate `.git` — it relies on the parent Xcode repo for `gh-pages` branch management.

### Showcase mobile / animation rules
- Parallax (`useParallax`, `ParallaxWrapper`) must always check `window.matchMedia('(hover: none)').matches` and return early on touch devices
- `will-change: auto` on `.hero-topo`, `.hero-watermark`, `.hero-phone` at ≤600px (CSS media query)
- `.reveal` entrance distance is 28px desktop, 14px at ≤600px
- `prefers-reduced-motion: reduce` media query disables all transitions/animations
- Responsive breakpoints: 900px (collapse to 1-col grids, hide hero phones) and 600px (reduced font sizes, mobile padding)

---

## Git conventions

- Active development branch: `demov3`
- `gh-pages` branch: showcase website only — never merge code there, only copy `dist/`
- **Do not add `Co-Authored-By` trailers to any commit message** (project-wide rule, any branch)
- Commit messages follow conventional commits format: `feat:`, `fix:`, `docs:`, `chore:`, `deploy:`
